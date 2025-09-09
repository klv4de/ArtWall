# ArtWall - Product Requirements Document

## Overview

ArtWall is a macOS application that automatically fetches fine art from museum APIs and sets them as rotating desktop wallpapers, bringing world-class art to your daily computing experience.

## Core Objectives

- **Effortless Art Discovery**: Automatically source high-quality fine art from reputable museums
- **Seamless Integration**: Work natively with macOS wallpaper rotation system
- **Legal & Ethical**: Only use public domain or properly licensed artwork
- **Beautiful Experience**: Curate visually stunning, high-resolution images optimized for desktop display

## Tech Stack

### Current (MVP - COMPLETED)
- **Language**: Swift + SwiftUI
- **Platform**: Native macOS application
- **Database**: SQLite with 134,078 artworks and complete metadata
- **Collections**: 8 curated historical period collections (267 artworks)
- **APIs**: Chicago Art Institute API for high-resolution images
- **Architecture**: JSON-driven, bundle resources, production-ready
- **Cost**: $0 - Completely local operation

### Future Professional Stack
- **Packaging**: PyInstaller for standalone executables, proper setup.py/pyproject.toml
- **GUI Framework**: Electron, PyQt, or native Swift/SwiftUI for consumer applications
- **Backend**: FastAPI or Flask for web services (if needed)
- **Database**: SQLite for local metadata, PostgreSQL for cloud services
- **CI/CD**: GitHub Actions for automated testing and releases
- **Distribution**: App stores, package managers, professional installers

## MVP Features

### ✅ Phase 1: Collection Browsing (COMPLETED)
- **Native SwiftUI App**: Professional 4-page navigation (Welcome → Collections → Details → Artwork)
- **8 Curated Collections**: Historical periods from Medieval to 1890s Golden Age
- **267 High-Quality Artworks**: Museum masterpieces with full metadata
- **Instant Loading**: JSON-driven architecture with bundle resources
- **Optimized Performance**: 79% code reduction, production-ready file paths

### 🎉 Phase 2: Wallpaper Integration (STRATEGIC PIVOT - January 2025)

#### **STRATEGIC DECISION: Custom Wallpaper Engine** 🚀 NEW APPROACH
- ✅ **Research Complete**: Identified macOS Sequoia system bugs affecting wallpaper rotation
- ✅ **Root Cause**: Photos album rotation, folder rotation, and AppleScript APIs broken system-wide
- 🎯 **Solution**: Build custom wallpaper rotation engine instead of fighting broken system APIs
- ⚡ **Implementation**: Timer-based rotation using working NSWorkspace individual image setting
- 🔄 **Hybrid Architecture**: Background service + menu bar control + main app UI

#### **Core Wallpaper Functionality** ✅ COMPLETE
- ✅ **"Apply this collection" Button**: One-click wallpaper setup on Collection Details page
- ✅ **Automatic Download**: Save collection images to `~/Pictures/ArtWall/[Collection Name]/`
- ✅ **Progress Tracking**: Real-time download progress with cancel option
- ✅ **Error Handling**: Graceful failure recovery and user feedback
- ✅ **Custom Engine**: Replace broken system integration with reliable custom solution
- ✅ **Menu Bar Integration**: System-wide wallpaper control with compact player interface
- ✅ **Menu Bar Artwork Details**: Full-size artwork details via dedicated NSWindow (September 2025)

#### **User Experience Flow** (Updated with Custom Engine)
1. User browses collections in app
2. User views Collection Details page with all artworks
3. User clicks **"Apply this collection"** button
4. App downloads all images to dedicated folder
5. **NEW**: App starts custom wallpaper rotation engine (background service)
6. **NEW**: Menu bar icon provides rotation control (pause/resume/change collection)
7. User enjoys rotating fine art wallpapers automatically every 30 minutes

#### **Technical Implementation** (Custom Wallpaper Engine)
- **Image Management**: Download and organize collection images locally
- **Custom Rotation Engine**: Timer-based wallpaper changes using working NSWorkspace API
- **Background Service**: Runs invisibly with Launch Agent registration
- **Menu Bar Control**: Quick access to pause/resume/change collections
- **Hybrid App Model**: Main app for browsing + background service for rotation
- **Permission Handling**: Standard macOS app permissions (no complex Accessibility requirements)
- **Error Handling**: Graceful fallbacks with comprehensive logging
- **Progress Feedback**: Show download/setup progress to user

### 🏗️ Phase 2.5: Enterprise Infrastructure (✅ COMPLETED - January 2025)

#### **Logging & Observability System** ✅ IMPLEMENTED
- ✅ **Comprehensive Logging**: 100% coverage across all major processes
- ✅ **Structured Categories**: 8 specialized logging categories (App, Collections, Download, Wallpaper, UI, Network, FileSystem, Error)
- ✅ **Process Tracking**: Automatic timing and success/failure tracking
- ✅ **File Logging**: Persistent logs in `~/Library/Logs/ArtWall/` with 7-day retention
- ✅ **Console Integration**: Native macOS Console.app support

#### **Automated Testing Framework** ✅ IMPLEMENTED
- ✅ **System Health Checks**: Automated testing on app startup
- ✅ **Component Validation**: File system, network, macOS compatibility, screen detection, UserDefaults
- ✅ **Non-Destructive Testing**: Safe to run in production environment
- ✅ **Diagnostic Reporting**: Clear pass/fail results with detailed error information

#### **Robust Error Handling** ✅ IMPLEMENTED
- ✅ **Timeout Protection**: 5-10 second timeouts prevent UI freezing
- ✅ **Partial Failure Tolerance**: Continue operations with 75%+ success rate
- ✅ **Graceful Fallbacks**: Alternative approaches when primary methods fail
- ✅ **User-Friendly Errors**: Clear error messages with actionable guidance

#### **Development Standards** ✅ ESTABLISHED
- ✅ **Mandatory Logging**: All new features must include comprehensive logging
- ✅ **Mandatory Testing**: All new components must include automated tests
- ✅ **Zero Compilation Tolerance**: Immediate fixing of compilation errors required
- ✅ **Complete Documentation**: All changes must update relevant documentation

### 🎨 Phase 2B: Collection Expansion (PRE-DISTRIBUTION)

#### **Content Maximization Strategy**
- **Goal**: Utilize most/all suitable Chicago Art Institute paintings before MVP distribution
- **Current**: 8 collections, 267 artworks (historical periods focus)
- **Target**: Comprehensive coverage using existing database of 803 European oil paintings

#### **Expansion Categories**
1. **Artist Collections**: Monet (47 works), Renoir (23), Degas (19), Cézanne (15), Van Gogh, Toulouse-Lautrec
2. **Style Collections**: Impressionist Masters, Post-Impressionist, Baroque, Dutch Golden Age
3. **Theme Collections**: Landscapes, Portraits, Still Life, Religious Art, Classical Mythology

#### **Distribution Readiness**
- **Phase 2A**: Wallpaper automation functionality ✅ COMPLETED
- **Phase 2B**: Comprehensive collections (maximize content)
- **Phase 2E**: Artwork descriptions and educational content ✅ COMPLETED
- **Phase 2F**: Menu bar artwork details & background app configuration ✅ MENU BAR DETAILS COMPLETED
- **Phase 3**: Package and distribute feature-complete MVP

### 🎨 Phase 2E: Artwork Descriptions Feature (✅ COMPLETED - January 2025)

#### **Educational Content Integration** ✅ IMPLEMENTED
- ✅ **Rich Descriptions**: Museum-quality artwork descriptions from Chicago Art Institute database
- ✅ **Data Model Enhancement**: Extended `GitHubArtwork` model with `description` field and proper JSON decoding
- ✅ **UI Integration**: Enhanced `ArtworkDetailView` with "About this artwork" section and clean typography
- ✅ **Content Processing**: HTML parsing with tag removal and entity decoding for optimal readability
- ✅ **Quality Assurance**: Comprehensive testing across all 267 artworks with graceful handling

#### **User Experience Enhancement** ✅ IMPLEMENTED
- ✅ **Cultural Context**: Detailed historical background and artistic analysis for major artworks
- ✅ **Educational Value**: Transforms ArtWall from wallpaper tool into comprehensive art appreciation platform
- ✅ **Clean Interface**: Smart conditional display shows descriptions only when available
- ✅ **Professional Quality**: Content sourced directly from museum's comprehensive database

#### **Technical Implementation** ✅ COMPLETED
- ✅ **Data Pipeline Fix**: Resolved hardcoded `nil` values in `CollectionManager`
- ✅ **JSON Schema Update**: Extended collection files with comprehensive descriptions
- ✅ **HTML Processing**: Custom parsing function for clean text rendering
- ✅ **Automated Testing**: Added test coverage for description functionality

### 🎨 Phase 2F: Menu Bar Artwork Details & Background App (✅ MENU BAR DETAILS COMPLETED - September 2025)

#### **Menu Bar Artwork Details Enhancement** ✅ IMPLEMENTED
- ✅ **Problem Solved**: Menu bar artwork details appeared in tiny constrained window due to MenuBarExtra popover size constraints
- ✅ **Technical Solution**: Created `ArtworkDetailWindowController` with dedicated NSWindow (800x900 size)
- ✅ **User Experience**: Auto-dismiss menu bar popover to prevent UI overlap, smart positioning near menu bar
- ✅ **Professional Result**: Identical UI experience to main app artwork details, accessible from menu bar

#### **Background App Configuration** 🔄 READY FOR IMPLEMENTATION
- **Goal**: Transform ArtWall into professional background utility app
- **Implementation Plan**:
  - Hide from Dock by default (`NSApp.setActivationPolicy(.accessory)`)
  - Don't show main window on startup
  - Show main window + Dock icon only when "Open ArtWall" clicked from menu bar
  - Hide Dock icon when main window closes
- **Benefits**: Cleaner system integration, professional utility feel, identical functionality
- **User Experience**: Menu bar (🎨) as primary interface, main window available on demand

### 4. Collection Management (Updated MVP Scope)
- **MVP Target**: 24 high-quality images per collection for optimal browsing experience
- **Department-Based Selection**: Use Chicago Art Institute API for 100% success rates
- **Quality Over Quantity**: Focus on perfect wallpaper suitability vs. large collection
- **Collection Standard**: 24 masterpieces per collection with 4-image thumbnail previews
- **Future Expansion**: Can scale to multiple themed collections after MVP validation

## Major Art APIs Available

### Primary (MVP)
- **The Metropolitan Museum of Art API**
  - 406,000+ artworks
  - High-resolution images
  - Public domain (CC0) licensing
  - Rich metadata (title, artist, date, culture)
  - Free, no API key required

### Future Integration Candidates
- **Rijksmuseum API** (Netherlands)
  - 700,000+ objects
  - High-quality images
  - Public domain works available
  - Requires API key (free)

- **Art Institute of Chicago API**
  - 50,000+ artworks
  - CC0 licensed images
  - Rich metadata
  - Free, no API key required

- **Harvard Art Museums API**
  - 250,000+ objects
  - Some public domain works
  - Requires API key (free for non-commercial)

- **Smithsonian Institution API**
  - 11+ million records
  - Mixed licensing
  - Requires API key (free)

- **National Gallery of Art (Washington) API**
  - Open access images
  - High resolution available
  - No API key required

## Next Sprint: Native macOS Application

### 1. MVP Native App Development
**Priority**: Replace script-based approach with proper macOS application
- **Swift/SwiftUI Implementation**: Native macOS app with proper system integration
- **Direct Wallpaper API Access**: Use macOS frameworks instead of AppleScript UI automation
- **Automatic Collection Building**: Integrate existing Chicago Art Institute API functionality
- **One-Click Setup**: Complete automation from download to wallpaper rotation
- **Proper Permission Handling**: Standard macOS app permissions and entitlements

### 2. Complete Database Architecture (COMPLETED August 2025)
- ✅ **Complete Data Migration**: 134,078 artworks with ALL metadata in SQLite
- ✅ **Smart API Selection**: Chicago Art Institute API provides 100% success rate
- ✅ **Department Filtering**: All departments available for instant filtering
- ✅ **Advanced Query Capability**: Filter by any combination of 80+ fields
- ✅ **Offline Operation**: Zero API dependencies, instant local queries
- ✅ **Optimized Performance**: Indexed database for lightning-fast searches

## Potential Future Next Steps

### 1. Cross-Platform Support
- **Windows Integration**: Support Windows wallpaper system and registry management
- **Linux Support**: GNOME, KDE, and other desktop environment compatibility
- **Universal Packaging**: Single installer for all platforms

### 2. Consumer Product Development
- **GUI Application**: Beautiful, intuitive interface for non-technical users
- **One-Click Setup**: Automated wallpaper folder configuration
- **App Store Distribution**: macOS App Store, Microsoft Store, Linux package managers
- **Installer Package**: Simple `.dmg`/`.exe`/`.deb` installers

### 3. Automatic Wallpaper Configuration (REQUIRES NATIVE APP)
**Research Finding**: AppleScript UI automation is unreliable in macOS Sequoia+ due to System Settings changes
**Solution**: Native macOS application required for proper automation

- **Native App Approach**: Swift/SwiftUI app with direct macOS API access
- **Wallpaper Folder Setup**: Use macOS frameworks to configure wallpaper settings programmatically
- **Rotation Configuration**: Direct API calls to enable rotation and set intervals
- **Display Settings**: Native configuration of wallpaper scaling and display options
- **Multi-Monitor Support**: Proper multi-display detection and configuration
- **Permission Handling**: Standard macOS app permission model with proper entitlements

**Current MVP**: Manual wallpaper setup with clear instructions (script-based automation removed)

### 4. Enhanced Art APIs Integration
- **Multi-Museum Support**: Integrate all major museum APIs listed above
- **Smart Curation**: AI-powered selection based on user preferences
- **Regional Preferences**: Focus on specific museums or geographic regions
- **Art Movement Filtering**: Filter by artistic periods, styles, or movements

### 5. Visual Category Expansion
**Beyond Fine Art - Future Collections:**
- **Public Art**: Street art, murals, graffiti collections
- **Album Covers**: Classic vinyl, modern releases, genre-specific collections
- **Movie Content**: Vintage posters, iconic stills, international cinema
- **Nature Photography**: Landscapes, wildlife, macro photography (Unsplash API)
- **Architecture**: Modern buildings, historical structures, interior design
- **Fashion Photography**: Editorial shoots, runway, street style
- **Sports Photography**: Action shots, iconic sporting moments
- **Space/Astronomy**: NASA images, telescope photography, space art
- **Abstract Art**: Digital art, generative art, contemporary abstracts
- **Historical Photography**: Vintage photos, historical moments
- **Travel Photography**: Cities, cultures, landmarks worldwide

**Technical Implementation:**
- Each category requires different API integrations
- Unified filtering and curation pipeline across all categories
- User preference system for category selection and weighting

### 6. Rich Metadata Display
- **Artwork Information Overlay**: Display title, artist, and year on desktop
- **Wikipedia Integration**: Direct links to Wikipedia pages for artworks and artists
- **Museum Links**: Links back to original museum collection pages
- **Art History Context**: Brief descriptions and historical context

### 7. Advanced Features
- **Favorites System**: Save and prioritize preferred artworks
- **Custom Collections**: Create themed collections (Impressionism, Ancient Art, etc.)
- **Social Sharing**: Share favorite discoveries with friends
- **Learning Mode**: Educational information about art history and techniques
- **Calendar Integration**: Special collections for holidays or cultural events

### 8. Code Professionalization
- **Development Environment**: Virtual environments, proper dependency management
- **Code Quality**: Black formatting, flake8 linting, type hints with mypy
- **Testing Suite**: Comprehensive unit tests with pytest, integration tests
- **Documentation**: Sphinx documentation, code comments, API documentation
- **Version Management**: Semantic versioning, proper release management
- **Entry Points**: Professional CLI with `artwall` command instead of `python main.py`
- **Configuration**: YAML/TOML config files instead of hardcoded values
- **Logging**: Structured logging with configurable levels

### 9. Tech Stack Modernization
- **Package Management**: Move from pip to Poetry or pipenv for dependency management
- **Build System**: Modern Python packaging with pyproject.toml
- **Distribution**: Professional installers (.dmg, .exe, .deb) and package managers
- **Cross-Platform**: Refactor platform-specific code for Windows/Linux compatibility
- **Performance**: Async/await for concurrent API calls, optimized image processing
- **Security**: Input validation, secure API key management, sandboxing

### 10. Automated Collection Management
- **Scheduled Refresh**: Built-in scheduler for weekly/monthly collection updates
- **Background Service**: Run as system service/daemon for automatic management
- **Smart Curation**: Remove duplicate or similar artworks automatically
- **Storage Monitoring**: Automatic cleanup when disk space is low (target: 1-4GB max)
- **Favorites System**: Permanent storage for user-selected images
- **Rollback System**: Ability to restore previous collections if new ones are unsatisfactory

### 11. Technical Enhancements
- **Offline Mode**: Cache images for offline wallpaper rotation
- **Performance Optimization**: Lazy loading and smart caching
- **Bandwidth Management**: Configurable download limits and scheduling
- **Multi-Monitor Support**: Different artworks on different displays
- **Image Optimization**: Automatic resizing for different screen resolutions

## Success Metrics

- **User Engagement**: Daily active usage and wallpaper rotation frequency
- **Art Discovery**: Number of artworks viewed and favorited
- **Platform Adoption**: Downloads and active installations across platforms
- **Educational Impact**: User engagement with artwork metadata and learning features

## Technical Considerations

- **API Rate Limits**: Respectful usage of free museum APIs
- **Image Processing**: Automatic cropping and optimization for various screen sizes
- **Storage Management**: Configurable local storage limits and cleanup
- **Privacy**: No user data collection, fully local operation
- **Performance**: Minimal system resource usage

---

*This PRD serves as a living document and will be updated as the project evolves.*
