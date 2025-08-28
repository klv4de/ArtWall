# ArtWall - Tech Stack & Architecture Decisions

**Date**: January 21, 2025  
**Status**: FINAL - Ready for Implementation

## ✅ **Confirmed Technology Stack**

### **Core Technologies**
- **Language**: Swift + SwiftUI
- **Platform**: Native macOS application (macOS Sonoma 14.0+ required)
- **Development**: Xcode (free)
- **Tested on**: macOS Sequoia 15.6.1
- **Multi-Monitor**: ✅ FULL SUPPORT (using macos-wallpaper Swift package)
- **Total Cost**: $0

### **Why Swift/SwiftUI**
1. **$0 Cost** - No licensing fees, Xcode free
2. **Native Performance** - Direct macOS API access for wallpaper management
3. **Professional Result** - Industry-standard development
4. **Future-Proof** - Easy to hire Swift developers later
5. **Windows Path Exists** - Swift runs on Windows, or port core logic to C#/.NET

### **Image Download Strategy**
**Decision**: Use GitHub-hosted images instead of Chicago Art Institute API
- **Reliability** - GitHub CDN is more stable than museum API
- **Performance** - Images already optimized and cached
- **$0 Cost** - No API rate limits or bandwidth costs
- **Offline Capability** - Images remain available even if museum API changes
- **Quality Control** - We've already curated high-quality versions

## 🎨 **Design System & UI Standards**

### **Core Design Principles**
1. **Component Consistency** - All UI elements must follow a unified design system
2. **Reusable Components** - Create shared components to ensure consistency
3. **Visual Hierarchy** - Clear typography, spacing, and color standards
4. **Responsive Design** - Scaleable UI with intelligent breakpoints
5. **Accessibility First** - Ensure all interactions are accessible and intuitive

### **Button Standards**
- **Primary Actions**: `.font(.headline)` + `.foregroundColor(.blue)`
- **Secondary Actions**: Match primary styling for consistency
- **Consistent Sizing**: Use standard control sizes across the app
- **Symmetrical Layout**: Balance visual weight in headers and navigation

### **Typography Scale**
- **Page Titles**: `.font(.title2)` + `.fontWeight(.semibold)`
- **Section Headers**: `.font(.headline)`
- **Body Text**: `.font(.subheadline)`
- **Captions**: `.font(.caption)` + `.foregroundColor(.secondary)`

### **Color Palette**
- **Primary Action**: `.blue` (system blue)
- **Secondary Text**: `.secondary` (system secondary)
- **Background**: `Color(NSColor.windowBackgroundColor)`
- **Cards**: `Color(NSColor.controlBackgroundColor)`

### **Spacing Standards**
- **Page Margins**: `.padding(.horizontal, 20)`
- **Section Spacing**: `.padding(.vertical, 16)`
- **Card Padding**: `.padding(16)`
- **Grid Spacing**: `spacing: 20` for major grids

## 🔍 **Logging & Testing Infrastructure**

### **Comprehensive Observability System**
**Decision**: Implement enterprise-grade logging and testing infrastructure
- **ArtWallLogger**: Structured logging with 8 categories and 6 severity levels
- **File Logging**: `~/Library/Logs/ArtWall/artwall-YYYY-MM-DD.log` with 7-day retention
- **Process Tracking**: Automatic timing and success/failure tracking for all major operations
- **Console Integration**: Native macOS Console.app support with searchable logs

### **Automated Testing Framework**
**Decision**: Build comprehensive system validation and component testing
- **AppTester**: Automated health checks on app startup
- **System Tests**: File system, network, macOS compatibility, screen detection, UserDefaults
- **Component Tests**: Collections, wallpaper API, download operations
- **Non-Destructive**: All tests safe to run in production environment

### **Error Recovery & Resilience**
**Decision**: Implement robust error handling with graceful degradation
- **Timeout Protection**: 5-10 second wallpaper API timeouts prevent freezing (multi-monitor issue identified)
- **Partial Failure Tolerance**: Continue downloads even if 25% fail
- **Fallback Mechanisms**: Hardcoded manifests if bundle loading fails
- **User-Friendly Errors**: Clear error messages with actionable guidance

### **Why This Infrastructure?**
1. **Debugging Efficiency** - Complete visibility into all operations
2. **Reliability** - Proactive issue detection and graceful failure handling
3. **User Support** - Detailed logs for troubleshooting user issues
4. **Development Speed** - Rapid identification of issues during development
5. **Production Confidence** - Comprehensive testing validates system health

## 🏗️ **Architecture Decisions**

### **Hybrid Hosting Strategy**
- **Collection Metadata**: GitHub repository (JSON files, version controlled)
- **Full Images**: Museum APIs (Chicago Art Institute, Met, etc.)
- **App Distribution**: GitHub Releases (.dmg files)
- **Website**: GitHub Pages (landing page, downloads)

### **Collection System**
```
GitHub Repository (Free)
├── collections/
│   ├── monet_water_lilies.json      # Curated collections
│   ├── impressionists.json          # Metadata only (~1-50KB each)
│   └── collections_index.json       # Master collection list
├── ArtWallApp/                      # Swift/SwiftUI app
└── docs/                           # GitHub Pages website
```

## 📦 **Distribution Strategy**

### **Direct Download (No App Store Required)**
1. User visits GitHub Pages website
2. Downloads .dmg file from GitHub Releases
3. Installs by dragging to Applications folder
4. App downloads collections + images directly from APIs

### **Benefits**
- **$0 cost** (no Apple Developer account needed initially)
- **Fast deployment** (no App Store review process)
- **Full control** over updates and feature releases

## 🎨 **Collection Architecture**

### **Planned Collection Types**
- **Artist-Focused**: Monet Water Lilies, Van Gogh Masterpieces
- **Style-Based**: Impressionists, Post-Impressionists, Renaissance Masters
- **Museum-Based**: Chicago European Paintings, Met Highlights
- **Themed**: Landscapes, Portraits, Still Life

### **Collection Workflow**
1. **Curation**: Use existing Python scripts to discover great artworks
2. **JSON Generation**: Create collection metadata files
3. **Version Control**: Commit collections to GitHub repository
4. **App Sync**: App downloads updated collections automatically

## 🚀 **Implementation Plan**

### **Phase 1: Core App (1-2 weeks)**
1. Create Xcode project in `ArtWallApp/` directory
2. Build collection browser UI (SwiftUI)
3. Implement JSON collection loading from GitHub
4. Add image download from museum APIs
5. Integrate native macOS wallpaper configuration

### **Phase 2: Collections & Distribution (1 week)**
1. Create 5 starter collections using existing Python work
2. Set up GitHub Pages website
3. Configure app signing & .dmg distribution
4. Add collection management features to app

## 💰 **Cost Analysis**
- **Development Tools**: $0 (Xcode free)
- **Hosting**: $0 (GitHub Pages + Releases)
- **Collection Storage**: $0 (tiny JSON files)
- **Image Hosting**: $0 (museums serve images via their APIs)
- **Distribution**: $0 (direct download)
- **Optional Custom Domain**: ~$10/year

**Total: $0-10/year** 🎉

## 🎯 **Immediate Next Steps**
1. **Create Xcode project** in `ArtWallApp/` directory
2. **Port Chicago Art API logic** from Python to Swift
3. **Design collection browser** UI mockups
4. **Create first collection JSON** from existing 48-image European collection

---

## 🚧 **Current Status & Strategic Pivot** (January 21, 2025)

### **🔍 RESEARCH BREAKTHROUGH: System Bug Identification**

**Problem Solved**: Wallpaper rotation issues are **macOS Sequoia system bugs**, not our implementation.

**Key Findings from Research**:
- Photos album rotation broken system-wide since macOS Ventura
- Folder rotation inconsistent even with local folders
- AppleScript System Events API broken in recent macOS versions
- iCloud photo access fails for wallpaper rotation
- **Root Cause**: Apple broke wallpaper APIs, affecting all apps and users

**Strategic Decision**: Stop fighting broken system APIs, build custom solution.

### **✅ COMPLETED FOUNDATION**
- Enterprise logging and testing infrastructure (100% complete)
- Download functionality (working perfectly - 24/24 images)
- Individual wallpaper setting (NSWorkspace API working)
- Development standards and documentation
- **Research Phase**: Complete analysis of macOS wallpaper system bugs

### **✅ RESOLVED: Multi-Monitor Wallpaper API Issue (August 26, 2025)**

**Problem Solved**: NSWorkspace API hanging completely fixed with hybrid approach!

**Technical Solution:**
```swift
// Working Hybrid Architecture
1. UserDefaults Method:
   - Sets folder rotation (30-minute intervals)
   - Configures scaling preferences  
   - No API hanging issues
   
2. AppleScript Method:
   - Sets immediate wallpaper image
   - Simple, reliable syntax
   - Works on all screen types

3. Comprehensive Logging:
   - Complete visibility into operations
   - Debug any future issues
   - Process tracking with timing
```

**What Doesn't Work in macOS Sequoia:**
- `NSWorkspace.setDesktopImageURL()` - hangs on external monitors
- AppleScript folder rotation syntax - not supported
- Complex AppleScript scaling commands - syntax errors

**What Works Perfectly:**
- Simple AppleScript image setting - no hanging
- Main screen targeting - avoids multi-monitor issues
- Progress dialog completion - no more hanging
- Comprehensive logging - complete visibility

**What Doesn't Work Yet:**
- UserDefaults folder configuration - folder not appearing in System Settings
- Folder rotation - only single image shows, no 30-minute switching
- System integration - collections not recognized by macOS wallpaper system

### **🚀 STRATEGIC PIVOT: Custom Wallpaper Engine (January 2025)**

**RESEARCH COMPLETE**: macOS Sequoia wallpaper rotation is broken system-wide due to Apple bugs.

**NEW APPROACH**: Build custom wallpaper rotation engine instead of fighting broken APIs.

#### **Custom Engine Architecture**
```swift
// Timer-based rotation using working NSWorkspace API
class ArtWallWallpaperEngine {
    private var timer: Timer?
    private var images: [URL] = []
    
    func startRotation(interval: TimeInterval = 1800) { // 30 minutes
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.rotateToNext()
        }
    }
}
```

#### **Hybrid App Model**
1. **Main App**: Collection browsing, configuration (SwiftUI)
2. **Background Service**: Invisible wallpaper rotation (Launch Agent)
3. **Menu Bar Control**: Quick access to rotation controls

#### **Development Approach: Incremental Testing**
- **Test at every step** - no large changes without verification
- **Modular implementation** - build and test each component separately
- **Comprehensive logging** - full visibility into all operations
- **Fallback mechanisms** - graceful degradation if components fail

### **🎯 UPDATED TECHNICAL PRIORITIES**
1. **Build Custom WallpaperEngine** - Timer-based rotation (2-3 hours estimated)
2. **Add Menu Bar Interface** - Control rotation from menu bar
3. **Configure Background Service** - Launch Agent registration
4. **Test Incremental Components** - Verify each piece works before proceeding
5. **Content Expansion**: Build more collections (after rotation engine works)

### **🎉 BREAKTHROUGH: Wallpaper Management Solution (January 28, 2025)**
**Decision**: Use `macos-wallpaper` Swift package by Sindre Sorhus
- **Problem Solved**: Wallpaper scaling and multi-monitor support
- **Replaces**: Failed attempts with NSWorkspace, AppleScript, and desktoppr
- **Features**: 
  - ✅ "Fit to screen" scaling with black background fill
  - ✅ Multi-monitor support (all screens simultaneously)
  - ✅ Native Swift integration (no shell commands)
  - ✅ Reliable on macOS 15.6+
- **Implementation**: `Wallpaper.set(imageURL, screen: .all, scale: .fit, fillColor: .black)`
- **Status**: ✅ WORKING - Successfully tested on dual monitor setup

**✅ Core wallpaper automation: SOLVED with native Swift package**
