#!/usr/bin/env python3
"""
Department Sampler - Download 5-10 examples from each Met Museum department
Respects API rate limits with 3-second delays between calls
"""

import os
import requests
import time
from pathlib import Path
import json
from PIL import Image
from io import BytesIO

class DepartmentSampler:
    def __init__(self):
        self.met_api_base = "https://collectionapi.metmuseum.org/public/collection/v1"
        self.samples_dir = Path.home() / "Pictures" / "ArtWall_Samples"
        self.samples_dir.mkdir(exist_ok=True)
        
        # VERY conservative rate limiting
        self.api_delay = 3.0  # 3 seconds between API calls
        self.max_samples_per_dept = 5  # Keep it small for now
        
        # All departments
        self.departments = {
            1: "American Decorative Arts",
            3: "Ancient Near Eastern Art",
            4: "Arms and Armor", 
            5: "Arts of Africa, Oceania, and the Americas",
            6: "Asian Art",
            7: "The Cloisters",
            8: "The Costume Institute",
            9: "Drawings and Prints",
            10: "Egyptian Art",
            11: "European Paintings",
            12: "European Sculpture and Decorative Arts",
            13: "Greek and Roman Art",
            14: "Islamic Art",
            15: "The Robert Lehman Collection",
            16: "The Libraries",
            17: "Medieval Art",
            18: "Musical Instruments",
            19: "Photographs",
            21: "Modern Art"
        }
    
    def safe_api_call(self, url, description="API call"):
        """Make API call with error handling and rate limiting"""
        print(f"Making {description}...")
        try:
            response = requests.get(url, timeout=30)
            if response.status_code == 200:
                print(f"✓ Success")
                time.sleep(self.api_delay)  # Rate limiting
                return response.json()
            else:
                print(f"✗ API error: {response.status_code}")
                time.sleep(self.api_delay * 2)  # Longer delay on error
                return None
        except Exception as e:
            print(f"✗ Request failed: {e}")
            time.sleep(self.api_delay * 2)
            return None
    
    def download_image(self, image_url, filepath):
        """Download image with error handling"""
        try:
            response = requests.get(image_url, stream=True, timeout=30)
            if response.status_code == 200:
                with open(filepath, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                return True
        except Exception as e:
            print(f"  ✗ Image download failed: {e}")
        return False
    
    def sample_department(self, dept_id, dept_name):
        """Sample artworks from a specific department"""
        print(f"\n🎨 Sampling Department {dept_id}: {dept_name}")
        
        # Create department folder
        dept_folder = self.samples_dir / f"{dept_id:02d}_{dept_name.replace(' ', '_').replace(',', '')}"
        dept_folder.mkdir(exist_ok=True)
        
        # Search for objects in this department with images
        search_url = f"{self.met_api_base}/search?departmentId={dept_id}&hasImages=true&isPublicDomain=true"
        search_results = self.safe_api_call(search_url, f"search in {dept_name}")
        
        if not search_results or 'objectIDs' not in search_results:
            print(f"  ✗ No objects found in {dept_name}")
            return 0
        
        object_ids = search_results['objectIDs'][:20]  # Get first 20 to sample from
        print(f"  Found {len(search_results['objectIDs'])} total objects, sampling from first {len(object_ids)}")
        
        downloaded = 0
        for i, obj_id in enumerate(object_ids):
            if downloaded >= self.max_samples_per_dept:
                break
            
            print(f"  Checking object {i+1}/{len(object_ids)} (ID: {obj_id})...")
            
            # Get object details
            obj_url = f"{self.met_api_base}/objects/{obj_id}"
            artwork = self.safe_api_call(obj_url, f"object details for {obj_id}")
            
            if not artwork or not artwork.get('primaryImage'):
                print(f"    ✗ No image available")
                continue
            
            # Get artwork info
            title = artwork.get('title', 'Unknown')[:50]
            artist = artwork.get('artistDisplayName', 'Unknown')[:30]
            
            # Create filename
            safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).strip()
            filename = f"{obj_id}_{safe_title}.jpg"
            filepath = dept_folder / filename
            
            print(f"    ✓ Downloading: {title} by {artist}")
            
            # Download image
            if self.download_image(artwork['primaryImage'], filepath):
                downloaded += 1
                print(f"    ✓ Saved to {filepath.name}")
                
                # Save metadata
                metadata = {
                    'objectID': obj_id,
                    'title': artwork.get('title'),
                    'artist': artwork.get('artistDisplayName'),
                    'department': dept_name,
                    'classification': artwork.get('classification'),
                    'objectName': artwork.get('objectName'),
                    'medium': artwork.get('medium'),
                    'dimensions': artwork.get('dimensions'),
                    'objectDate': artwork.get('objectDate')
                }
                
                metadata_file = filepath.with_suffix('.json')
                with open(metadata_file, 'w') as f:
                    json.dump(metadata, f, indent=2)
            
            # Rate limiting between downloads
            time.sleep(1.0)
        
        print(f"  📊 Downloaded {downloaded} samples from {dept_name}")
        return downloaded
    
    def sample_all_departments(self):
        """Sample from all departments"""
        print("🎨 Starting Department Sampling")
        print(f"Rate limiting: {self.api_delay}s between API calls")
        print(f"Target: {self.max_samples_per_dept} samples per department")
        print(f"Output folder: {self.samples_dir}")
        
        total_downloaded = 0
        
        for dept_id, dept_name in self.departments.items():
            try:
                count = self.sample_department(dept_id, dept_name)
                total_downloaded += count
                
                # Longer pause between departments
                if dept_id != list(self.departments.keys())[-1]:  # Not the last department
                    print(f"  Pausing 5 seconds before next department...")
                    time.sleep(5.0)
                    
            except KeyboardInterrupt:
                print(f"\n⏹️  Sampling interrupted by user")
                break
            except Exception as e:
                print(f"  ✗ Error sampling {dept_name}: {e}")
                time.sleep(self.api_delay * 2)
        
        print(f"\n📊 Sampling Complete!")
        print(f"Total samples downloaded: {total_downloaded}")
        print(f"Check samples in: {self.samples_dir}")

def main():
    sampler = DepartmentSampler()
    sampler.sample_all_departments()

if __name__ == "__main__":
    main()
