import SwiftUI

struct ArtWallApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
    }
}

// Entry point
ArtWallApp.main()
