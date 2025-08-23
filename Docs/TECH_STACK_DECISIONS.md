# ArtWall - Tech Stack & Architecture Decisions

**Date**: January 21, 2025  
**Status**: FINAL - Ready for Implementation

## ✅ **Confirmed Technology Stack**

### **Core Technologies**
- **Language**: Swift + SwiftUI
- **Platform**: Native macOS application
- **Development**: Xcode (free)
- **Total Cost**: $0

### **Why Swift/SwiftUI**
1. **$0 Cost** - No licensing fees, Xcode free
2. **Native Performance** - Direct macOS API access for wallpaper management
3. **Professional Result** - Industry-standard development
4. **Future-Proof** - Easy to hire Swift developers later
5. **Windows Path Exists** - Swift runs on Windows, or port core logic to C#/.NET

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

**✅ All major technical decisions finalized - ready to begin Swift development!**
