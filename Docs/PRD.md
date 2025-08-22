# ArtWall - Product Requirements Document

## Overview

ArtWall is a macOS application that automatically fetches fine art from museum APIs and sets them as rotating desktop wallpapers, bringing world-class art to your daily computing experience.

## Core Objectives

- **Effortless Art Discovery**: Automatically source high-quality fine art from reputable museums
- **Seamless Integration**: Work natively with macOS wallpaper rotation system
- **Legal & Ethical**: Only use public domain or properly licensed artwork
- **Beautiful Experience**: Curate visually stunning, high-resolution images optimized for desktop display

## Tech Stack

### Current (MVP)
- **Language**: Python 3.7+
- **HTTP Client**: `requests` library for API calls
- **Image Processing**: `Pillow` (PIL) for image manipulation
- **System Integration**: Native macOS system calls/AppleScript
- **APIs**: REST APIs (Met Museum, future museum APIs)
- **Storage**: Local filesystem (`~/Pictures/ArtWall/`)
- **Platform**: macOS (with future cross-platform plans)

### Future Professional Stack
- **Packaging**: PyInstaller for standalone executables, proper setup.py/pyproject.toml
- **GUI Framework**: Electron, PyQt, or native Swift/SwiftUI for consumer applications
- **Backend**: FastAPI or Flask for web services (if needed)
- **Database**: SQLite for local metadata, PostgreSQL for cloud services
- **CI/CD**: GitHub Actions for automated testing and releases
- **Distribution**: App stores, package managers, professional installers

## MVP Features

### 1. Art Fetching
- Fetch random fine art from The Metropolitan Museum of Art API
- Filter for public domain works (CC0 licensed)
- Download high-resolution images suitable for desktop wallpapers
- Intelligent curation to avoid inappropriate or low-quality images

### 2. Wallpaper Management
- Save images to dedicated macOS wallpaper folder (`~/Pictures/ArtWall`)
- Provide clear instructions for setting up rotating wallpapers in System Settings
- Support common desktop resolutions and aspect ratios

### 3. Basic Configuration
- Configurable number of artworks to download (default: 10)
- Simple command-line interface
- Respectful API usage with rate limiting

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

### 2. Image Quality & Curation (COMPLETED in Script)
- ✅ **Smart API Selection**: Chicago Art Institute API provides 100% success rate
- ✅ **Department Filtering**: "Painting and Sculpture of Europe" for optimal results  
- ✅ **Paintings-Only Filter**: Excludes sculptures, prints, drawings automatically
- ✅ **Quality Collection**: 48 masterpieces including Van Gogh, Monet, Renoir, Botticelli

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
