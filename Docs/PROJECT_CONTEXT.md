# ArtWall - Project Context & Key Information

**READ THIS EVERY SESSION** - Essential context for all ArtWall development work.

## Role & Relationship
- **My Role**: **Excited** Technical Co-founder - Push back on ideas that don't make technical/business sense, offer alternative solutions, think strategically about architecture and scalability with enthusiasm and energy! 🚀
- **Kevin's Role**: Product vision, user experience, business direction
- **Communication Style**: Direct technical feedback, challenge assumptions, propose better approaches when needed - but with excitement about the possibilities!

## Working Style
- **Break conversations into digestible chunks** - Don't overwhelm with multiple complex topics at once
- **One decision point at a time** - Let Kevin process and respond to each piece before moving to the next
- **Clear separation of concerns** - Technical analysis vs business decisions vs user preferences
- **Wait for answers** before proceeding to implementation
- **CRITICAL: File Change Approval Process**:
  1. Always let Kevin approve code changes before committing
  2. Let Kevin QA changes
  3. Be thoughtful about what changes you're making
  4. Make sure you are in the right directory
  5. Show Kevin what changed and wait for approval
  6. ONLY THEN commit and push
  7. Never commit without explicit approval

- **CRITICAL: UI/UX Excellence Rule**:
  1. **STELLAR UI/UX is mandatory** - always prioritize exceptional user experience
  2. **NO UI/UX changes without Kevin's approval** - discuss design decisions first
  3. **If Kevin didn't approve it, don't implement it** - stick to agreed designs
  4. **Always ask before changing layouts, styling, or user flows**
  5. **Focus on polish and attention to detail** - every pixel matters

- **CRITICAL: Process Management Before New Builds**:
  1. Always check for running ArtWall processes: `ps aux | grep -i artwall`
  2. Kill all existing processes: `pkill -f ArtWall`
  3. Verify processes are terminated: `ps aux | grep -i artwall`
  4. ONLY THEN build and launch new version
  5. This prevents multiple instances and resource conflicts

## Project Vision & Scaling Strategy
**Phase 1 MVP**: Personal fine art wallpaper system for Kevin's MacBook (48 images, 24 hours)
**Phase 2 Personal**: Expand Kevin's collection (weekly, monthly collections)
**Phase 3 Product**: Scale to other users with cost-optimized architecture

## Cost Strategy
**MVP (Phase 1)**: $0 cost - Everything runs locally on Kevin's machine
**Phase 2 Personal**: ~$0 cost - Local expansion (1GB storage for weekly collection)
**Scaling (Phase 3+)**: Minimize costs through:
- Shared database of curated images (one API call serves many users)
- Efficient caching and CDN strategy
- Serverless architecture to avoid idle server costs
- Community curation to reduce manual filtering costs

## Storage Requirements
**MVP (48 images)**: ~150MB
**Weekly collection (336 images)**: ~1GB  
**Monthly collection (1,440 images)**: ~4GB
**Strategy**: Smart cleanup, favorites system, storage optimization

## Core Problem We're Solving
- Kevin wants rotating fine art wallpapers on his Mac
- Museum APIs have poor image curation for wallpaper use (fragments, catalog photos, small objects)
- **NEW MVP SCOPE**: Need 48 high-quality images for 30-minute rotations (24 hours of content)
- API rate limiting makes real-time fetching impractical
- Multi-monitor setup needs same image on all displays

## Key Technical Decisions Made

### Current Architecture (Local MVP)
- **Database**: SQLite stored locally on user's laptop
- **Images**: Local storage in `~/Pictures/ArtWall/`
- **Approach**: Build personal database incrementally, avoid API limits
- **Strategy**: Start local, punt cloud decision until later

### Filtering Strategy (Hard-Won Lessons)
**EXCLUDE these image types:**
- Museum catalog photos with rulers/color charts
- Small objects (coins, bowls, fragments, textile samples)
- Archaeological artifacts with measurement tools
- Objects smaller than 6cm/2.5 inches
- Departments: Arms & Armor, Egyptian Art, Greek/Roman Art

**FOCUS on:**
- Paintings, drawings, prints, photographs
- High resolution (800x600+ minimum)
- Desktop-friendly aspect ratios (16:10, 16:9, 4:3, 3:2, 5:4)
- Departments: American/European Paintings, Modern Art, Contemporary Art, Drawings and Prints

### API & Rate Limiting
- **CHICAGO ART INSTITUTE API (PRIMARY)**:
  - 100% success rate for European paintings
  - Reliable 200 status responses
  - 3-second rate limiting (conservative, works perfectly)
  - Department: "Painting and Sculpture of Europe"
  - World-class content: Monet, Cézanne, Van Gogh, Renoir, Degas, Manet
  - IIIF image service for high-resolution downloads
  
- **MET MUSEUM API (BACKUP/PROBLEMATIC)**:
  - 497,375+ objects available
  - Rate limiting: 2+ seconds between calls to avoid 403 errors
  - Success rate: ~1% of artworks pass all filters
  - **RELIABILITY ISSUE**: 502 server errors (Dec 2024)

## Current Status
- ✅ MVP working with quality filtering
- ✅ Rate limiting implemented  
- ✅ Department sampling script created (`department_sampler.py`)
- ✅ All 20 Met departments identified and mapped
- ✅ Updated main script to use API department filtering (European Paintings #11)
- ✅ Reduced target to 48 images (24-hour rotation)
- ❌ **BLOCKER**: Met Museum API returning 502 errors (server issues, not rate limiting)
- ✅ **PIVOT SUCCESSFUL**: Art Institute of Chicago API implemented and working
- ✅ **BREAKTHROUGH**: 100% success rate with Chicago API vs 1% with Met API
- ✅ **FIRST COLLECTION**: 20/48 masterpieces downloaded (Monet, Cézanne, Van Gogh, etc.)
- ✅ **COMPLETE DATABASE**: 134,078 artworks with ALL metadata in SQLite (360.8 MB)
- ✅ **DATA ARCHITECTURE**: Instant local queries, no more API dependencies

## ✅ Database Architecture Complete (August 2025)
**ACCOMPLISHED - Database-Driven Approach:**
- ✅ **Complete local database**: 134,078 artworks with ALL 80+ metadata fields
- ✅ **Instant queries**: SQLite with optimized indexes for lightning-fast searches
- ✅ **Zero API dependencies**: No more rate limits, 502 errors, or waiting
- ✅ **Advanced filtering**: Query by department, artist, color, material, technique, date, etc.
- ✅ **Offline capability**: Full functionality without internet connection
- ✅ **Complete data preservation**: Every field from Chicago Art Institute preserved

## Key Files & Structure
```
ArtWall/
├── main.py                           # Met Museum API script (legacy)
├── chicago_artwall.py                # Chicago Art Institute script (legacy)
├── build_artworks_db_fixed.py        # Database builder script (COMPLETE)
├── chicago_artworks_complete.db      # 🎉 COMPLETE DATABASE (360.8 MB, 134k artworks)
├── ArtWallApp/                       # Native SwiftUI macOS application
├── Docs/                            # Complete documentation
└── requirements.txt                 # Python dependencies

Database Structure:
chicago_artworks_complete.db         # SQLite database with ALL metadata
├── 134,078 artworks                 # Complete collection
├── 80+ fields per artwork           # Full metadata preservation
├── Optimized indexes               # Lightning-fast queries
└── 360.8 MB total size            # Compact, efficient storage
```

## Major Technical Breakthrough (December 2024)

### Chicago Art Institute API Success
**Problem Solved**: Met Museum API reliability issues and 1% success rate
**Solution**: Pivoted to Chicago Art Institute API with 100% success rate

**Key Learnings**:
- **API Quality Matters More Than Collection Size**: Chicago's curated European paintings collection beats Met's massive but poorly filterable collection
- **Minimal Filtering Works**: Only needed public domain + has image filters - no complex quality checks required
- **Department Targeting**: "Painting and Sculpture of Europe" gives perfect wallpaper-suitable content
- **Rate Limiting**: 3-second delays are conservative but ensure 100% reliability

**Final Collection Results** (48 images):
- **Van Gogh**: The Bedroom, Madame Roulin Rocking the Cradle, Terrace at Montmartre
- **Claude Monet**: Multiple Water Lilies, Haystacks, Étretat cliffs, Bordighera, Seine at Giverny
- **Pierre-Auguste Renoir**: Chrysanthemums, Near the Lake, Woman at the Piano
- **Sandro Botticelli**: Virgin and Child with an Angel
- **Rembrandt van Rijn**: Young Woman at an Open Half-Door
- **Paul Cézanne**: Auvers Panoramic View, Apples and Grapes
- **Henri de Toulouse-Lautrec**: At the Moulin Rouge, Moulin de la Galette
- **Plus**: Édouard Manet, Edgar Degas, Georges Seurat, and Dutch Golden Age masters

### macOS Automation Success & Permission Architecture
**Problem Solved**: AppleScript automation failing on macOS Sequoia (15.6.1)
**Solution**: Updated to use new System Settings structure with proper pane IDs

**Technical Implementation**:
- **Fixed Pane ID**: `com.apple.Wallpaper-Settings.extension` for macOS 15+
- **Complete Automation**: Opens settings, adds folder, enables 30-min rotation, configures multi-monitor
- **Permission Requirements**: Requires Accessibility/Automation permissions for Terminal/Cursor

**Permission Architecture Decision**:
- **Research Conclusion**: AppleScript UI automation fundamentally unreliable in macOS Sequoia+
- **Root Cause**: System Settings UI changes break AppleScript element targeting
- **Script vs App**: Apps have direct API access, scripts limited to fragile UI automation
- **Strategic Pivot**: Native macOS app required for proper automation (confirmed PRD roadmap)
- **Current State**: Script provides image collection + manual setup instructions

## Critical User Feedback Patterns
- Kevin shows screenshots of bad images → immediately implement filters to exclude those types
- Focus on wallpaper suitability over art historical value
- Multi-monitor setup needs same image on all displays
- Quality over quantity - better to have fewer perfect images than many mediocre ones
- **NEW**: Minimal filtering approach successful - let API curation do the work

## Competitive Analysis
**Existing Solutions:**
- Unsplash Desktop Apps (nature/photography, no fine art)
- Bing/Windows Spotlight (daily wallpapers, not art-focused)
- Irvue, 24 Hour Wallpaper, Keka (limited collections, manual management)

**ArtWall's Unique Value:**
- Museum-quality fine art focus with smart curation
- Automated rotation with multi-monitor support
- Expandable to multiple visual categories
- Personal database that grows over time
- Cost-effective scaling architecture

## Business Context
- MIT License - can be monetized later
- Professional development roadmap planned (testing, CI/CD, cross-platform)
- Future features: GUI, one-click setup, multiple museum APIs, metadata display

---

## 🚨 PRIORITY REFINEMENTS (Next Session - January 2025)

**Critical fixes needed before proceeding with roadmap:**

1. **Fix UI Jumpiness**: 
   - Issue: Visual jump when transitioning from "Load Collection" to artwork grid view
   - Current attempt: Added `.animation(.easeInOut(duration: 0.3))` but still jumpy
   - Need: Smoother transition or different layout approach

2. **Optimize Collection Loading**:
   - Issue: Collections re-load every time when navigating back/forth in same session
   - Current: Moved state to parent ContentView with `@Binding` 
   - Need: Verify this works properly and collections stay loaded

**Status**: Native SwiftUI app working with Chicago API integration, navigation, and artwork detail views. Implementing new page architecture.

## 📱 **App Page Structure (January 2025)**

**Navigation Hierarchy:**
1. **Welcome Page** - Landing page with "Browse Collections" button
2. **Collections Page** - Grid of collection cards with 4-image thumbnails 
3. **Collection Details Page** - Grid of all artworks in selected collection
4. **Image Details Page** - Individual artwork details and metadata

**User Flow:**
- Welcome Page → Collections Page → Collection Details Page → Image Details Page
- Collections auto-load thumbnails (no manual "Load Collection" button)
- Collection cards show visual previews with first 4 images from collection
- Intuitive click-through navigation without explicit load buttons

---
**Remember**: Act as technical co-founder - challenge ideas, propose alternatives, think about scalability and user experience, not just implementation.
