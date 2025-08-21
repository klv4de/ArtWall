# Chicago Art Institute API Reference

## Base Information
- **API Base URL**: `https://api.artic.edu/api/v1`
- **IIIF Image Base**: `https://www.artic.edu/iiif/2`
- **Rate Limiting**: Conservative 3-second delays work well
- **Max Limit per Request**: ~100 items (403 error if higher)

## Key Endpoints

### Search Artworks
```
GET /artworks/search?q={query}&limit={limit}&fields={fields}
```

### Get Specific Artwork
```
GET /artworks/{id}?fields={fields}
```

## Important Fields for ArtWall

### Filtering Fields
- `department_title`: "Painting and Sculpture of Europe"
- `is_public_domain`: true/false
- `image_id`: Present if artwork has image
- `medium_display`: Full medium description
- `classification_title`: Artwork type

### Metadata Fields
- `id`: Unique artwork ID
- `title`: Artwork title
- `artist_title`: Artist name (short)
- `artist_display`: Full artist info with dates
- `date_start` / `date_end`: Year range
- `dimensions`: Physical size
- `style_titles`: Art movements/styles
- `subject_titles`: Subject matter tags

## European Collection Medium Types

### Paintings (INCLUDE)
- `"Oil on canvas"`
- `"Oil on panel"`
- `"Oil on board"`
- `"Tempera on panel"`
- `"Acrylic on canvas"`

### Works on Paper (EXCLUDE for now)
- `"Watercolor on paper"`
- `"Gouache on paper"`
- `"Pastel on paper"`
- `"Charcoal on paper"`
- `"Graphite on paper"`

### Prints (EXCLUDE)
- `"Etching"`
- `"Lithograph"`
- `"Engraving"`
- `"Woodcut"`

### Sculpture (EXCLUDE for now)
- `"Terracotta"`
- `"Bronze"`
- `"Marble"`
- `"Plaster"`

## IIIF Image URLs
```
https://www.artic.edu/iiif/2/{image_id}/full/{width},/0/default.jpg
```
- Use `843,` for width=843px, height=auto
- Use `full` for maximum resolution

## Successful Query Examples

### European Paintings Search
```
https://api.artic.edu/api/v1/artworks/search?q=Painting and Sculpture of Europe&limit=100&fields=id,title,artist_display,image_id,is_public_domain,department_title,classification_title,medium_display
```

### Filter Results
- Filter by `department_title == "Painting and Sculpture of Europe"`
- Filter by `is_public_domain == true`
- Filter by `image_id` exists
- Filter by medium (paintings only)

## Rate Limiting Best Practices
- 3-second delays between API calls
- Max 100 items per search request
- Max 100 API calls per session
- Use timeouts (30 seconds)

## Data Dump Alternative
- GitHub: https://github.com/art-institute-of-chicago/api-data
- Updated nightly
- Use for bulk analysis without API limits

---
*Last Updated: December 2024*
*Based on successful ArtWall implementation*
