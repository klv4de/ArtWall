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
            'exclude_keywords': ['fragment', 'fragments', 'shard', 'shards', 'piece of', 'part of',
                                'coin', 'weight', 'button', 'bead', 'sample', 'textile sample',
                                'bowl', 'cup', 'vessel', 'pot', 'jar', 'plate', 'dish'],
            'preferred_departments': ['American Paintings and Sculpture', 'European Paintings', 
                                    'Modern Art', 'Contemporary Art', 'Drawings and Prints',
                                    'Photographs', 'The American Wing'],
            'avoid_departments': ['Arms and Armor', 'Egyptian Art', 'Greek and Roman Art', 
                                'Medieval Art', 'Musical Instruments'],
            'same_image_all_displays': True,  # For multi-monitor setup
            
            # Rate limiting and collection size settings
            'api_delay_seconds': 2.0,  # Increased from 0.5 to 2 seconds between API calls
            'max_retries': 3,  # Number of times to retry failed API calls
            'daily_target': 48,  # Images needed for 30-min rotation, 24 hours
            'batch_size': 20,  # How many to try to get in each run
            'max_api_calls_per_session': 200  # Limit API calls to avoid rate limiting
        }
    
    def get_department_artwork_ids(self, department_id=11, count=100):
        """Fetch artwork IDs from a specific department (default: European Paintings)"""
        # Search for objects in European Paintings department with images
        search_url = f"{self.met_api_base}/search?departmentId={department_id}&hasImages=true&isPublicDomain=true"
        print(f"Calling Met API: {search_url}")
        response = requests.get(search_url)
        print(f"API response status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            all_ids = data.get("objectIDs", [])
            print(f"Total objects in European Paintings department: {len(all_ids)}")
            if all_ids:
                # Return random sample from department
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
    
    def get_current_collection_size(self):
        """Count how many images we currently have"""
        image_files = list(self.wallpaper_dir.glob("*.jpg")) + list(self.wallpaper_dir.glob("*.jpeg")) + list(self.wallpaper_dir.glob("*.png"))
        return len(image_files)
    
    def get_collection_progress(self):
        """Get progress toward daily target"""
        current = self.get_current_collection_size()
        target = self.settings['daily_target']
        percentage = (current / target) * 100 if target > 0 else 0
        return current, target, percentage
    
    def is_suitable_artwork(self, artwork):
        """Filter artwork based on our quality criteria"""
        if not artwork or not artwork.get("primaryImage"):
            return False, "No primary image"
        
        # Must be public domain
        if not artwork.get("isPublicDomain"):
            return False, "Not public domain"
        
        # Check title for fragments/pieces and small objects
        title = artwork.get("title", "").lower()
        for keyword in self.settings['exclude_keywords']:
            if keyword in title:
                return False, f"Contains excluded keyword: {keyword}"
        
        # Check object name for small objects and utilitarian items
        object_name = artwork.get("objectName", "").lower()
        for keyword in self.settings['exclude_keywords']:
            if keyword in object_name:
                return False, f"Object type excluded: {object_name}"
        
        # Exclude very small objects that are likely museum specimens
        dimensions = artwork.get("dimensions", "")
        if dimensions and any(term in dimensions.lower() for term in ['cm', 'inches']):
            # Look for very small dimensions (less than 6 inches / 15 cm in any direction)
            import re
            numbers = re.findall(r'(\d+(?:\.\d+)?)\s*(?:cm|inches|in\.)', dimensions.lower())
            if numbers:
                try:
                    sizes = [float(num) for num in numbers]
                    # If any dimension is very small (likely a coin, button, etc.)
                    if any(size < 6 for size in sizes) and 'cm' in dimensions.lower():
                        return False, f"Object too small: {dimensions}"
                    if any(size < 2.5 for size in sizes) and ('inches' in dimensions.lower() or 'in.' in dimensions.lower()):
                        return False, f"Object too small: {dimensions}"
                except ValueError:
                    pass
        
        # Prefer paintings if setting is enabled
        if self.settings['focus_on_paintings']:
            classification = artwork.get("classification", "").lower()
            object_name = artwork.get("objectName", "").lower()
            department = artwork.get("department", "")
            
            # Avoid certain departments known for small objects
            if department in self.settings['avoid_departments']:
                return False, f"Department avoided: {department}"
            
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
    
    def fetch_artworks(self, count=None):
        """Main method to fetch and save artworks with quality filtering and rate limiting"""
        # Check current progress
        current, target, percentage = self.get_collection_progress()
        print(f"🎨 ArtWall Collection Progress: {current}/{target} images ({percentage:.1f}%)")
        
        if count is None:
            count = self.settings['batch_size']
        
        if current >= target:
            print(f"✅ Collection complete! You have {current} images for a full week of 30-minute rotations.")
            return 0
        
        remaining_needed = target - current
        actual_count = min(count, remaining_needed)
        
        print(f"Fetching {actual_count} high-quality paintings from The Met...")
        print("Filtering for: paintings, good aspect ratios, high resolution, no small objects")
        print(f"Rate limiting: {self.settings['api_delay_seconds']}s between API calls")
        
        # Get more IDs since we'll be filtering heavily, but limit total API calls
        max_to_check = min(self.settings['max_api_calls_per_session'], actual_count * 20)
        artwork_ids = self.get_department_artwork_ids(department_id=11, count=max_to_check)
        print(f"Retrieved {len(artwork_ids)} artwork IDs from the API")
        
        if not artwork_ids:
            print("ERROR: No artwork IDs retrieved from Met API (possible rate limiting)")
            print("Try again in a few minutes, or the API may be temporarily unavailable.")
            return 0
        
        downloaded = 0
        checked = 0
        
        for artwork_id in artwork_ids:
            if downloaded >= actual_count:
                break
            
            if checked >= max_to_check:
                print("Reached maximum API calls for this session to avoid rate limiting.")
                break
            
            checked += 1
            if checked % 10 == 0:
                print(f"Checked {checked} artworks, downloaded {downloaded} suitable ones...")
                
            artwork = self.get_artwork_details(artwork_id)
            
            # First filter: basic artwork suitability
            suitable, reason = self.is_suitable_artwork(artwork)
            if not suitable:
                # Rate limiting between API calls
                time.sleep(self.settings['api_delay_seconds'])
                continue
            
            # Second filter: image quality
            image_url = artwork["primaryImage"]
            quality_ok, quality_reason = self.check_image_quality(image_url)
            if not quality_ok:
                # Rate limiting between API calls
                time.sleep(self.settings['api_delay_seconds'])
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
                # Update progress after each successful download
                new_current, _, new_percentage = self.get_collection_progress()
                print(f"  Progress: {new_current}/{target} images ({new_percentage:.1f}%)")
            
            # Rate limiting between API calls
            time.sleep(self.settings['api_delay_seconds'])
        
        final_current, _, final_percentage = self.get_collection_progress()
        print(f"\n📊 Session Summary:")
        print(f"Downloaded {downloaded} high-quality artworks to {self.wallpaper_dir}")
        print(f"Checked {checked} total artworks to find {downloaded} suitable ones")
        print(f"Collection progress: {final_current}/{target} images ({final_percentage:.1f}%)")
        
        if final_current < target:
            remaining = target - final_current
            print(f"Still need {remaining} more images for a full week of wallpapers.")
            print("Run the script again to continue building your collection!")
        
        if self.settings['same_image_all_displays']:
            print("\nNote: For multi-monitor setup, manually select the same image for all displays")
            print("Or use a tool like 'desktoppr' for automatic same-image-all-displays")
        
        return downloaded

def main():
    art_manager = ArtWallManager()
    
    # Show current collection status
    current, target, percentage = art_manager.get_collection_progress()
    
    if current == 0:
        print("🎨 Welcome to ArtWall! Building your fine art collection...")
        print(f"Target: {target} images for 30-minute rotations, 24/7 for a week")
        print("This will take multiple runs due to API rate limiting and selective filtering.")
    
    # Fetch artworks using default batch size
    count = art_manager.fetch_artworks()
    
    if count > 0:
        art_manager.set_wallpaper_folder()
    elif current == 0:
        print("No artworks were downloaded. The API may be rate-limited.")
        print("Please try again in a few minutes.")
    
    # Show final status
    final_current, _, final_percentage = art_manager.get_collection_progress()
    if final_current >= target:
        print(f"\n🎉 Congratulations! Your collection is complete with {final_current} images!")
        print("You can now enjoy a full week of rotating fine art wallpapers!")

if __name__ == "__main__":
    main()
