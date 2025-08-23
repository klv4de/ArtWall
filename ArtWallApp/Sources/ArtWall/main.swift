import SwiftUI

struct ArtWallApp: App {
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
