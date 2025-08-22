#!/usr/bin/env python3
"""
Convert Chicago Art Institute JSON artwork data to CSV and SQLite for easy analysis
"""

import json
import csv
import sqlite3
import os
import glob
from pathlib import Path

def convert_artworks_to_structured_data():
    """Convert all artwork JSON files to CSV and SQLite database"""
    
    print("🎨 Converting Chicago Art Institute artwork data...")
    
    # Path to artwork JSON files
    artworks_dir = "artic-api-data/json/artworks"
    
    if not os.path.exists(artworks_dir):
        print(f"❌ Directory {artworks_dir} not found!")
        return
    
    # Get all JSON files
    json_files = glob.glob(f"{artworks_dir}/*.json")
    total_files = len(json_files)
    print(f"📁 Found {total_files} artwork files")
    
    # List to store all artwork data
    artworks = []
    
    # Process each JSON file
    print("📊 Processing files...")
    for i, file_path in enumerate(json_files):
        if i % 5000 == 0:  # Progress update every 5000 files
            print(f"   Processed {i}/{total_files} files...")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                
                # Extract ALL useful fields
                thumbnail = data.get('thumbnail', {})
                dimensions_detail = data.get('dimensions_detail', [{}])[0] if data.get('dimensions_detail') else {}
                color = data.get('color', {})
                
                artwork = {
                    # Basic Info
                    'id': data.get('id'),
                    'title': (data.get('title') or '').replace('\n', ' ').replace('\r', ' '),
                    'artist_display': (data.get('artist_display') or '').replace('\n', ' ').replace('\r', ' '),
                    'date_display': data.get('date_display', ''),
                    'medium_display': data.get('medium_display', ''),
                    'main_reference_number': data.get('main_reference_number', ''),
                    
                    # Classification
                    'department_title': data.get('department_title', ''),
                    'classification_title': data.get('classification_title', ''),
                    'artwork_type_title': data.get('artwork_type_title', ''),
                    
                    # Status & Access
                    'is_public_domain': data.get('is_public_domain', False),
                    'is_on_view': data.get('is_on_view', False),
                    'is_zoomable': data.get('is_zoomable', False),
                    'max_zoom_window_size': data.get('max_zoom_window_size'),
                    
                    # Location & Origin
                    'place_of_origin': data.get('place_of_origin', ''),
                    'gallery_title': data.get('gallery_title', ''),
                    
                    # Dimensions
                    'dimensions': data.get('dimensions', ''),
                    'width_cm': dimensions_detail.get('width'),
                    'height_cm': dimensions_detail.get('height'),
                    'depth_cm': dimensions_detail.get('depth'),
                    
                    # Images
                    'image_id': data.get('image_id', ''),
                    'has_image': bool(data.get('image_id')),
                    'thumbnail_width': thumbnail.get('width'),
                    'thumbnail_height': thumbnail.get('height'),
                    'thumbnail_pixels': (thumbnail.get('width', 0) * thumbnail.get('height', 0)) if thumbnail.get('width') and thumbnail.get('height') else 0,
                    
                    # Dates
                    'date_start': data.get('date_start'),
                    'date_end': data.get('date_end'),
                    
                    # Descriptions
                    'description': (data.get('description') or '').replace('\n', ' ').replace('\r', ' ')[:500],  # Truncate long descriptions
                    'short_description': (data.get('short_description') or '').replace('\n', ' ').replace('\r', ' '),
                    'credit_line': (data.get('credit_line') or '').replace('\n', ' ').replace('\r', ' '),
                    'inscriptions': (data.get('inscriptions') or '').replace('\n', ' ').replace('\r', ' '),
                    
                    # Color Analysis
                    'colorfulness': data.get('colorfulness'),
                    'color_h': color.get('h'),  # Hue
                    'color_l': color.get('l'),  # Lightness  
                    'color_s': color.get('s'),  # Saturation
                    
                    # Metadata
                    'boost_rank': data.get('boost_rank'),
                    'has_not_been_viewed_much': data.get('has_not_been_viewed_much', False),
                    'fiscal_year': data.get('fiscal_year'),
                }
                
                artworks.append(artwork)
                
        except Exception as e:
            print(f"⚠️  Error processing {file_path}: {e}")
            continue
    
    print(f"✅ Processed {len(artworks)} artworks successfully")
    
    # Write to CSV
    print("💾 Writing CSV file...")
    csv_file = "chicago_artworks.csv"
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        if artworks:
            fieldnames = artworks[0].keys()
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(artworks)
    
    print(f"✅ CSV saved: {csv_file}")
    
    # Create SQLite database
    print("🗃️  Creating SQLite database...")
    db_file = "chicago_artworks.db"
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    
    # Create table with ALL fields
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS artworks (
            id INTEGER PRIMARY KEY,
            title TEXT,
            artist_display TEXT,
            date_display TEXT,
            medium_display TEXT,
            main_reference_number TEXT,
            department_title TEXT,
            classification_title TEXT,
            artwork_type_title TEXT,
            is_public_domain BOOLEAN,
            is_on_view BOOLEAN,
            is_zoomable BOOLEAN,
            max_zoom_window_size INTEGER,
            place_of_origin TEXT,
            gallery_title TEXT,
            dimensions TEXT,
            width_cm REAL,
            height_cm REAL,
            depth_cm REAL,
            image_id TEXT,
            has_image BOOLEAN,
            thumbnail_width INTEGER,
            thumbnail_height INTEGER,
            thumbnail_pixels INTEGER,
            date_start INTEGER,
            date_end INTEGER,
            description TEXT,
            short_description TEXT,
            credit_line TEXT,
            inscriptions TEXT,
            colorfulness REAL,
            color_h INTEGER,
            color_l INTEGER,
            color_s INTEGER,
            boost_rank REAL,
            has_not_been_viewed_much BOOLEAN,
            fiscal_year INTEGER
        )
    ''')
    
    # Insert data
    if artworks:
        placeholders = ', '.join(['?' for _ in artworks[0].keys()])
        cursor.executemany(
            f"INSERT INTO artworks VALUES ({placeholders})",
            [tuple(artwork.values()) for artwork in artworks]
        )
    
    conn.commit()
    conn.close()
    
    print(f"✅ SQLite database saved: {db_file}")
    
    # Quick analysis
    print("\n📈 Quick Analysis:")
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    
    # Total artworks
    cursor.execute("SELECT COUNT(*) FROM artworks")
    total = cursor.fetchone()[0]
    print(f"   Total artworks: {total:,}")
    
    # Public domain count
    cursor.execute("SELECT COUNT(*) FROM artworks WHERE is_public_domain = 1")
    public_domain = cursor.fetchone()[0]
    print(f"   Public domain: {public_domain:,}")
    
    # Paintings in European department
    cursor.execute("""
        SELECT COUNT(*) FROM artworks 
        WHERE department_title = 'Painting and Sculpture of Europe' 
        AND classification_title = 'painting'
    """)
    european_paintings = cursor.fetchone()[0]
    print(f"   European paintings: {european_paintings:,}")
    
    # Public domain European paintings
    cursor.execute("""
        SELECT COUNT(*) FROM artworks 
        WHERE department_title = 'Painting and Sculpture of Europe' 
        AND classification_title = 'painting'
        AND is_public_domain = 1
    """)
    public_european_paintings = cursor.fetchone()[0]
    print(f"   Public domain European paintings: {public_european_paintings:,}")
    
    # Oil paintings
    cursor.execute("""
        SELECT COUNT(*) FROM artworks 
        WHERE medium_display LIKE '%oil on canvas%'
        AND is_public_domain = 1
    """)
    oil_paintings = cursor.fetchone()[0]
    print(f"   Public domain oil on canvas: {oil_paintings:,}")
    
    conn.close()
    
    print(f"\n🎯 Files created:")
    print(f"   📄 {csv_file} - Open in Excel/Google Sheets")
    print(f"   🗃️  {db_file} - Query with Python/SQL")
    print(f"\n✨ Ready for analysis!")

if __name__ == "__main__":
    convert_artworks_to_structured_data()
