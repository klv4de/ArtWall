# ArtWall

Native macOS application with comprehensive fine art database for rotating desktop wallpapers.

## Current Status ✅

**Complete Database Architecture** - 134,078 artworks with full metadata in local SQLite database.

## Quick Start

### Native SwiftUI App
```bash
cd ArtWallApp
swift run
```

### Database Analysis
```bash
python3 -c "import sqlite3; conn = sqlite3.connect('chicago_artworks_complete.db'); print('Total artworks:', conn.execute('SELECT COUNT(*) FROM artworks').fetchone()[0])"
```

## Features

- **Complete Art Database**: 134,078 artworks from Chicago Art Institute with full metadata
- **Rich Artwork Descriptions**: Museum-quality descriptions with cultural context and historical analysis
- **Instant Queries**: Lightning-fast local database searches with optimized indexes
- **Advanced Filtering**: Query by department, artist, color, material, technique, date, and more
- **Native macOS App**: SwiftUI application with professional UI/UX and educational content
- **Offline Operation**: No API dependencies, works without internet
- **Public Domain Focus**: High-quality, legally usable artwork

## Architecture

- **Database**: SQLite (360.8 MB) with 80+ metadata fields per artwork
- **Frontend**: Native SwiftUI macOS application
- **Images**: Chicago Art Institute IIIF service for high-resolution downloads
- **Cost**: $0 - Completely free, local operation

## Requirements

- macOS (for native app)
- Swift/Xcode (for development)
- Python 3.7+ (for database tools)

## License

MIT License - See LICENSE file for details
