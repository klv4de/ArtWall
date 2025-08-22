#!/usr/bin/env python3
"""
ArtWall GitHub Collections Builder
Downloads all artwork images and creates GitHub-ready collection structure
"""

import os
import json
import requests
import sqlite3
import time
from pathlib import Path
import shutil

class GitHubCollectionsBuilder:
    def __init__(self):
        self.db_path = "chicago_artworks_complete.db"
        self.output_dir = Path("github_collections")
        self.collections_dir = Path("collections")
        self.api_delay = 1.0  # 1 second between downloads (faster than API calls)
        
    def create_output_structure(self):
        """Create the GitHub collections directory structure"""
        if self.output_dir.exists():
            shutil.rmtree(self.output_dir)
        
        self.output_dir.mkdir(exist_ok=True)
        (self.output_dir / "images").mkdir(exist_ok=True)
        (self.output_dir / "collections").mkdir(exist_ok=True)
        
        print(f"📁 Created output directory: {self.output_dir}")
    
    def load_collection_manifests(self):
        """Load all collection JSON files"""
        manifests = []
        
        collection_files = [
            "medieval_early_renaissance",
            "renaissance_baroque", 
            "eighteenth_century",
            "golden_age_1850s",
            "golden_age_1860s",
            "golden_age_1870s",
            "golden_age_1880s",
            "golden_age_1890s"
        ]
        
        for filename in collection_files:
            filepath = self.collections_dir / f"{filename}.json"
            if filepath.exists():
                with open(filepath, 'r', encoding='utf-8') as f:
                    manifest = json.load(f)
                    manifests.append(manifest)
                    print(f"📋 Loaded: {manifest['title']} ({manifest['artwork_count']} artworks)")
        
        return manifests
    
    def get_artwork_metadata(self, artwork_ids):
        """Get artwork metadata from database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create placeholders for IN clause
        placeholders = ','.join(['?' for _ in artwork_ids])
        
        cursor.execute(f'''
            SELECT id, title, artist_display, date_display, medium_display, image_id
            FROM artworks 
            WHERE id IN ({placeholders})
            ORDER BY id
        ''', artwork_ids)
        
        artworks = {}
        for row in cursor.fetchall():
            artwork_id, title, artist, date, medium, image_id = row
            artworks[artwork_id] = {
                'id': artwork_id,
                'title': title,
                'artist': artist,
                'date': date,
                'medium': medium,
                'image_id': image_id,
                'image_url': f'https://www.artic.edu/iiif/2/{image_id}/full/843,/0/default.jpg'
            }
        
        conn.close()
        return artworks
    
    def download_artwork_image(self, artwork, images_dir):
        """Download a single artwork image"""
        image_url = artwork['image_url']
        filename = f"{artwork['id']}.jpg"
        filepath = images_dir / filename
        
        if filepath.exists():
            print(f"  ✅ Already exists: {artwork['title']}")
            return True
        
        try:
            print(f"  ⬇️ Downloading: {artwork['title']}")
            response = requests.get(image_url, stream=True, timeout=30)
            
            if response.status_code == 200:
                with open(filepath, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                
                size_mb = filepath.stat().st_size / (1024 * 1024)
                print(f"    ✅ Downloaded: {size_mb:.2f} MB")
                return True
            else:
                print(f"    ❌ HTTP Error: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"    ❌ Error: {e}")
            return False
    
    def build_collection(self, manifest):
        """Build a single collection with images and metadata"""
        collection_id = manifest['collection_id']
        print(f"\n🎨 Building collection: {manifest['title']}")
        
        # Create collection directory
        collection_dir = self.output_dir / "collections" / collection_id
        collection_dir.mkdir(exist_ok=True)
        
        images_dir = self.output_dir / "images"
        
        # Get artwork metadata from database
        artwork_metadata = self.get_artwork_metadata(manifest['artwork_ids'])
        
        # Download images and track success
        successful_artworks = []
        failed_downloads = []
        
        for i, artwork_id in enumerate(manifest['artwork_ids'], 1):
            if artwork_id in artwork_metadata:
                artwork = artwork_metadata[artwork_id]
                print(f"[{i}/{len(manifest['artwork_ids'])}] {artwork['title']}")
                
                if self.download_artwork_image(artwork, images_dir):
                    # Add GitHub URL to artwork metadata
                    artwork['github_image_url'] = f"https://raw.githubusercontent.com/USER/ArtWall-Collections/main/images/{artwork_id}.jpg"
                    successful_artworks.append(artwork)
                else:
                    failed_downloads.append(artwork_id)
                
                # Rate limiting
                if i < len(manifest['artwork_ids']):
                    time.sleep(self.api_delay)
            else:
                print(f"[{i}/{len(manifest['artwork_ids'])}] ❌ Artwork ID {artwork_id} not found in database")
                failed_downloads.append(artwork_id)
        
        # Create updated collection manifest
        updated_manifest = {
            **manifest,
            'artwork_count': len(successful_artworks),
            'artworks': successful_artworks,
            'failed_downloads': failed_downloads,
            'github_ready': True,
            'image_base_url': 'https://raw.githubusercontent.com/USER/ArtWall-Collections/main/images/'
        }
        
        # Save collection manifest
        manifest_path = collection_dir / "collection.json"
        with open(manifest_path, 'w', encoding='utf-8') as f:
            json.dump(updated_manifest, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Collection complete: {len(successful_artworks)} artworks downloaded")
        if failed_downloads:
            print(f"⚠️ Failed downloads: {len(failed_downloads)} artworks")
        
        return updated_manifest
    
    def create_master_index(self, collections):
        """Create master index of all collections"""
        index = {
            'collections': [
                {
                    'id': col['collection_id'],
                    'title': col['title'],
                    'description': col['description'],
                    'date_range': col['date_range'],
                    'artwork_count': col['artwork_count'],
                    'thumbnail_artworks': col['artworks'][:4] if col['artworks'] else []
                }
                for col in collections
            ],
            'total_collections': len(collections),
            'total_artworks': sum(col['artwork_count'] for col in collections),
            'created_date': '2025-01-21',
            'version': '1.0'
        }
        
        index_path = self.output_dir / "collections_index.json"
        with open(index_path, 'w', encoding='utf-8') as f:
            json.dump(index, f, indent=2, ensure_ascii=False)
        
        print(f"\n📊 Master index created: {index['total_artworks']} artworks across {index['total_collections']} collections")
        return index
    
    def generate_readme(self, index):
        """Generate README for GitHub repository"""
        readme_content = f"""# ArtWall Collections

Curated fine art collections for the ArtWall application.

## Collections ({index['total_collections']})

"""
        
        for collection in index['collections']:
            readme_content += f"### {collection['title']}\n"
            readme_content += f"- **Period**: {collection['date_range']}\n"
            readme_content += f"- **Artworks**: {collection['artwork_count']}\n"
            readme_content += f"- **Description**: {collection['description']}\n\n"
        
        readme_content += f"""## Statistics

- **Total Collections**: {index['total_collections']}
- **Total Artworks**: {index['total_artworks']}
- **Total Images**: ~{index['total_artworks'] * 0.2:.1f} MB
- **Source**: Chicago Art Institute API
- **License**: Public Domain (CC0)

## Usage

Images are served directly from GitHub:
```
https://raw.githubusercontent.com/USER/ArtWall-Collections/main/images/{{artwork_id}}.jpg
```

Collection metadata:
```
https://raw.githubusercontent.com/USER/ArtWall-Collections/main/collections/{{collection_id}}/collection.json
```

## Structure

```
collections/
├── medieval_early_renaissance/
├── renaissance_baroque/
├── eighteenth_century/
├── golden_age_1850s/
├── golden_age_1860s/
├── golden_age_1870s/
├── golden_age_1880s/
└── golden_age_1890s/

images/
├── 111057.jpg
├── 11723.jpg
└── ...
```

Generated on {index['created_date']}
"""
        
        readme_path = self.output_dir / "README.md"
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)
        
        print(f"📝 README.md created")
    
    def build_all_collections(self):
        """Build all collections for GitHub"""
        print("🚀 Starting GitHub Collections Build")
        print("=" * 50)
        
        # Setup
        self.create_output_structure()
        manifests = self.load_collection_manifests()
        
        if not manifests:
            print("❌ No collection manifests found. Make sure collections/*.json files exist.")
            return
        
        # Build each collection
        built_collections = []
        total_artworks = 0
        
        for manifest in manifests:
            try:
                built_collection = self.build_collection(manifest)
                built_collections.append(built_collection)
                total_artworks += built_collection['artwork_count']
            except Exception as e:
                print(f"❌ Failed to build {manifest['title']}: {e}")
        
        # Create master files
        index = self.create_master_index(built_collections)
        self.generate_readme(index)
        
        # Summary
        print("\n" + "=" * 50)
        print("🎉 GitHub Collections Build Complete!")
        print(f"📊 Built {len(built_collections)} collections with {total_artworks} artworks")
        print(f"📁 Output directory: {self.output_dir}")
        print(f"💾 Total size: ~{total_artworks * 0.2:.1f} MB")
        print("\n🎯 Next steps:")
        print("1. Create GitHub repository 'ArtWall-Collections'")
        print("2. Upload contents of github_collections/ directory")
        print("3. Update SwiftUI app to use GitHub URLs")

def main():
    builder = GitHubCollectionsBuilder()
    builder.build_all_collections()

if __name__ == "__main__":
    main()
