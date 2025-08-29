#!/usr/bin/env python3
"""
Test script to verify description coverage across all collections
"""

import json
import os
import glob

def test_description_coverage():
    """Test that all artworks have descriptions (or report which don't)"""
    
    collections_dir = "ArtWallApp/Sources/ArtWall/Resources/collections/"
    
    if not os.path.exists(collections_dir):
        print(f"❌ Collections directory not found: {collections_dir}")
        return False
    
    # Find all collection JSON files
    collection_files = glob.glob(f"{collections_dir}*/collection.json")
    
    if not collection_files:
        print(f"❌ No collection files found in {collections_dir}")
        return False
    
    print(f"🔍 Testing description coverage across {len(collection_files)} collections...\n")
    
    total_artworks = 0
    total_with_descriptions = 0
    total_empty_descriptions = 0
    
    collections_report = []
    
    for collection_file in sorted(collection_files):
        collection_name = os.path.basename(os.path.dirname(collection_file))
        
        try:
            with open(collection_file, 'r', encoding='utf-8') as f:
                collection_data = json.load(f)
            
            artworks = collection_data.get('artworks', [])
            collection_total = len(artworks)
            collection_with_desc = 0
            collection_empty_desc = 0
            missing_desc_titles = []
            
            for artwork in artworks:
                total_artworks += 1
                description = artwork.get('description', '')
                
                if description and description.strip():
                    collection_with_desc += 1
                    total_with_descriptions += 1
                else:
                    collection_empty_desc += 1
                    total_empty_descriptions += 1
                    missing_desc_titles.append(artwork.get('title', 'Unknown Title'))
            
            coverage_percent = (collection_with_desc / collection_total * 100) if collection_total > 0 else 0
            
            collections_report.append({
                'name': collection_name,
                'total': collection_total,
                'with_desc': collection_with_desc,
                'empty_desc': collection_empty_desc,
                'coverage': coverage_percent,
                'missing_titles': missing_desc_titles
            })
            
            # Print collection summary
            status = "✅" if collection_empty_desc == 0 else "⚠️"
            print(f"{status} {collection_name.replace('_', ' ').title()}")
            print(f"   Total: {collection_total} | With descriptions: {collection_with_desc} | Empty: {collection_empty_desc} | Coverage: {coverage_percent:.1f}%")
            
            if missing_desc_titles and len(missing_desc_titles) <= 5:
                print(f"   Missing descriptions: {', '.join(missing_desc_titles[:5])}")
            elif len(missing_desc_titles) > 5:
                print(f"   Missing descriptions: {', '.join(missing_desc_titles[:3])} ... and {len(missing_desc_titles) - 3} more")
            print()
            
        except Exception as e:
            print(f"❌ Error processing {collection_file}: {e}")
            continue
    
    # Overall summary
    overall_coverage = (total_with_descriptions / total_artworks * 100) if total_artworks > 0 else 0
    
    print("=" * 60)
    print("📊 OVERALL SUMMARY")
    print("=" * 60)
    print(f"Total Collections: {len(collections_report)}")
    print(f"Total Artworks: {total_artworks}")
    print(f"With Descriptions: {total_with_descriptions}")
    print(f"Empty Descriptions: {total_empty_descriptions}")
    print(f"Overall Coverage: {overall_coverage:.1f}%")
    
    # Success criteria
    if total_empty_descriptions == 0:
        print("\n🎉 SUCCESS: All artworks have descriptions!")
        return True
    else:
        print(f"\n⚠️  INCOMPLETE: {total_empty_descriptions} artworks still need descriptions")
        
        # Show collections with worst coverage
        worst_collections = sorted([c for c in collections_report if c['empty_desc'] > 0], 
                                 key=lambda x: x['coverage'])
        
        if worst_collections:
            print("\n📉 Collections with missing descriptions (worst first):")
            for collection in worst_collections[:3]:
                print(f"   • {collection['name'].replace('_', ' ').title()}: {collection['coverage']:.1f}% coverage ({collection['empty_desc']} missing)")
        
        return False

if __name__ == "__main__":
    success = test_description_coverage()
    exit(0 if success else 1)
