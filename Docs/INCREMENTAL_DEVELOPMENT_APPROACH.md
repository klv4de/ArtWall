# ArtWall - Incremental Development Approach

**Date**: January 21, 2025  
**Status**: MANDATORY - All Development Must Follow This Approach

## 🎯 **Core Development Philosophy**

### **Test at Every Turn**
- **No large changes** without immediate testing and verification
- **Build incrementally** - one small component at a time
- **Verify each step** works before proceeding to the next
- **Comprehensive logging** to track every operation

### **Modular Implementation**
- **Single responsibility** - each component does one thing well
- **Independent testing** - each module can be tested in isolation
- **Clear interfaces** - well-defined boundaries between components
- **Graceful degradation** - components fail safely without breaking the whole system

## 🏗️ **Custom Wallpaper Engine Implementation Plan**

### **Phase 1: Core Timer Engine (1-2 hours)**

#### **Step 1.1: Basic Timer Implementation**
```swift
class ArtWallWallpaperEngine: ObservableObject {
    private var timer: Timer?
    private var images: [URL] = []
    private var currentIndex = 0
    private let logger = ArtWallLogger.shared
    
    func startRotation(images: [URL], interval: TimeInterval = 1800) {
        self.images = images
        logger.info("Starting wallpaper rotation with \(images.count) images", category: .wallpaper)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.rotateToNext()
        }
    }
}
```

**Test Criteria:**
- [ ] Timer starts successfully
- [ ] Timer fires at correct intervals (test with 5-second interval)
- [ ] Logging shows timer events
- [ ] Timer can be stopped/started

#### **Step 1.2: Image Rotation Logic**
```swift
private func rotateToNext() {
    guard !images.isEmpty else { return }
    
    let nextImage = images[currentIndex]
    logger.info("Rotating to image \(currentIndex + 1)/\(images.count): \(nextImage.lastPathComponent)", category: .wallpaper)
    
    setWallpaper(url: nextImage)
    currentIndex = (currentIndex + 1) % images.count
}
```

**Test Criteria:**
- [ ] Index rotation works correctly (0, 1, 2, 0, 1, 2...)
- [ ] Image URLs are valid and accessible
- [ ] Logging shows each rotation attempt
- [ ] Handles empty image arrays gracefully

#### **Step 1.3: Individual Wallpaper Setting**
```swift
private func setWallpaper(url: URL) {
    do {
        try NSWorkspace.shared.setDesktopImageURL(url, for: NSScreen.main!, options: [:])
        logger.success("Wallpaper set successfully: \(url.lastPathComponent)", category: .wallpaper)
    } catch {
        logger.error("Failed to set wallpaper", error: error, category: .wallpaper)
    }
}
```

**Test Criteria:**
- [ ] Individual wallpaper setting works (we know this works)
- [ ] Error handling for invalid URLs
- [ ] Logging shows success/failure for each attempt
- [ ] No hanging or freezing

### **Phase 2: Background Service Integration (1 hour)**

#### **Step 2.1: App Delegate Configuration**
```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure as background app
        NSApp.setActivationPolicy(.accessory)
        logger.info("ArtWall configured as background service", category: .app)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in background
    }
}
```

**Test Criteria:**
- [ ] App runs without showing in Dock
- [ ] App continues running when main window closes
- [ ] Background service starts correctly
- [ ] Logging confirms background mode activation

#### **Step 2.2: Service Lifecycle Management**
```swift
class WallpaperService: ObservableObject {
    @Published var isRunning = false
    @Published var currentCollection: String?
    private let engine = ArtWallWallpaperEngine()
    
    func startRotation(collectionName: String, images: [URL]) {
        currentCollection = collectionName
        engine.startRotation(images: images)
        isRunning = true
        logger.info("Wallpaper service started for collection: \(collectionName)", category: .wallpaper)
    }
}
```

**Test Criteria:**
- [ ] Service can be started and stopped
- [ ] State management works correctly (@Published properties)
- [ ] Multiple start/stop cycles work without issues
- [ ] Logging tracks service lifecycle

### **Phase 3: Menu Bar Interface (1-2 hours)**

#### **Step 3.1: Basic Menu Bar Presence**
```swift
@main
struct ArtWallMenuApp: App {
    var body: some Scene {
        MenuBarExtra("🎨", systemImage: "paintbrush") {
            VStack {
                Text("ArtWall")
                    .font(.headline)
                Divider()
                Text("No collection active")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
```

**Test Criteria:**
- [ ] Menu bar icon appears
- [ ] Menu opens when clicked
- [ ] Basic content displays correctly
- [ ] Menu closes properly

#### **Step 3.2: Dynamic Status Display**
```swift
struct MenuBarContent: View {
    @ObservedObject var service: WallpaperService
    
    var body: some View {
        VStack(alignment: .leading) {
            if service.isRunning {
                Text("✅ \(service.currentCollection ?? "Unknown")")
                Text("Next change: \(timeUntilNext)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("⏸️ Rotation Paused")
            }
        }
    }
}
```

**Test Criteria:**
- [ ] Status updates dynamically
- [ ] Timer countdown displays correctly
- [ ] Collection name shows properly
- [ ] Pause/resume state reflects accurately

#### **Step 3.3: Control Actions**
```swift
struct MenuBarControls: View {
    @ObservedObject var service: WallpaperService
    
    var body: some View {
        VStack {
            if service.isRunning {
                Button("⏸️ Pause Rotation") {
                    service.pauseRotation()
                }
            } else {
                Button("▶️ Resume Rotation") {
                    service.resumeRotation()
                }
            }
            
            Divider()
            
            Button("⚙️ Open ArtWall") {
                openMainApp()
            }
            
            Button("❌ Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
```

**Test Criteria:**
- [ ] Pause/resume buttons work correctly
- [ ] Main app opens when requested
- [ ] Quit functionality works properly
- [ ] Button states update correctly

### **Phase 4: Integration with Existing App (30 minutes)**

#### **Step 4.1: Update Apply Collection Button**
```swift
// In CollectionDetailsView.swift
Button("Apply this collection") {
    Task {
        await downloadImages()
        WallpaperService.shared.startRotation(
            collectionName: collection.title,
            images: downloadedImageURLs
        )
    }
}
```

**Test Criteria:**
- [ ] Download process works as before
- [ ] Wallpaper service starts after download completes
- [ ] UI updates to show service status
- [ ] Error handling for failed downloads

#### **Step 4.2: Remove Broken System Integration**
```swift
// Remove from WallpaperService.swift:
// - UserDefaults folder configuration
// - AppleScript folder rotation attempts
// - System Settings integration

// Keep only:
// - Individual image setting (for immediate preview)
// - Directory creation and management
```

**Test Criteria:**
- [ ] No more hanging on broken APIs
- [ ] Cleaner, simpler codebase
- [ ] Faster "Apply this collection" operation
- [ ] No system permission issues

## 🧪 **Testing Strategy**

### **Unit Testing Approach**
```swift
// Add to AppTester.swift
func testWallpaperEngine() -> Bool {
    logger.debug("Testing WallpaperEngine functionality...", category: .app)
    
    do {
        let engine = ArtWallWallpaperEngine()
        let testImages = getTestImageURLs()
        
        // Test timer creation
        engine.startRotation(images: testImages, interval: 5.0) // 5 second test
        
        // Wait and verify
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            engine.stopRotation()
            self.logger.success("✅ WallpaperEngine test completed", category: .app)
        }
        
        return true
    } catch {
        logger.error("❌ WallpaperEngine test failed", error: error, category: .app)
        return false
    }
}
```

### **Integration Testing**
- Test complete flow: Collection selection → Download → Rotation start
- Verify menu bar updates reflect service state
- Test pause/resume functionality
- Verify background service persistence

### **User Acceptance Testing**
- Download a collection and verify rotation starts
- Check menu bar shows correct status
- Test pause/resume from menu bar
- Verify rotation continues after app restart

## 📊 **Success Metrics**

### **Phase 1 Success**
- [ ] Timer-based rotation working with test images
- [ ] Individual wallpaper setting reliable
- [ ] Comprehensive logging of all operations
- [ ] No hanging or freezing

### **Phase 2 Success**
- [ ] Background service runs invisibly
- [ ] Service persists when main window closes
- [ ] Proper lifecycle management
- [ ] Resource usage minimal (<20MB memory)

### **Phase 3 Success**
- [ ] Menu bar interface functional and responsive
- [ ] Dynamic status updates working
- [ ] Control actions (pause/resume) working
- [ ] Professional look and feel

### **Phase 4 Success**
- [ ] Integration with existing app seamless
- [ ] "Apply this collection" button works end-to-end
- [ ] No broken system API calls
- [ ] User experience improved (faster, more reliable)

## 🚨 **Rollback Strategy**

### **If Phase Fails**
- **Immediate rollback** to previous working state
- **Analyze logs** to understand failure
- **Adjust approach** based on findings
- **Re-test** smaller increment

### **Fallback Options**
- **Phase 1 Failure**: Keep existing individual wallpaper setting, add manual "next image" button
- **Phase 2 Failure**: Run as regular app instead of background service
- **Phase 3 Failure**: Use main app interface instead of menu bar
- **Phase 4 Failure**: Keep new engine separate from existing download flow

## 🎯 **Development Session Structure**

### **Each Development Session**
1. **Review previous progress** and current state
2. **Choose single phase/step** to implement
3. **Write code incrementally** (10-20 lines at a time)
4. **Test immediately** after each small change
5. **Log everything** for debugging visibility
6. **Document results** before proceeding

### **Never Do**
- Large code changes without testing
- Multiple phases simultaneously
- Skip logging implementation
- Ignore test failures
- Proceed without verification

---

## 📋 **Current Status & Next Steps**

**Last Updated**: September 9, 2025

### **✅ Completed**
- Core wallpaper rotation engine with timer-based switching
- Image download service with progress tracking
- **Menu bar integration with compact player view - FULLY FUNCTIONAL** 🎉
- Collection management system
- Comprehensive logging and testing framework
- **Complete menu bar functionality** (rotation controls, artwork display, navigation)
- **Main app artwork details UI fixes** (centered title, standardized buttons)
- **✅ SOLVED: Menu bar artwork details sizing issue** - Implemented separate NSWindow approach
- **✅ SOLVED: Menu bar UI overlap** - Auto-dismiss menu bar popover when artwork details window opens

### **✅ Completed (Phase 2F - September 9, 2025)**
- Core wallpaper rotation engine with timer-based switching
- Image download service with progress tracking
- **Menu bar integration with compact player view - FULLY FUNCTIONAL** 🎉
- Collection management system
- Comprehensive logging and testing framework
- **Complete menu bar functionality** (rotation controls, artwork display, navigation)
- **Main app artwork details UI fixes** (centered title, standardized buttons)
- **✅ SOLVED: Menu bar artwork details sizing issue** - Implemented separate NSWindow approach
- **✅ SOLVED: Menu bar UI overlap** - Auto-dismiss menu bar popover when artwork details window opens
- **✅ COMPLETED: Background app configuration** - Professional utility app with dynamic Dock behavior

### **🔄 Current Focus (Phase 3A)**
- **IMMEDIATE NEXT**: Collection expansion using complete Chicago Art Institute database (803 European paintings)

### **📅 Next Priority Phases**
- **Phase 3A**: Collection expansion (15-20 comprehensive collections)
- **Phase 3B**: Distribution preparation (app signing, installer, documentation)
- **Phase 3C**: Public launch (feature-complete MVP)

### **🎉 Recent Achievements (Sep 9, 2025)**
**✅ Background App Configuration - COMPLETELY IMPLEMENTED**
- **Challenge**: Transform ArtWall into professional utility app while maintaining functionality
- **Solution Implemented**: 
  - Hybrid launch behavior (starts with main window, transitions to background when closed)
  - Dynamic Dock icon management (shows/hides based on window state)
  - SwiftUI WindowGroup integration with proper window restoration
  - Menu bar "Open ArtWall" functionality with `@Environment(\.openWindow)`
- **Result**: Professional utility app experience with seamless background operation

**✅ Menu Bar Artwork Details - COMPLETELY SOLVED**
- **Problem**: Menu bar artwork details appeared in tiny constrained window
- **Root Cause**: MenuBarExtraStyle.window popover size constraints
- **Solution Implemented**: 
  - Created `ArtworkDetailWindowController` with dedicated NSWindow (800x900)
  - Auto-dismiss menu bar popover to prevent overlap
  - Positioned near menu bar in upper-right area
  - Identical UI experience to main app artwork details
- **Result**: Professional, full-size artwork details accessible from menu bar

---

**This incremental approach ensures we build a reliable, well-tested custom wallpaper engine while minimizing risk and maximizing our ability to debug issues quickly.**
