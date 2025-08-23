# ArtWall System Requirements

## Minimum Requirements

### macOS Version
- **Required**: macOS Sonoma 14.0 or later
- **Tested on**: macOS Sequoia 15.6.1
- **Recommended**: Latest macOS version for best performance

### Hardware
- **Mac**: Any Mac capable of running macOS Sonoma 14.0+
- **Storage**: 500MB+ available space (for art collections)
- **Memory**: 4GB RAM minimum
- **Network**: Internet connection required for downloading collections

## Feature Compatibility

### Wallpaper Automation
- **macOS 14.0+**: Full automatic wallpaper rotation support
- **macOS 13.x**: Limited support (manual wallpaper setup required)
- **macOS 12.x and earlier**: Not supported

### Screensaver Integration
- **macOS 14.0+**: Automatic screensaver configuration
- **Earlier versions**: Manual screensaver setup required

## Why macOS Sonoma 14.0+?

ArtWall's automatic wallpaper and screensaver configuration relies on:

1. **Native Wallpaper APIs**: `NSWorkspace.setDesktopImageURL()` with modern options
2. **System Preferences Integration**: Reliable UserDefaults keys for wallpaper rotation
3. **Multi-Display Support**: Enhanced multi-monitor wallpaper management
4. **Security Framework**: Proper permission handling for system automation

## Checking Your macOS Version

To check your current macOS version:

1. **Apple Menu** → **About This Mac**
2. **Terminal**: Run `sw_vers`
3. **System Settings** → **General** → **About**

## Upgrading macOS

If you're running an older version:

1. **Apple Menu** → **System Settings** → **General** → **Software Update**
2. Follow the upgrade instructions for your Mac model
3. Ensure you have sufficient storage space (20GB+) for the upgrade

## Error Messages

If you see: *"ArtWall requires macOS Sonoma 14.0 or later for wallpaper automation"*

- Your Mac is running an older macOS version
- Collections will still download, but wallpaper setup will be manual
- Consider upgrading to macOS Sonoma or later for full automation

---

*Last updated: January 2025*
*Tested on: macOS Sequoia 15.6.1*
