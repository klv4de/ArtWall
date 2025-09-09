import SwiftUI
import AppKit

/// Dedicated window controller for displaying artwork details from menu bar
/// Bypasses MenuBarExtra popover size constraints by creating independent NSWindow
class ArtworkDetailWindowController: NSWindowController {
    private let logger = ArtWallLogger.shared
    private static var sharedController: ArtworkDetailWindowController?
    
    /// Show artwork details in dedicated window positioned near menu bar
    static func showArtworkDetails(for artwork: Artwork) {
        let logger = ArtWallLogger.shared
        logger.info("Opening dedicated artwork details window for: \(artwork.title)", category: .ui)
        
        // Close existing window if open
        sharedController?.close()
        
        // Dismiss menu bar popover to avoid overlap
        dismissMenuBarPopover()
        
        // Create new window controller
        let controller = ArtworkDetailWindowController(artwork: artwork)
        sharedController = controller
        
        // Show window
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        
        logger.success("Artwork details window opened successfully", category: .ui)
    }
    
    /// Dismiss the menu bar popover to provide clean window presentation
    private static func dismissMenuBarPopover() {
        // Find and dismiss any open menu bar popover
        for window in NSApplication.shared.windows {
            if window.className.contains("MenuBarExtra") || window.className.contains("Popover") {
                window.orderOut(nil)
                ArtWallLogger.shared.debug("Dismissed menu bar popover for clean artwork details presentation", category: .ui)
                break
            }
        }
    }
    
    private init(artwork: Artwork) {
        // Create the SwiftUI content view - identical to main app
        let contentView = ArtworkDetailView(artwork: artwork)
        let hostingView = NSHostingView(rootView: contentView)
        
        // Create window with appropriate size (matching main app modal)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 900),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        // Configure window properties
        window.title = "Artwork Details"
        window.contentView = hostingView
        window.isReleasedWhenClosed = false
        window.center() // Center on screen initially
        
        // Position near menu bar if possible
        Self.positionNearMenuBar(window: window)
        
        super.init(window: window)
        
        logger.debug("Created artwork details window: \(artwork.title)", category: .ui)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Position window near menu bar icon if possible
    private static func positionNearMenuBar(window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        
        // Get menu bar height (typically 24 points) - for future positioning enhancements
        let _: CGFloat = 24
        
        // Position window in upper right area, below menu bar
        let windowFrame = window.frame
        let screenFrame = screen.visibleFrame
        
        let x = screenFrame.maxX - windowFrame.width - 20 // 20pt margin from right edge
        let y = screenFrame.maxY - windowFrame.height - 10 // 10pt below menu bar
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
        
        ArtWallLogger.shared.debug("Positioned artwork details window near menu bar", category: .ui)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Ensure window closes properly without affecting app
        window?.delegate = self
    }
}

// MARK: - NSWindowDelegate
extension ArtworkDetailWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        logger.info("Artwork details window closing", category: .ui)
        
        // Clear shared reference when window closes
        if ArtworkDetailWindowController.sharedController === self {
            ArtworkDetailWindowController.sharedController = nil
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Always allow window to close - don't affect app lifecycle
        return true
    }
}
