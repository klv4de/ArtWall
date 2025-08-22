# Chicago Art Institute API Reference

## Overview
Complete reference for the Chicago Art Institute API filters and parameters for the ArtWall project.

**Base URL**: `https://api.artic.edu/api/v1/artworks/search`

## Current Problem Analysis
- **Search Method**: Using `q=oil on canvas` keyword search
- **Results**: 24 artworks returned, ~21 rejected by client-side filtering
- **Success Rate**: Only 3-4 suitable paintings per 24 API results (12-16%)
- **Root Cause**: Most results are not public domain or not European department

## Complete API Parameters

### Core Search Parameters
| Parameter | Description | Example | Currently Used |
|-----------|-------------|---------|----------------|
| `q` | Keyword search | `q=Monet` or `q=oil on canvas` | ✅ |
| `fields` | Data fields to return | `id,title,artist_display` | ✅ |
| `limit` | Results per page (max 100) | `limit=24` | ✅ |
| `page` | Page number | `page=2` | ❌ |

### Content Filters (API-Side - Key Opportunity!)
| Parameter | Description | Example | Currently Used |
|-----------|-------------|---------|----------------|
| `is_public_domain` | Public domain filter | `is_public_domain=true` | ❌ |
| `department_title` | Museum department | `department_title=European Painting` | ❌ |
| `classification_title` | Artwork type | `classification_title=Painting` | ❌ |
| `medium_display` | Materials/technique | `medium_display=Oil on canvas` | ❌ |
| `artist_title` | Specific artist | `artist_title=Claude Monet` | ❌ |
| `place_of_origin` | Geographic origin | `place_of_origin=France` | ❌ |

### Date Filters
| Parameter | Description | Example | Currently Used |
|-----------|-------------|---------|----------------|
| `date_start` | Earliest creation date | `date_start=1800` | ❌ |
| `date_end` | Latest creation date | `date_end=1900` | ❌ |

### Display Filters
| Parameter | Description | Example | Currently Used |
|-----------|-------------|---------|----------------|
| `is_on_view` | Currently displayed | `is_on_view=true` | ❌ |
| `sort` | Sort order | `sort=title` | ❌ |

## Current Implementation Issues

### What We're Doing Wrong
1. **Keyword Search Only**: Using `q=oil on canvas` gets random oil paintings
2. **Client-Side Filtering**: Filtering after API call wastes 80%+ of results
3. **No Public Domain Filter**: Most results fail public domain check
4. **No Department Filter**: Getting American, Asian, Contemporary art we don't want

### Terminal Output Analysis
```
🔍 Searching: q=oil%20on%20canvas&limit=24
📊 Found 24 artworks
❌ Not public domain: The Annunciation
❌ Not public domain: Train Landscape  
❌ Not public domain: Still Life Filled with Space
✅ Suitable painting: Fisherman's Cottage - Oil on canvas
✅ Suitable painting: Farm near Duivendrecht - Oil on canvas
❌ Not public domain: Corpse and Mirror II
... (21 more rejections)
🎨 Filtered to 3 suitable European paintings
```

**Problem**: 21 out of 24 results rejected = 87.5% waste rate!

## Recommended New Strategy

### Strategy 1: Pre-Filter with API Parameters
```
https://api.artic.edu/api/v1/artworks/search?
  is_public_domain=true&
  classification_title=Painting&
  medium_display=Oil on canvas&
  limit=24
```

**Expected Result**: 24 public domain oil paintings (90%+ suitable vs current 12%)

### Strategy 2: Target Specific Departments
```
https://api.artic.edu/api/v1/artworks/search?
  is_public_domain=true&
  department_title=European Painting&
  limit=24
```

### Strategy 3: Famous Artists Search
```
https://api.artic.edu/api/v1/artworks/search?
  artist_title=Claude Monet&
  is_public_domain=true&
  limit=5
```

### Strategy 4: Geographic + Time Period
```
https://api.artic.edu/api/v1/artworks/search?
  place_of_origin=France&
  date_start=1800&
  date_end=1900&
  is_public_domain=true&
  classification_title=Painting&
  limit=24
```

## Known Department Names
Based on terminal output analysis:
- `"European Painting"` ✅ (what we want)
- `"Modern Art"` ✅ (contains European masterpieces)  
- `"Arts of the Americas"` ❌ (American art)
- `"Textiles"` ❌ (not paintings)
- `"Prints and Drawings"` ❌ (not oil paintings)
- `"Contemporary Art"` ❌ (likely not public domain)

## Known Classification Names
- `"Painting"` ✅ (what we want)
- `"Sculpture"` ❌
- `"Drawing"` ✅ (could be included)
- `"Print"` ❌

## European Countries for `place_of_origin`
- `"France"` (Impressionists, Post-Impressionists)
- `"Netherlands"` (Dutch Masters, Van Gogh)
- `"Italy"` (Renaissance, Baroque)
- `"Spain"` (Goya, Velázquez)
- `"Germany"` (German Expressionists)
- `"Belgium"` (Flemish Masters)
- `"United Kingdom"` / `"England"` (British art)

## Implementation Priority

### Phase 1: Quick Win (Immediate)
Replace current search with:
```swift
// Instead of: q=oil on canvas
// Use: is_public_domain=true&classification_title=Painting&limit=24
```

### Phase 2: Multi-Strategy Approach
1. European Painting department search
2. Famous artist searches (Monet, Van Gogh, Renoir)
3. Geographic searches (France, Netherlands, Italy)
4. Time period searches (1800-1900 for Impressionists)

### Phase 3: Smart Rotation
- Rotate between different search strategies
- Track which strategies yield the most suitable results
- Build local database of successful artwork IDs

## Success Metrics
- **Current**: 3-4 suitable paintings per 24 API calls (12-16% success)
- **Target**: 20+ suitable paintings per 24 API calls (80%+ success)
- **Benefit**: 5x more artwork variety with same API usage

## Rate Limiting Notes
- Current: 3-second delay between API calls
- Chicago API appears very reliable (no 502 errors like Met Museum)
- Can increase API calls if we get better success rates

## Complete Department List

**API Endpoint**: `https://api.artic.edu/api/v1/departments`

### All 16 Available Departments:
1. **"AIC Archives"** ❌ (Archive materials)
2. **"Applied Arts of Europe"** ✅ (European decorative arts)
3. **"Architecture and Design"** ❌ (Not paintings)
4. **"Arts of Africa"** ❌ (African art)
5. **"Arts of Asia"** ❌ (Asian art)
6. **"Arts of Greece, Rome, and Byzantium"** ❌ (Ancient art)
7. **"Arts of the Americas"** ❌ (American art - what we're rejecting)
8. **"Contemporary Art"** ❌ (Likely not public domain)
9. **"Modern and Contemporary Art"** ❌ (Mixed, mostly not public domain)
10. **"Modern Art"** ✅ (Contains European masterpieces - Van Gogh, Picasso)
11. **"Painting and Sculpture of Europe"** ✅ (Primary target!)
12. **"Photography and Media"** ❌ (Not paintings)
13. **"Prints and Drawings"** ✅ (Could include drawings)
14. **"Provenance Research Project"** ❌ (Research materials)
15. **"Ryerson and Burnham Libraries Special Collections"** ❌ (Library materials)
16. **"Textiles"** ❌ (Fabric art - what we're rejecting)

### Recommended Departments for Our Use:
- **"Painting and Sculpture of Europe"** (Primary)
- **"Modern Art"** (Contains Impressionists, Post-Impressionists)
- **"Applied Arts of Europe"** (Decorative paintings)
- **"Prints and Drawings"** (For drawings category)

## Classification Titles (From Terminal Analysis)

**Note**: The `/classifications` API endpoint returns 404, but from our terminal output analysis, we can see these classifications:

### Classifications We've Observed:
- **"Painting"** ✅ (Primary target)
- **"Drawing"** ✅ (Could include)
- **"Print"** ❌ (Not oil paintings)
- **"Sculpture"** ❌ (Not paintings)
- **"Textile"** ❌ (Fabric art)
- **"Vessel"** ❌ (Pottery/ceramics)
- **"Panel"** ❌ (Decorative panels)

### Medium Display Values (From Terminal Analysis):
- **"Oil on canvas"** ✅ (Primary target)
- **"Oil on cradled panel"** ❌ (We're rejecting these)
- **"Oil on cardboard"** ❌ (We're rejecting these)
- **"Watercolor"** ✅ (Could include)
- **"Acrylic"** ❌ (Modern, likely not public domain)

## API Endpoint Reference

### Working Endpoints:
- **Departments**: `https://api.artic.edu/api/v1/departments` ✅
- **Departments Page 2**: `https://api.artic.edu/api/v1/departments?page=2` ✅
- **Artworks Search**: `https://api.artic.edu/api/v1/artworks/search` ✅

### Non-Working Endpoints:
- **Classifications**: `https://api.artic.edu/api/v1/classifications` ❌ (Returns 404)

---
*Last Updated: December 2024*
*For ArtWall Project - Kevin & AI Assistant*
