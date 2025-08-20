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
    
    def get_random_artwork_ids(self, count=10):
        """Fetch random artwork IDs from The Met's collection"""
        # Get all object IDs (this is a large list)
        response = requests.get(f"{self.met_api_base}/objects")
        if response.status_code == 200:
            all_ids = response.json()["objectIDs"]
            # Return random sample
            return random.sample(all_ids, min(count, len(all_ids)))
        return []
    
    def get_artwork_details(self, object_id):
        """Get detailed information about a specific artwork"""
        response = requests.get(f"{self.met_api_base}/objects/{object_id}")
        if response.status_code == 200:
            return response.json()
        return None
    
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
        """Main method to fetch and save artworks"""
        print(f"Fetching {count} artworks from The Met...")
        
        artwork_ids = self.get_random_artwork_ids(count * 3)  # Get more than needed
        downloaded = 0
        
        for artwork_id in artwork_ids:
            if downloaded >= count:
                break
                
            artwork = self.get_artwork_details(artwork_id)
            if not artwork or not artwork.get("primaryImage"):
                continue
            
            # Only download public domain works with images
            if artwork.get("isPublicDomain") and artwork.get("primaryImage"):
                title = artwork.get("title", "Unknown")
                artist = artwork.get("artistDisplayName", "Unknown Artist")
                
                # Create safe filename
                safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
                filename = f"{artwork_id}_{safe_title[:50]}.jpg"
                
                print(f"Downloading: {title} by {artist}")
                if self.download_image(artwork["primaryImage"], filename):
                    downloaded += 1
                
                # Be nice to the API
                time.sleep(0.5)
        
        print(f"Downloaded {downloaded} artworks to {self.wallpaper_dir}")
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
