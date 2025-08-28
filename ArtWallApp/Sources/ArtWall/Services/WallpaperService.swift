import Foundation
import AppKit
import Wallpaper

@MainActor
class WallpaperService: ObservableObject {
    
    private let logger = ArtWallLogger.shared
    
    /// Sets up wallpaper rotation for a downloaded collection
    func setupWallpaperRotation(for collection: ArtCollection, at collectionPath: URL) async throws {
        let tracker = logger.startProcess("Wallpaper Setup: \(collection.title)", category: .wallpaper)
        
        do {
            // Check macOS version compatibility
            tracker.progress("Checking system compatibility...")
            try checkSystemCompatibility()
            
            // 1. Configure wallpaper settings for all screens
            tracker.progress("Configuring wallpaper settings...")
            try await configureWallpaperSettings(collectionPath: collectionPath)
            
            // 2. Configure screensaver to use same collection
            tracker.progress("Configuring screensaver...")
            try await configureScreensaver(collectionPath: collectionPath)
            
            tracker.complete()
            logger.success("Wallpaper and screensaver configured successfully for: \(collection.title)", category: .wallpaper)
        } catch {
            tracker.fail(error: error)
            logger.error("Failed to setup wallpaper rotation", error: error, category: .wallpaper)
            throw error
        }
    }
    
    /// Check if the current macOS version supports our wallpaper automation
    private func checkSystemCompatibility() throws {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        // Require macOS 14.0+ (Sonoma) for reliable wallpaper automation
        if osVersion.majorVersion < 14 {
            let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
            throw WallpaperError.unsupportedMacOSVersion(versionString)
        }
        
        print("✅ macOS \(osVersion.majorVersion).\(osVersion.minorVersion) - wallpaper automation supported")
    }
    
    /// Configure wallpaper settings using shell command approach
    private func configureWallpaperSettings(collectionPath: URL) async throws {
        logger.debug("Starting wallpaper configuration for path: \(collectionPath.path)", category: .wallpaper)
        
        // Get all image files in the collection
        let imageFiles = try getImageFiles(in: collectionPath)
        
        guard !imageFiles.isEmpty else {
            logger.error("No images found in collection path: \(collectionPath.path)", category: .wallpaper)
            throw WallpaperError.noImagesFound(collectionPath.path)
        }
        
        logger.info("Found \(imageFiles.count) images in collection", category: .wallpaper)
        
        // Set the first image as wallpaper using shell command (only working approach)
        let firstImageURL = imageFiles.first!
        let screens = NSScreen.screens
        
        logger.debug("Found \(screens.count) screens, setting wallpaper via shell command", category: .wallpaper)
        
        do {
            // Use shell command to set wallpaper (only reliable method)
            try setWallpaperViaShellCommand(imageURL: firstImageURL)
            
            logger.success("Successfully set wallpaper: \(firstImageURL.lastPathComponent)", category: .wallpaper)
            
            // Log info about multiple screens
            if screens.count > 1 {
                let screenNames = screens.map { $0.localizedName }
                logger.info("Wallpaper applied to all \(screens.count) screens: \(screenNames.joined(separator: ", "))", category: .wallpaper)
            }
            
        } catch {
            logger.error("Failed to set wallpaper", error: error, category: .wallpaper)
            throw WallpaperError.failedToSetWallpaper(error.localizedDescription)
        }
    }
    
    /// Configure screensaver to use the same collection
    private func configureScreensaver(collectionPath: URL) async throws {
        logger.debug("Configuring screensaver for collection: \(collectionPath.lastPathComponent)", category: .wallpaper)
        
        do {
            let defaults = UserDefaults.standard
            
            // Set screensaver to use slideshow module
            defaults.set("Slideshow", forKey: "ScreenSaverModuleName")
            defaults.set("/System/Library/Screen Savers/Slideshow.saver", forKey: "ScreenSaverModulePath")
            
            // Configure slideshow screensaver to use our collection folder
            let screensaverDefaults = UserDefaults(suiteName: "com.apple.screensaver.Slideshow")
            screensaverDefaults?.set([collectionPath.path], forKey: "SlideshowFolders")
            screensaverDefaults?.set(true, forKey: "SlideshowFoldersEnabled")
            screensaverDefaults?.set(30.0, forKey: "SlideshowDisplayTime") // 30 seconds per image
            screensaverDefaults?.set(true, forKey: "SlideshowRandomOrder")
            
            // Synchronize with timeout protection
            try await withTimeout(seconds: 5) {
                await Task.detached {
                    screensaverDefaults?.synchronize()
                    defaults.synchronize()
                }.value
            }
            
            logger.success("Configured screensaver to use collection: \(collectionPath.lastPathComponent)", category: .wallpaper)
        } catch {
            logger.error("Failed to configure screensaver", error: error, category: .wallpaper)
            throw WallpaperError.configurationFailed("Screensaver configuration failed: \(error.localizedDescription)")
        }
    }
    
    /// Set wallpaper using native macos-wallpaper Swift package (optimized for speed)
    private func setWallpaperViaShellCommand(imageURL: URL) throws {
        logger.debug("Setting wallpaper via native macos-wallpaper: \(imageURL.lastPathComponent)", category: .wallpaper)
        
        // Direct wallpaper setting without extra operations for speed
        do {
            try Wallpaper.set(
                imageURL,
                screen: .all,
                scale: .fit,
                fillColor: .black
            )
            
            logger.success("✅ Successfully set wallpaper with fit-to-screen scaling", category: .wallpaper)
        } catch {
            logger.error("Failed to set wallpaper on all screens: \(error)", category: .wallpaper)
            throw error
        }
    }
    
    /// Execute a task with a timeout to prevent freezing
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw WallpaperError.configurationFailed("Operation timed out after \(seconds) seconds")
            }
            
            guard let result = try await group.next() else {
                throw WallpaperError.configurationFailed("Task group failed")
            }
            
            group.cancelAll()
            return result
        }
    }
    
    /// Get all image files from a directory
    private func getImageFiles(in directory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        return contents.filter { url in
            let pathExtension = url.pathExtension.lowercased()
            return ["jpg", "jpeg", "png", "tiff", "bmp"].contains(pathExtension)
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    
    /// Check if collection needs updating by comparing with existing files
    func shouldUpdateCollection(_ collection: ArtCollection, at collectionPath: URL) -> Bool {
        let fileManager = FileManager.default
        
        // If directory doesn't exist, definitely need to download
        guard fileManager.fileExists(atPath: collectionPath.path) else {
            return true
        }
        
        // Check if we have the expected number of images
        do {
            let existingImages = try getImageFiles(in: collectionPath)
            if existingImages.count != collection.allArtworks.count {
                print("🔄 Collection needs update: expected \(collection.allArtworks.count) images, found \(existingImages.count)")
                return true
            }
        } catch {
            print("🔄 Collection needs update: error reading existing files")
            return true
        }
        
        return false
    }
    
    /// Clean up old collection before downloading new one
    func cleanupOldCollection(at collectionPath: URL) throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: collectionPath.path) {
            try fileManager.removeItem(at: collectionPath)
            print("🗑️ Removed old collection at: \(collectionPath.path)")
        }
    }
}

enum WallpaperError: LocalizedError {
    case noImagesFound(String)
    case failedToSetWallpaper(String)
    case configurationFailed(String)
    case unsupportedMacOSVersion(String)
    
    var errorDescription: String? {
        switch self {
        case .noImagesFound(let path):
            return "No images found in collection at: \(path)"
        case .failedToSetWallpaper(let reason):
            return "Failed to set wallpaper: \(reason)"
        case .configurationFailed(let reason):
            return "Failed to configure wallpaper settings: \(reason)"
        case .unsupportedMacOSVersion(let version):
            return "ArtWall requires macOS Sonoma 14.0 or later for wallpaper automation. You're running macOS \(version). Please update your system to use this feature."
        }
    }
}
