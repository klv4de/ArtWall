#!/usr/bin/env python3
"""
Script to add artwork descriptions from SQLite database to collection JSON files
"""

import json
import sqlite3
import os
import sys

def get_artwork_descriptions(db_path, artwork_ids):
    """Fetch descriptions for given artwork IDs from the database"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Convert list to comma-separated string for SQL IN clause
    ids_str = ','.join(map(str, artwork_ids))
    
    query = f"""
    SELECT id, description, short_description 
    FROM artworks 
    WHERE id IN ({ids_str})
    """
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    # Convert to dictionary for easy lookup
    descriptions = {}
    for artwork_id, description, short_description in results:
        descriptions[artwork_id] = {
            'description': description or '',
            'short_description': short_description or ''
        }
    
    conn.close()
    return descriptions

def update_collection_json(collection_path, descriptions):
    """Update collection JSON file with descriptions"""
    
    # Read the collection JSON
    with open(collection_path, 'r', encoding='utf-8') as f:
        collection_data = json.load(f)
    
    # Update artworks with descriptions
    updated_count = 0
    for artwork in collection_data.get('artworks', []):
        artwork_id = artwork.get('id')
        if artwork_id in descriptions:
            desc_data = descriptions[artwork_id]
            artwork['description'] = desc_data['description']
            artwork['short_description'] = desc_data['short_description']
            updated_count += 1
            print(f"✅ Added description for: {artwork.get('title', 'Unknown')}")
        else:
            # Add empty description fields if not found
            artwork['description'] = ''
            artwork['short_description'] = ''
            print(f"⚠️  No description found for: {artwork.get('title', 'Unknown')} (ID: {artwork_id})")
    
    # Write back the updated JSON
    with open(collection_path, 'w', encoding='utf-8') as f:
        json.dump(collection_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Updated {updated_count} artworks in {collection_path}")
    return updated_count

def main():
    db_path = 'chicago_artworks_complete.db'
    
    if not os.path.exists(db_path):
        print(f"❌ Database not found: {db_path}")
        sys.exit(1)
    
    # Collections to update - ALL collections
    collections = [
        'ArtWallApp/Sources/ArtWall/Resources/collections/eighteenth_century/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/golden_age_1850s/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/golden_age_1860s/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/golden_age_1870s/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/golden_age_1880s/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/golden_age_1890s/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/medieval_early_renaissance/collection.json',
        'ArtWallApp/Sources/ArtWall/Resources/collections/renaissance_baroque/collection.json',
    ]
    
    total_updated = 0
    
    for collection_path in collections:
        if not os.path.exists(collection_path):
            print(f"⚠️  Collection not found: {collection_path}")
            continue
            
        print(f"\n🔄 Processing: {collection_path}")
        
        # Read collection to get artwork IDs
        with open(collection_path, 'r', encoding='utf-8') as f:
            collection_data = json.load(f)
        
        artwork_ids = [artwork['id'] for artwork in collection_data.get('artworks', [])]
        
        if not artwork_ids:
            print(f"⚠️  No artworks found in {collection_path}")
            continue
        
        # Get descriptions from database
        descriptions = get_artwork_descriptions(db_path, artwork_ids)
        
        # Update the collection JSON
        updated_count = update_collection_json(collection_path, descriptions)
        total_updated += updated_count
    
    print(f"\n🎉 Total artworks updated: {total_updated}")

if __name__ == "__main__":
    main()
