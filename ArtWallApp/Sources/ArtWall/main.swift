import SwiftUI

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
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}

// Entry point
ArtWallApp.main()
