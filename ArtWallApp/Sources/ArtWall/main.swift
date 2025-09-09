import SwiftUI

struct AppWithBottomPlayer: View {
    @ObservedObject private var rotationEngine = WallpaperRotationEngine.shared
    private let logger = ArtWallLogger.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Main app content
            ContentView()
                .frame(width: 1000, height: 800)
            
            // Bottom player (only show when rotation is active)
            if rotationEngine.isRotating {
                BottomPlayerView()
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = ArtWallLogger.shared
    static var shared: AppDelegate?
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("AppDelegate: Application finished launching", category: .app)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Choice 3A: Hide to background when window closes (don't quit)
        logger.info("Main window closed - entering background mode", category: .app)
        
        // Choice 2A: Hide Dock icon when entering background mode
        NSApp.setActivationPolicy(.accessory)
        logger.info("Dock icon hidden - app now in background mode", category: .app)
        
        return false // Don't quit, keep running in background
    }
    
    func showMainWindow() {
        logger.info("Showing main window - exiting background mode", category: .app)
        
        // Choice 2A: Show Dock icon when main window opens
        NSApp.setActivationPolicy(.regular)
        logger.info("Dock icon restored - app now in foreground mode", category: .app)
        
        // Bring app to front and activate
        NSApp.activate(ignoringOtherApps: true)
        
        // Try to find existing window first
        for window in NSApp.windows {
            if window.contentViewController != nil {
                window.makeKeyAndOrderFront(nil)
                logger.success("Existing main window restored and brought to front", category: .app)
                return
            }
        }
        
        // If no window exists, we need to create one
        // This will be handled by the WindowGroup with the openWindow environment
        logger.info("No existing window found - will create new one", category: .app)
    }
}

struct ArtWallApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Configure URL cache for better image caching
        let cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
        URLCache.shared = cache
        
        // Initialize logging and run system tests
        let logger = ArtWallLogger.shared
        logger.info("🚀 ArtWall starting up...", category: .app)
        
        // Clean up old log files
        logger.cleanupOldLogs()
        
        // Run system tests in background
        Task {
            await AppTester.quickHealthCheck()
        }
    }
    
    var body: some Scene {
        WindowGroup("ArtWall", id: "main") {
            AppWithBottomPlayer()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 800) // Force even shorter height
        .windowToolbarStyle(.unifiedCompact)
        
        // NEW: Menu Bar Extra for system-wide wallpaper control
        MenuBarExtra("🎨") {
            CompactMenuBarPlayerView()
        }
        .menuBarExtraStyle(.window) // Allows sheets to present properly
    }
}

// Entry point
ArtWallApp.main()
