import Foundation
import AppKit
import Wallpaper

/// Custom wallpaper rotation engine that provides reliable timer-based wallpaper changes
/// Solves macOS Sequoia system bugs with folder rotation by using working NSWorkspace individual image API
@MainActor
class WallpaperRotationEngine: ObservableObject {
    
    // MARK: - Shared Instance
    static let shared = WallpaperRotationEngine()
    
    // MARK: - Published Properties
    @Published var isRotating = false
    @Published var currentCollection: String?
    @Published var currentImageIndex = 0
    @Published var totalImages = 0
    @Published var timeUntilNext: Int = 0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var countdownTimer: Timer?
    private var images: [URL] = []
    private let logger = ArtWallLogger.shared
    private let rotationInterval: TimeInterval = 1800 // 30 minutes (1800 seconds)
    
    // MARK: - Initialization
    private init() {
        logger.info("WallpaperRotationEngine shared instance initialized", category: .wallpaper)
    }
    
    // MARK: - Public Interface
    
    /// Start wallpaper rotation for a collection
    func startRotation(collectionName: String, collectionPath: URL) {
        let tracker = logger.startProcess("Start Wallpaper Rotation: \(collectionName)", category: .wallpaper)
        
        do {
            // Stop any existing rotation
            stopRotation()
            
            // Load images from collection
            tracker.progress("Loading images from collection...")
            self.images = try loadImagesFromCollection(at: collectionPath)
            
            guard !images.isEmpty else {
                throw WallpaperRotationError.noImagesFound(collectionPath.path)
            }
            
            // Set initial state
            self.currentCollection = collectionName
            self.totalImages = images.count
            self.currentImageIndex = 0
            self.timeUntilNext = Int(rotationInterval)
            
            logger.info("Loaded \(images.count) images for rotation", category: .wallpaper)
            
            // Set initial wallpaper
            tracker.progress("Setting initial wallpaper...")
            try setCurrentWallpaper()
            
            // Start rotation timer
            tracker.progress("Starting rotation timer...")
            startRotationTimer()
            
            // Start countdown timer for UI updates
            startCountdownTimer()
            
            self.isRotating = true
            
            tracker.complete()
            logger.success("Started wallpaper rotation: \(collectionName) (\(images.count) images, \(Int(rotationInterval/60))min intervals)", category: .wallpaper)
            
        } catch {
            tracker.fail(error: error)
            logger.error("Failed to start wallpaper rotation", error: error, category: .wallpaper)
            
            // Reset state on failure
            self.isRotating = false
            self.currentCollection = nil
            self.currentImageIndex = 0
            self.totalImages = 0
        }
    }
    
    /// Stop wallpaper rotation
    func stopRotation() {
        logger.info("Stopping wallpaper rotation", category: .wallpaper)
        
        timer?.invalidate()
        timer = nil
        
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        isRotating = false
        currentCollection = nil
        currentImageIndex = 0
        totalImages = 0
        timeUntilNext = 0
        images.removeAll()
        
        logger.success("Wallpaper rotation stopped", category: .wallpaper)
    }
    
    /// Pause wallpaper rotation (keep state, stop timers)
    func pauseRotation() {
        guard isRotating else { return }
        
        logger.info("Pausing wallpaper rotation", category: .wallpaper)
        
        timer?.invalidate()
        timer = nil
        
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        isRotating = false
        
        logger.success("Wallpaper rotation paused", category: .wallpaper)
    }
    
    /// Resume wallpaper rotation
    func resumeRotation() {
        guard !isRotating, !images.isEmpty else { return }
        
        logger.info("Resuming wallpaper rotation", category: .wallpaper)
        
        startRotationTimer()
        startCountdownTimer()
        isRotating = true
        
        logger.success("Wallpaper rotation resumed", category: .wallpaper)
    }
    
    /// Manually advance to next wallpaper
    func nextWallpaper() {
        guard !images.isEmpty else { return }
        
        logger.info("Manual advance to next wallpaper", category: .wallpaper)
        
        rotateToNext()
        
        // Reset countdown timer
        timeUntilNext = Int(rotationInterval)
    }
    
    // MARK: - Private Methods
    
    /// Load image files from collection directory
    private func loadImagesFromCollection(at collectionPath: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: collectionPath, includingPropertiesForKeys: nil)
        
        let imageFiles = contents.filter { url in
            let pathExtension = url.pathExtension.lowercased()
            return ["jpg", "jpeg", "png", "tiff", "bmp"].contains(pathExtension)
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        logger.debug("Found \(imageFiles.count) image files in \(collectionPath.lastPathComponent)", category: .wallpaper)
        
        return imageFiles
    }
    
    /// Start the main rotation timer
    private func startRotationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: rotationInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.rotateToNext()
            }
        }
        
        logger.debug("Rotation timer started (\(Int(rotationInterval/60)) minutes)", category: .wallpaper)
    }
    
    /// Start countdown timer for UI updates (every second)
    private func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCountdown()
            }
        }
        
        logger.debug("Countdown timer started", category: .wallpaper)
    }
    
    /// Update countdown for UI
    private func updateCountdown() {
        if timeUntilNext > 0 {
            timeUntilNext -= 1
        } else {
            timeUntilNext = Int(rotationInterval)
        }
    }
    
    /// Rotate to the next wallpaper
    private func rotateToNext() {
        guard !images.isEmpty else { return }
        
        // Advance to next image
        currentImageIndex = (currentImageIndex + 1) % images.count
        
        let nextImage = images[currentImageIndex]
        logger.info("Rotating to image \(currentImageIndex + 1)/\(images.count): \(nextImage.lastPathComponent)", category: .wallpaper)
        
        do {
            try setWallpaper(url: nextImage)
            
            // Reset countdown
            timeUntilNext = Int(rotationInterval)
            
        } catch {
            logger.error("Failed to rotate wallpaper", error: error, category: .wallpaper)
        }
    }
    
    /// Set current wallpaper (based on current index)
    private func setCurrentWallpaper() throws {
        guard !images.isEmpty else {
            throw WallpaperRotationError.noImagesFound("No images loaded")
        }
        
        let currentImage = images[currentImageIndex]
        try setWallpaper(url: currentImage)
    }
    
    /// Set wallpaper using AppleScript for maximum rotation speed (configuration already set by WallpaperService)
    private func setWallpaper(url: URL) throws {
        // Minimal logging for speed - only log the essential info
        logger.debug("Rotating wallpaper: \(url.lastPathComponent)", category: .wallpaper)
        
        // Use AppleScript for fast image-only rotation (scaling/fill already configured)
        do {
            try setWallpaperViaAppleScript(imageURL: url)
            
            // Minimal success logging for speed
            logger.success("✅ Wallpaper rotated successfully", category: .wallpaper)
            
        } catch {
            logger.error("Failed to rotate wallpaper via AppleScript", error: error, category: .wallpaper)
            throw WallpaperRotationError.failedToSetWallpaper(error.localizedDescription)
        }
    }
    
    /// Apply wallpaper image using AppleScript (fast image-only rotation)
    private func setWallpaperViaAppleScript(imageURL: URL) throws {
        let imagePath = imageURL.path
        
        // Simple AppleScript for fast image rotation - no configuration options
        let appleScript = """
        tell application "System Events"
            tell every desktop
                set picture to "\(imagePath)"
            end tell
        end tell
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", appleScript]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw WallpaperRotationError.failedToSetWallpaper("AppleScript rotation failed: \(errorOutput)")
        }
    }
    
    // MARK: - Status Methods
    
    /// Get formatted time until next rotation
    func formattedTimeUntilNext() -> String {
        let minutes = timeUntilNext / 60
        let seconds = timeUntilNext % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Get current rotation status summary
    func getStatusSummary() -> String {
        guard isRotating, let collection = currentCollection else {
            return "No rotation active"
        }
        
        return "\(collection) - Image \(currentImageIndex + 1)/\(totalImages) - Next in \(formattedTimeUntilNext())"
    }
}

// MARK: - Error Types

enum WallpaperRotationError: LocalizedError {
    case noImagesFound(String)
    case failedToSetWallpaper(String)
    case rotationNotActive
    case configurationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noImagesFound(let path):
            return "No images found for rotation at: \(path)"
        case .failedToSetWallpaper(let reason):
            return "Failed to set wallpaper: \(reason)"
        case .rotationNotActive:
            return "Wallpaper rotation is not currently active"
        case .configurationFailed(let reason):
            return "Configuration failed: \(reason)"
        }
    }
}
