# ArtWall Collection Filter Template

**Date**: January 21, 2025  
**Status**: STANDARD TEMPLATE - Do Not Modify Without Approval

## 🎯 **Standard Collection Filters**

**This is our proven template for building high-quality wallpaper collections.**

### **Required Filters (Apply to ALL Collections)**

```sql
SELECT id, title, artist_display, date_display, medium_display, image_id
FROM artworks 
WHERE 
    -- 1. DEPARTMENT FILTER
    department_title = "Painting and Sculpture of Europe"
    
    -- 2. LEGAL FILTER  
    AND is_public_domain = 1
    
    -- 3. IMAGE AVAILABILITY FILTER
    AND image_id IS NOT NULL
    
    -- 4. CLASSIFICATION FILTER
    AND classification_title = "painting"
    
    -- 5. QUALITY FILTER
    AND is_zoomable = 1
    
    -- Additional filters go here (artist, date, etc.)
```

## 📋 **Filter Breakdown**

### **1. Department Filter**
- **Field**: `department_title = "Painting and Sculpture of Europe"`
- **Purpose**: Focus on European masterpieces from curated museum department
- **Result**: Excludes Asian art, American art, textiles, etc.

### **2. Legal Filter**
- **Field**: `is_public_domain = 1`
- **Purpose**: Only legally free artworks (no copyright issues)
- **Result**: Safe for commercial use, distribution, wallpaper apps

### **3. Image Availability Filter**
- **Field**: `image_id IS NOT NULL`
- **Purpose**: Only artworks with downloadable images
- **Result**: Excludes artworks without digital images

### **4. Classification Filter**
- **Field**: `classification_title = "painting"`
- **Purpose**: Only actual paintings (not sculptures, reliefs, etc.)
- **Result**: Wallpaper-suitable 2D artworks only

### **5. Quality Filter**
- **Field**: `is_zoomable = 1`
- **Purpose**: Ensures high-resolution images available
- **Result**: All images can be downloaded at wallpaper-suitable resolutions

## 📊 **Template Results**

**Base Pool**: 323 high-quality European paintings
- **All public domain** ✅
- **All have images** ✅  
- **All are paintings** ✅
- **All are high-resolution** ✅
- **Date range**: 1260s-1910s (650+ years of art history)

## 🎨 **Additional Filter Options**

### **Artist-Based Collections**
```sql
-- Add to base template:
AND artist_title = "Claude Monet"
```

### **Period-Based Collections**  
```sql
-- Add to base template:
AND date_start BETWEEN 1860 AND 1890
```

### **Color-Based Collections**
```sql
-- Add to base template:
AND colorfulness > 40
```

### **Geographic Collections**
```sql
-- Add to base template:
AND place_of_origin = "France"
```

## ⚠️ **Important Notes**

1. **Never modify the 5 required filters** - they ensure quality and legal safety
2. **Always test additional filters** against the base template
3. **Document any new filter combinations** for future reference
4. **Verify image URLs work** before building collections

## 🚀 **Usage**

This template is used by:
- Database curation scripts
- Collection ID generation
- API collection building
- SwiftUI app filtering

**This template ensures consistent, high-quality collections across all ArtWall features.**
