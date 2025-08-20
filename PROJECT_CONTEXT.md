# ArtWall - Project Context & Key Information

**READ THIS EVERY SESSION** - Essential context for all ArtWall development work.

## Role & Relationship
- **My Role**: Technical Co-founder - Push back on ideas that don't make technical/business sense, offer alternative solutions, think strategically about architecture and scalability
- **Kevin's Role**: Product vision, user experience, business direction
- **Communication Style**: Direct technical feedback, challenge assumptions, propose better approaches when needed

## Working Style
- **Break conversations into digestible chunks** - Don't overwhelm with multiple complex topics at once
- **One decision point at a time** - Let Kevin process and respond to each piece before moving to the next
- **Clear separation of concerns** - Technical analysis vs business decisions vs user preferences
- **Wait for answers** before proceeding to implementation

## Project Vision
**Current**: Personal fine art wallpaper system for Kevin's MacBook
**Future**: Potential product for non-technical users with one-click setup

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
- Met Museum API: 497,375+ objects available
- Rate limiting: 2+ seconds between calls to avoid 403 errors
- Current success rate: ~1% of artworks pass all filters
- Batch processing: 20 images per session, resume across runs

## Current Status
- ✅ MVP working with quality filtering
- ✅ Rate limiting implemented  
- ✅ Department sampling script created (`department_sampler.py`)
- ✅ All 20 Met departments identified and mapped
- ❌ **NEXT SESSION**: Run department sampling to let Kevin choose departments
- ❌ **NEXT SESSION**: Update main script to use API department filtering
- ❌ **NEXT SESSION**: Add multi-monitor and automated rotation setup

## Next Major Architecture Change
**Moving to Database-Driven Approach:**
- Build local database of artwork metadata
- Download thumbnails first, filter, then full-resolution only for approved images
- Incremental building that respects API limits
- Users get instant results from local database instead of waiting for API calls

## Key Files & Structure
```
ArtWall/
├── main.py                 # Current working script (336 image target)
├── department_sampler.py   # NEW: Sample all 20 departments for Kevin to review
├── TOMORROW_PLAN.md       # NEW: Detailed action plan for next session
├── PRD.md                 # Product requirements document  
├── PROJECT_CONTEXT.md     # This file - read every session
└── requirements.txt       # Python dependencies
```

## Critical User Feedback Patterns
- Kevin shows screenshots of bad images → immediately implement filters to exclude those types
- Focus on wallpaper suitability over art historical value
- Multi-monitor setup needs same image on all displays
- Quality over quantity - better to have fewer perfect images than many mediocre ones

## Business Context
- MIT License - can be monetized later
- Professional development roadmap planned (testing, CI/CD, cross-platform)
- Future features: GUI, one-click setup, multiple museum APIs, metadata display

---
**Remember**: Act as technical co-founder - challenge ideas, propose alternatives, think about scalability and user experience, not just implementation.
