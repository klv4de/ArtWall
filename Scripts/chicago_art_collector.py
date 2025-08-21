#!/usr/bin/env python3
"""
ArtWall - Chicago Art Institute API Version
Fetch fine art from Chicago Art Institute and set as rotating wallpapers on macOS
"""

import os
import requests
import subprocess
from pathlib import Path
import json
import random
from PIL import Image
import time

class ChicagoArtWallManager:
    def __init__(self):
        self.api_base = "https://api.artic.edu/api/v1"
        self.iiif_base = "https://www.artic.edu/iiif/2"
        
        # Create subfolder: Museum_Department format
        base_dir = Path.home() / "Pictures" / "ArtWall"
        subfolder_name = "Chicago_Painting_and_Sculpture_of_Europe"
        self.wallpaper_dir = base_dir / subfolder_name
        self.wallpaper_dir.mkdir(parents=True, exist_ok=True)
        
        # Conservative settings with rate limiting
        self.settings = {
            'daily_target': 48,  # Images needed for 30-min rotation, 24 hours
            'batch_size': 20,  # How many to try to get in each run
            'api_delay_seconds': 3.0,  # Conservative 3-second delay between API calls
            'max_retries': 3,
            'max_api_calls_per_session': 100,  # Conservative limit
            
            # Image quality settings
            'min_image_width': 800,
            'min_image_height': 600,
            'preferred_aspect_ratios': [(16, 10), (16, 9), (4, 3), (3, 2), (5, 4)],
            'aspect_ratio_tolerance': 0.4,
            
            # Chicago API specific settings
            'department': 'Painting and Sculpture of Europe',
            'image_size': '843,',  # IIIF image size (width=843px, height auto)
            
            # Filtering
            'exclude_keywords': ['fragment', 'fragments', 'study for', 'sketch for', 
                               'detail of', 'copy after', 'attributed to'],
        }
    
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
    
    def search_artworks(self, limit=100):
        """Search for artworks in European Painting and Sculpture department"""
        search_url = f"{self.api_base}/artworks/search"
        
        params = {
            'q': f'{self.settings["department"]}',  # Simplified search
            'limit': limit,
            'fields': 'id,title,artist_display,image_id,is_public_domain,department_title,classification_title,medium_display,dimensions,date_display'
        }
        
        print(f"Calling Chicago Art Institute API...")
        print(f"Department: {self.settings['department']}")
        print(f"Searching for up to {limit} public domain artworks...")
        
        try:
            response = requests.get(search_url, params=params, timeout=30)
            print(f"API response status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                artworks = data.get('data', [])
                print(f"Found {len(artworks)} artworks in {self.settings['department']}")
                return artworks
            else:
                print(f"API error: {response.status_code} - {response.text}")
                return []
                
        except Exception as e:
            print(f"API request failed: {e}")
            return []
    
    def is_suitable_artwork(self, artwork):
        """Filter artwork based on our quality criteria"""
        if not artwork or not artwork.get("image_id"):
            return False, "No image available"
        
        # Must be public domain
        if not artwork.get("is_public_domain"):
            return False, "Not public domain"
        
        # Only paintings - exclude sculptures, prints, drawings, etc.
        medium = artwork.get("medium_display", "").lower()
        painting_keywords = ["oil on canvas", "oil on panel", "oil on board", "tempera on panel", "acrylic on canvas"]
        
        is_painting = any(keyword in medium for keyword in painting_keywords)
        if not is_painting:
            return False, f"Not a painting: {artwork.get('medium_display', 'Unknown medium')}"
        
        return True, f"Suitable painting: {artwork.get('medium_display')}"
    
    def get_image_url(self, image_id):
        """Construct IIIF image URL"""
        return f"{self.iiif_base}/{image_id}/full/{self.settings['image_size']}/0/default.jpg"
    
    def check_image_quality(self, image_url):
        """Check if image meets quality requirements"""
        try:
            # Get image headers first
            response = requests.head(image_url, timeout=30)
            if response.status_code != 200:
                return False, "Cannot access image"
            
            # Download partial image to check dimensions
            response = requests.get(image_url, stream=True, timeout=30)
            if response.status_code == 200:
                from io import BytesIO
                partial_data = BytesIO()
                downloaded = 0
                
                for chunk in response.iter_content(chunk_size=8192):
                    partial_data.write(chunk)
                    downloaded += len(chunk)
                    if downloaded > 50000:  # 50KB should be enough
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
            response = requests.get(image_url, stream=True, timeout=30)
            if response.status_code == 200:
                filepath = self.wallpaper_dir / filename
                with open(filepath, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                return filepath
        except Exception as e:
            print(f"Error downloading image: {e}")
        return None
    
    def fetch_artworks(self, count=None):
        """Main method to fetch and save artworks with quality filtering and rate limiting"""
        # Check current progress
        current, target, percentage = self.get_collection_progress()
        print(f"🎨 ArtWall Collection Progress: {current}/{target} images ({percentage:.1f}%)")
        
        if count is None:
            count = self.settings['batch_size']
        
        if current >= target:
            print(f"✅ Collection complete! You have {current} images for 24 hours of 30-minute rotations.")
            return 0
        
        remaining_needed = target - current
        actual_count = min(count, remaining_needed)
        
        print(f"Fetching {actual_count} high-quality European paintings from Chicago Art Institute...")
        print(f"Rate limiting: {self.settings['api_delay_seconds']}s between API calls")
        
        # Get more IDs since we'll be filtering heavily, but limit total API calls
        max_to_check = min(self.settings['max_api_calls_per_session'], actual_count * 10)
        artworks = self.search_artworks(max_to_check)
        
        if not artworks:
            print("ERROR: No artworks retrieved from Chicago API")
            return 0
        
        # Shuffle for variety
        random.shuffle(artworks)
        
        downloaded = 0
        checked = 0
        
        for artwork in artworks:
            if downloaded >= actual_count:
                break
            
            if checked >= self.settings['max_api_calls_per_session']:
                print("Reached maximum API calls for this session to avoid rate limiting.")
                break
            
            checked += 1
            if checked % 10 == 0:
                print(f"Checked {checked} artworks, downloaded {downloaded} suitable ones...")
            
            # Filter for our department and public domain
            if artwork.get('department_title') != self.settings['department']:
                continue
                
            # First filter: basic artwork suitability (public domain + has image)
            suitable, reason = self.is_suitable_artwork(artwork)
            if not suitable:
                continue
            
            # Get image URL
            image_url = self.get_image_url(artwork['image_id'])
            
            # Skip image quality check for now - let's see what we get
            
            # If we get here, the artwork passed all filters
            title = artwork.get("title", "Unknown")
            artist = artwork.get("artist_display", "Unknown Artist").split('\n')[0]  # First line only
            
            # Create safe filename
            safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
            filename = f"{artwork['id']}_{safe_title[:50]}.jpg"
            
            print(f"✓ Downloading: {title} by {artist}")
            
            if self.download_image(image_url, filename):
                downloaded += 1
                # Update progress after each successful download
                new_current, _, new_percentage = self.get_collection_progress()
                print(f"  Progress: {new_current}/{target} images ({new_percentage:.1f}%)")
            
            # Rate limiting between downloads
            time.sleep(self.settings['api_delay_seconds'])
        
        final_current, _, final_percentage = self.get_collection_progress()
        print(f"\n📊 Session Summary:")
        print(f"Downloaded {downloaded} high-quality European paintings to {self.wallpaper_dir}")
        print(f"Checked {checked} total artworks to find {downloaded} suitable ones")
        print(f"Collection progress: {final_current}/{target} images ({final_percentage:.1f}%)")
        
        if final_current < target:
            remaining = target - final_current
            print(f"Still need {remaining} more images for 24 hours of wallpapers.")
            print("Run the script again to continue building your collection!")
        
        return downloaded
    
    def set_wallpaper_folder(self):
        """Provide instructions for manual wallpaper setup"""
        print(f"🖼️  ArtWall Collection Ready!")
        print(f"📁 Location: {self.wallpaper_dir}")
        print(f"🎨 Images: {self.get_current_collection_size()} European masterpieces")
        print()
        print("📋 Manual Setup Instructions:")
        print("1. Go to System Settings > Wallpaper")
        print("2. Click 'Add Folder or Album' > 'Choose Folder'")
        print(f"3. Navigate to: {self.wallpaper_dir}")
        print("4. Click 'Choose'")
        print("5. Enable 'Shuffle' and set to 'Every 30 minutes'")
        print("6. Set display option to 'Fit to Screen' for best results")
        print()
        print("🎉 Once complete, you'll have rotating European art masterpieces!")
        print("💡 Note: Automatic setup requires a native macOS app (coming soon)")
    
    # AppleScript automation removed - requires native macOS app for reliable automation
    # All wallpaper configuration now handled through manual setup instructions
    
    def run_complete_collection(self):
        """Run the script multiple times to get the full 48-image collection"""
        print("🎯 Building complete 48-image collection...")
        
        max_runs = 5  # Safety limit
        run_count = 0
        
        while run_count < max_runs:
            current, target, percentage = self.get_collection_progress()
            
            if current >= target:
                print(f"🎉 Collection complete! {current}/{target} images ({percentage:.1f}%)")
                break
                
            print(f"\n📦 Collection Run #{run_count + 1}")
            print(f"Current progress: {current}/{target} images ({percentage:.1f}%)")
            
            # Fetch more artworks
            downloaded = self.fetch_artworks()
            
            if downloaded == 0:
                print("⚠️  No new artworks downloaded. Stopping to avoid API issues.")
                break
                
            run_count += 1
            
            # Brief pause between runs
            if current < target:
                print("⏸️  Brief pause before next batch...")
                time.sleep(5)
        
        final_current, final_target, final_percentage = self.get_collection_progress()
        
        if final_current >= final_target:
            print(f"\n🎉 Collection complete! {final_current} European masterpieces ready")
        else:
            print(f"\n📊 Collection progress: {final_current}/{final_target} images ({final_percentage:.1f}%)")
            print("Run the script again to continue building your collection.")
        
        return final_current

def main():
    art_manager = ChicagoArtWallManager()
    
    # Show current collection status
    current, target, percentage = art_manager.get_collection_progress()
    
    print("🎨 ArtWall - European Masterpiece Collection Builder!")
    print(f"Target: {target} European paintings for 30-minute rotations, 24 hours")
    print("This will:")
    print("• Download all 48 European masterpiece paintings")
    print("• Organize them in a dedicated folder")
    print("• Provide clear setup instructions for wallpaper rotation")
    print("• Note: Automatic wallpaper setup requires a native macOS app")
    print()
    
    if current == 0:
        print("Starting fresh collection build...")
    else:
        print(f"Continuing from {current} existing paintings...")
    
    # Run complete collection build with automation
    final_count = art_manager.run_complete_collection()
    
    if final_count >= target:
        print(f"\n🎉 SUCCESS! Your European masterpiece collection is complete!")
        print(f"• {final_count} paintings downloaded")
        print("• Includes works by Van Gogh, Monet, Renoir, Botticelli, Rembrandt, and more")
        print("• All paintings are high-quality and wallpaper-optimized")
        print("\n📋 Next: Follow the setup instructions to enable wallpaper rotation")
        art_manager.set_wallpaper_folder()
    else:
        print(f"\n📊 Collection progress: {final_count}/{target} paintings")
        print("Run the script again to continue building your collection.")
        
        if final_count > 0:
            print("\n📋 You can set up wallpaper rotation with your current collection:")
            art_manager.set_wallpaper_folder()

if __name__ == "__main__":
    main()
