#!/usr/bin/env python3
"""
ArtWall - Fetch fine art and set as rotating wallpapers on macOS
"""

import os
import requests
import subprocess
from pathlib import Path
import json
import random
from PIL import Image
import time

class ArtWallManager:
    def __init__(self):
        self.met_api_base = "https://collectionapi.metmuseum.org/public/collection/v1"
        self.wallpaper_dir = Path.home() / "Pictures" / "ArtWall"
        self.wallpaper_dir.mkdir(exist_ok=True)
        
        # Settings (hardcoded for now, will become user settings later)
        self.settings = {
            'focus_on_paintings': True,
            'min_image_width': 800,  # Reduced from 1200
            'min_image_height': 600,  # Reduced from 800
            'preferred_aspect_ratios': [(16, 10), (16, 9), (4, 3), (3, 2), (5, 4)],  # Common desktop ratios
            'aspect_ratio_tolerance': 0.4,  # Increased from 0.2 to 0.4 (40% variance)
            'exclude_keywords': ['fragment', 'fragments', 'shard', 'shards', 'piece of', 'part of'],
            'preferred_departments': ['American Decorative Arts', 'American Paintings and Sculpture', 
                                    'European Paintings', 'Modern Art', 'Contemporary Art', 'Asian Art',
                                    'European Sculpture and Decorative Arts', 'Islamic Art'],
            'same_image_all_displays': True  # For multi-monitor setup
        }
    
    def get_random_artwork_ids(self, count=10):
        """Fetch random artwork IDs from The Met's collection"""
        # Get all object IDs (this is a large list)
        print(f"Calling Met API: {self.met_api_base}/objects")
        response = requests.get(f"{self.met_api_base}/objects")
        print(f"API response status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            all_ids = data.get("objectIDs", [])
            print(f"Total objects in Met collection: {len(all_ids)}")
            if all_ids:
                # Return random sample
                sample_size = min(count, len(all_ids))
                return random.sample(all_ids, sample_size)
        else:
            print(f"API error: {response.status_code} - {response.text}")
        return []
    
    def get_artwork_details(self, object_id):
        """Get detailed information about a specific artwork"""
        response = requests.get(f"{self.met_api_base}/objects/{object_id}")
        if response.status_code == 200:
            return response.json()
        return None
    
    def is_suitable_artwork(self, artwork):
        """Filter artwork based on our quality criteria"""
        if not artwork or not artwork.get("primaryImage"):
            return False, "No primary image"
        
        # Must be public domain
        if not artwork.get("isPublicDomain"):
            return False, "Not public domain"
        
        # Check title for fragments/pieces
        title = artwork.get("title", "").lower()
        for keyword in self.settings['exclude_keywords']:
            if keyword in title:
                return False, f"Contains excluded keyword: {keyword}"
        
        # Prefer paintings if setting is enabled
        if self.settings['focus_on_paintings']:
            classification = artwork.get("classification", "").lower()
            object_name = artwork.get("objectName", "").lower()
            department = artwork.get("department", "")
            
            # Accept paintings, drawings, prints, and works from preferred departments
            is_visual_art = any(term in classification for term in ['painting', 'drawing', 'print', 'photograph']) or \
                           any(term in object_name for term in ['painting', 'drawing', 'print', 'photograph']) or \
                           department in self.settings['preferred_departments']
            
            if not is_visual_art:
                return False, f"Not a preferred artwork type: {classification}, {object_name}, {department}"
        
        return True, "Suitable"
    
    def check_image_quality(self, image_url):
        """Check if image meets quality requirements"""
        try:
            # Get image headers to check dimensions without downloading full image
            response = requests.head(image_url)
            if response.status_code != 200:
                return False, "Cannot access image"
            
            # Download a small portion to check actual dimensions
            response = requests.get(image_url, stream=True)
            if response.status_code == 200:
                # Read just enough to get image info
                from io import BytesIO
                partial_data = BytesIO()
                downloaded = 0
                for chunk in response.iter_content(chunk_size=8192):
                    partial_data.write(chunk)
                    downloaded += len(chunk)
                    if downloaded > 50000:  # 50KB should be enough for headers
                        break
                
                partial_data.seek(0)
                try:
                    with Image.open(partial_data) as img:
                        width, height = img.size
                        
                        # Check minimum dimensions
                        if width < self.settings['min_image_width'] or height < self.settings['min_image_height']:
                            return False, f"Image too small: {width}x{height}"
                        
                        # Check aspect ratio
                        image_ratio = width / height
                        suitable_ratio = False
                        
                        for pref_w, pref_h in self.settings['preferred_aspect_ratios']:
                            pref_ratio = pref_w / pref_h
                            if abs(image_ratio - pref_ratio) <= self.settings['aspect_ratio_tolerance']:
                                suitable_ratio = True
                                break
                        
                        if not suitable_ratio:
                            return False, f"Aspect ratio not suitable: {image_ratio:.2f}"
                        
                        return True, f"Good quality: {width}x{height}, ratio: {image_ratio:.2f}"
                        
                except Exception as e:
                    return False, f"Cannot analyze image: {e}"
            
            return False, "Cannot download image for analysis"
            
        except Exception as e:
            return False, f"Error checking image quality: {e}"
    
    def download_image(self, image_url, filename):
        """Download and save an image"""
        try:
            response = requests.get(image_url, stream=True)
            if response.status_code == 200:
                filepath = self.wallpaper_dir / filename
                with open(filepath, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                return filepath
        except Exception as e:
            print(f"Error downloading image: {e}")
        return None
    
    def set_wallpaper_folder(self):
        """Configure macOS to use our wallpaper folder with rotation"""
        # This is a placeholder - actual implementation would use AppleScript
        # or system calls to configure Desktop & Screen Saver settings
        print(f"Wallpaper folder ready at: {self.wallpaper_dir}")
        print("To set up rotation:")
        print("1. Go to System Settings > Wallpaper")
        print("2. Click 'Add Folder or Album' > 'Choose Folder'")
        print(f"3. Select: {self.wallpaper_dir}")
        print("4. Enable 'Rotate' and set your preferred interval")
    
    def fetch_artworks(self, count=5):
        """Main method to fetch and save artworks with quality filtering"""
        print(f"Fetching {count} high-quality paintings from The Met...")
        print("Filtering for: paintings, good aspect ratios, high resolution")
        
        # Get more IDs since we'll be filtering heavily
        artwork_ids = self.get_random_artwork_ids(count * 10)
        print(f"Retrieved {len(artwork_ids)} artwork IDs from the API")
        
        if not artwork_ids:
            print("ERROR: No artwork IDs retrieved from Met API")
            return 0
        
        downloaded = 0
        checked = 0
        
        for artwork_id in artwork_ids:
            if downloaded >= count:
                break
            
            checked += 1
            if checked % 10 == 0:
                print(f"Checked {checked} artworks, downloaded {downloaded} suitable ones...")
                
            artwork = self.get_artwork_details(artwork_id)
            
            # First filter: basic artwork suitability
            suitable, reason = self.is_suitable_artwork(artwork)
            if not suitable:
                continue
            
            # Second filter: image quality
            image_url = artwork["primaryImage"]
            quality_ok, quality_reason = self.check_image_quality(image_url)
            if not quality_ok:
                continue
            
            # If we get here, the artwork passed all filters
            title = artwork.get("title", "Unknown")
            artist = artwork.get("artistDisplayName", "Unknown Artist")
            department = artwork.get("department", "Unknown Department")
            
            # Create safe filename
            safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
            filename = f"{artwork_id}_{safe_title[:50]}.jpg"
            
            print(f"✓ Downloading: {title} by {artist} ({department})")
            print(f"  Quality: {quality_reason}")
            
            if self.download_image(image_url, filename):
                downloaded += 1
            
            # Be nice to the API
            time.sleep(0.5)
        
        print(f"\nDownloaded {downloaded} high-quality artworks to {self.wallpaper_dir}")
        print(f"Checked {checked} total artworks to find {downloaded} suitable ones")
        
        if self.settings['same_image_all_displays']:
            print("\nNote: For multi-monitor setup, manually select the same image for all displays")
            print("Or use a tool like 'desktoppr' for automatic same-image-all-displays")
        
        return downloaded

def main():
    art_manager = ArtWallManager()
    
    # Fetch some initial artworks
    count = art_manager.fetch_artworks(10)
    
    if count > 0:
        art_manager.set_wallpaper_folder()
    else:
        print("No artworks were downloaded. Please check your internet connection.")

if __name__ == "__main__":
    main()
