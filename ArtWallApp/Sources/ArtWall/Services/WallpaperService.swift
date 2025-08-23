import Foundation
import AppKit

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
    
    /// Configure wallpaper settings using macOS native APIs
    private func configureWallpaperSettings(collectionPath: URL) async throws {
        logger.debug("Starting wallpaper configuration for path: \(collectionPath.path)", category: .wallpaper)
        
        // Get all image files in the collection
        let imageFiles = try getImageFiles(in: collectionPath)
        
        guard !imageFiles.isEmpty else {
            logger.error("No images found in collection path: \(collectionPath.path)", category: .wallpaper)
            throw WallpaperError.noImagesFound(collectionPath.path)
        }
        
        logger.info("Found \(imageFiles.count) images in collection", category: .wallpaper)
        
        // Set the first image as wallpaper for all screens to start
        let firstImageURL = imageFiles.first!
        let screens = NSScreen.screens
        
        logger.debug("Setting wallpaper for \(screens.count) screens", category: .wallpaper)
        
        // Configure wallpaper for all screens with timeout protection
        for (index, screen) in screens.enumerated() {
            do {
                logger.debug("Setting wallpaper for screen \(index + 1)/\(screens.count): \(screen.localizedName)", category: .wallpaper)
                
                // Set wallpaper with specific options
                let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
                    .imageScaling: NSImageScaling.scaleProportionallyUpOrDown, // Fit to screen
                    .allowClipping: false,
                    .fillColor: NSColor.black // Black filler color
                ]
                
                // Use Task.detached to avoid blocking the main actor
                try await withTimeout(seconds: 10) {
                    try await Task.detached { @MainActor in
                        try NSWorkspace.shared.setDesktopImageURL(firstImageURL, for: screen, options: options)
                    }.value
                }
                
                logger.success("Set wallpaper for screen: \(screen.localizedName)", category: .wallpaper)
            } catch {
                logger.error("Failed to set wallpaper for screen \(screen.localizedName)", error: error, category: .wallpaper)
                throw WallpaperError.failedToSetWallpaper(error.localizedDescription)
            }
        }
        
        // Configure rotation settings using defaults (30 minutes = 1800 seconds)
        logger.debug("Configuring wallpaper rotation settings", category: .wallpaper)
        try configureWallpaperRotation(collectionPath: collectionPath, intervalSeconds: 1800)
    }
    
    /// Configure wallpaper rotation using macOS defaults
    private func configureWallpaperRotation(collectionPath: URL, intervalSeconds: Int) throws {
        let defaults = UserDefaults.standard
        
        // Set wallpaper folder for rotation
        defaults.set(collectionPath.path, forKey: "DesktopPictureFolderPath")
        
        // Enable rotation
        defaults.set(true, forKey: "DesktopPictureChangeEnabled")
        
        // Set rotation interval (30 minutes = 1800 seconds)
        defaults.set(intervalSeconds, forKey: "DesktopPictureChangeInterval")
        
        // Set scaling mode to fit
        defaults.set("Fit", forKey: "DesktopPictureImageScaling")
        
        // Set filler color to black
        defaults.set("0.0 0.0 0.0", forKey: "DesktopPictureFillerColor")
        
        // Apply changes
        defaults.synchronize()
        
        print("✅ Configured wallpaper rotation: 30-minute intervals, fit-to-screen, black filler")
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
