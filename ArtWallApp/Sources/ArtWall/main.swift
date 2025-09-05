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

struct ArtWallApp: App {
    
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
        WindowGroup {
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
