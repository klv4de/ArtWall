#!/usr/bin/env python3
"""
Chicago Art Institute Complete Database Builder
Converts all 134k+ artwork JSON files into a comprehensive SQLite database
with ALL fields preserved for maximum flexibility.
"""

import json
import sqlite3
import os
from pathlib import Path
import logging
from typing import Dict, Any, List, Optional

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ArtworksDatabaseBuilder:
    def __init__(self, json_dir: str, db_path: str):
        self.json_dir = Path(json_dir)
        self.db_path = db_path
        self.conn = None
        
    def create_database_schema(self):
        """Create comprehensive database schema with ALL fields from JSON"""
        logger.info("Creating comprehensive database schema...")
        
        schema_sql = """
        CREATE TABLE IF NOT EXISTS artworks (
            -- Core identifiers
            id INTEGER PRIMARY KEY,
            api_model TEXT,
            api_link TEXT,
            main_reference_number TEXT,
            
            -- Basic artwork info
            title TEXT,
            alt_titles TEXT, -- JSON array as text
            is_boosted BOOLEAN,
            has_not_been_viewed_much BOOLEAN,
            boost_rank INTEGER,
            
            -- Dates
            date_start INTEGER,
            date_end INTEGER,
            date_display TEXT,
            date_qualifier_title TEXT,
            date_qualifier_id INTEGER,
            
            -- Artist information
            artist_display TEXT,
            artist_id INTEGER,
            artist_title TEXT,
            alt_artist_ids TEXT, -- JSON array as text
            artist_ids TEXT, -- JSON array as text
            artist_titles TEXT, -- JSON array as text
            
            -- Location and origin
            place_of_origin TEXT,
            latitude REAL,
            longitude REAL,
            latlon TEXT,
            
            -- Descriptions
            description TEXT,
            short_description TEXT,
            
            -- Physical properties
            dimensions TEXT,
            dimensions_detail TEXT, -- JSON as text
            medium_display TEXT,
            inscriptions TEXT,
            
            -- Museum metadata
            credit_line TEXT,
            catalogue_display TEXT,
            publication_history TEXT,
            exhibition_history TEXT,
            provenance_text TEXT,
            edition TEXT,
            publishing_verification_level TEXT,
            internal_department_id INTEGER,
            fiscal_year INTEGER,
            fiscal_year_deaccession INTEGER,
            
            -- Rights and access
            is_public_domain BOOLEAN,
            is_zoomable BOOLEAN,
            max_zoom_window_size INTEGER,
            copyright_notice TEXT,
            
            -- Multimedia flags
            has_multimedia_resources BOOLEAN,
            has_educational_resources BOOLEAN,
            has_advanced_imaging BOOLEAN,
            
            -- Visual properties
            colorfulness REAL,
            color_h INTEGER,
            color_l INTEGER,
            color_s INTEGER,
            color_percentage REAL,
            color_population INTEGER,
            
            -- Display status
            is_on_view BOOLEAN,
            on_loan_display TEXT,
            gallery_title TEXT,
            gallery_id INTEGER,
            
            -- External references
            nomisma_id TEXT,
            
            -- Classification
            artwork_type_title TEXT,
            artwork_type_id INTEGER,
            department_title TEXT,
            department_id TEXT,
            
            -- Categories and terms
            category_ids TEXT, -- JSON array as text
            category_titles TEXT, -- JSON array as text
            term_titles TEXT, -- JSON array as text
            
            -- Style
            style_id INTEGER,
            style_title TEXT,
            alt_style_ids TEXT, -- JSON array as text
            style_ids TEXT, -- JSON array as text
            style_titles TEXT, -- JSON array as text
            
            -- Classification details
            classification_id TEXT,
            classification_title TEXT,
            alt_classification_ids TEXT, -- JSON array as text
            classification_ids TEXT, -- JSON array as text
            classification_titles TEXT, -- JSON array as text
            
            -- Subject matter
            subject_id INTEGER,
            alt_subject_ids TEXT, -- JSON array as text
            subject_ids TEXT, -- JSON array as text
            subject_titles TEXT, -- JSON array as text
            
            -- Materials
            material_id TEXT,
            alt_material_ids TEXT, -- JSON array as text
            material_ids TEXT, -- JSON array as text
            material_titles TEXT, -- JSON array as text
            
            -- Techniques
            technique_id INTEGER,
            alt_technique_ids TEXT, -- JSON array as text
            technique_ids TEXT, -- JSON array as text
            technique_titles TEXT, -- JSON array as text
            
            -- Themes
            theme_titles TEXT, -- JSON array as text
            
            -- Images and media
            image_id TEXT,
            alt_image_ids TEXT, -- JSON array as text
            thumbnail_lqip TEXT,
            thumbnail_width INTEGER,
            thumbnail_height INTEGER,
            thumbnail_alt_text TEXT,
            
            -- Related content
            document_ids TEXT, -- JSON array as text
            sound_ids TEXT, -- JSON array as text
            video_ids TEXT, -- JSON array as text
            text_ids TEXT, -- JSON array as text
            section_ids TEXT, -- JSON array as text
            section_titles TEXT, -- JSON array as text
            site_ids TEXT, -- JSON array as text
            
            -- Search and autocomplete
            suggest_autocomplete_all TEXT, -- JSON as text
            
            -- Timestamps
            source_updated_at TEXT,
            updated_at TEXT,
            timestamp TEXT
        );
        
        -- Create indexes for fast querying
        CREATE INDEX IF NOT EXISTS idx_department_title ON artworks(department_title);
        CREATE INDEX IF NOT EXISTS idx_is_public_domain ON artworks(is_public_domain);
        CREATE INDEX IF NOT EXISTS idx_image_id ON artworks(image_id);
        CREATE INDEX IF NOT EXISTS idx_classification_title ON artworks(classification_title);
        CREATE INDEX IF NOT EXISTS idx_artwork_type_title ON artworks(artwork_type_title);
        CREATE INDEX IF NOT EXISTS idx_artist_title ON artworks(artist_title);
        CREATE INDEX IF NOT EXISTS idx_date_start ON artworks(date_start);
        CREATE INDEX IF NOT EXISTS idx_date_end ON artworks(date_end);
        CREATE INDEX IF NOT EXISTS idx_place_of_origin ON artworks(place_of_origin);
        CREATE INDEX IF NOT EXISTS idx_is_on_view ON artworks(is_on_view);
        CREATE INDEX IF NOT EXISTS idx_colorfulness ON artworks(colorfulness);
        """
        
        self.conn.executescript(schema_sql)
        self.conn.commit()
        logger.info("Database schema created successfully")
        
    def safe_json_dumps(self, obj) -> Optional[str]:
        """Safely convert object to JSON string"""
        if obj is None:
            return None
        try:
            return json.dumps(obj)
        except (TypeError, ValueError):
            return str(obj)
    
    def extract_artwork_data(self, artwork_json: Dict[str, Any]) -> tuple:
        """Extract all fields from artwork JSON into database tuple"""
        
        # Handle thumbnail data
        thumbnail = artwork_json.get('thumbnail', {}) or {}
        
        # Handle color data
        color = artwork_json.get('color', {}) or {}
        
        return (
            # Core identifiers
            artwork_json.get('id'),
            artwork_json.get('api_model'),
            artwork_json.get('api_link'),
            artwork_json.get('main_reference_number'),
            
            # Basic artwork info
            artwork_json.get('title'),
            self.safe_json_dumps(artwork_json.get('alt_titles')),
            artwork_json.get('is_boosted'),
            artwork_json.get('has_not_been_viewed_much'),
            artwork_json.get('boost_rank'),
            
            # Dates
            artwork_json.get('date_start'),
            artwork_json.get('date_end'),
            artwork_json.get('date_display'),
            artwork_json.get('date_qualifier_title'),
            artwork_json.get('date_qualifier_id'),
            
            # Artist information
            artwork_json.get('artist_display'),
            artwork_json.get('artist_id'),
            artwork_json.get('artist_title'),
            self.safe_json_dumps(artwork_json.get('alt_artist_ids')),
            self.safe_json_dumps(artwork_json.get('artist_ids')),
            self.safe_json_dumps(artwork_json.get('artist_titles')),
            
            # Location and origin
            artwork_json.get('place_of_origin'),
            artwork_json.get('latitude'),
            artwork_json.get('longitude'),
            artwork_json.get('latlon'),
            
            # Descriptions
            artwork_json.get('description'),
            artwork_json.get('short_description'),
            
            # Physical properties
            artwork_json.get('dimensions'),
            self.safe_json_dumps(artwork_json.get('dimensions_detail')),
            artwork_json.get('medium_display'),
            artwork_json.get('inscriptions'),
            
            # Museum metadata
            artwork_json.get('credit_line'),
            artwork_json.get('catalogue_display'),
            artwork_json.get('publication_history'),
            artwork_json.get('exhibition_history'),
            artwork_json.get('provenance_text'),
            artwork_json.get('edition'),
            artwork_json.get('publishing_verification_level'),
            artwork_json.get('internal_department_id'),
            artwork_json.get('fiscal_year'),
            artwork_json.get('fiscal_year_deaccession'),
            
            # Rights and access
            artwork_json.get('is_public_domain'),
            artwork_json.get('is_zoomable'),
            artwork_json.get('max_zoom_window_size'),
            artwork_json.get('copyright_notice'),
            
            # Multimedia flags
            artwork_json.get('has_multimedia_resources'),
            artwork_json.get('has_educational_resources'),
            artwork_json.get('has_advanced_imaging'),
            
            # Visual properties
            artwork_json.get('colorfulness'),
            color.get('h'),
            color.get('l'),
            color.get('s'),
            color.get('percentage'),
            color.get('population'),
            
            # Display status
            artwork_json.get('is_on_view'),
            artwork_json.get('on_loan_display'),
            artwork_json.get('gallery_title'),
            artwork_json.get('gallery_id'),
            
            # External references
            artwork_json.get('nomisma_id'),
            
            # Classification
            artwork_json.get('artwork_type_title'),
            artwork_json.get('artwork_type_id'),
            artwork_json.get('department_title'),
            artwork_json.get('department_id'),
            
            # Categories and terms
            self.safe_json_dumps(artwork_json.get('category_ids')),
            self.safe_json_dumps(artwork_json.get('category_titles')),
            self.safe_json_dumps(artwork_json.get('term_titles')),
            
            # Style
            artwork_json.get('style_id'),
            artwork_json.get('style_title'),
            self.safe_json_dumps(artwork_json.get('alt_style_ids')),
            self.safe_json_dumps(artwork_json.get('style_ids')),
            self.safe_json_dumps(artwork_json.get('style_titles')),
            
            # Classification details
            artwork_json.get('classification_id'),
            artwork_json.get('classification_title'),
            self.safe_json_dumps(artwork_json.get('alt_classification_ids')),
            self.safe_json_dumps(artwork_json.get('classification_ids')),
            self.safe_json_dumps(artwork_json.get('classification_titles')),
            
            # Subject matter
            artwork_json.get('subject_id'),
            self.safe_json_dumps(artwork_json.get('alt_subject_ids')),
            self.safe_json_dumps(artwork_json.get('subject_ids')),
            self.safe_json_dumps(artwork_json.get('subject_titles')),
            
            # Materials
            artwork_json.get('material_id'),
            self.safe_json_dumps(artwork_json.get('alt_material_ids')),
            self.safe_json_dumps(artwork_json.get('material_ids')),
            self.safe_json_dumps(artwork_json.get('material_titles')),
            
            # Techniques
            artwork_json.get('technique_id'),
            self.safe_json_dumps(artwork_json.get('alt_technique_ids')),
            self.safe_json_dumps(artwork_json.get('technique_ids')),
            self.safe_json_dumps(artwork_json.get('technique_titles')),
            
            # Themes
            self.safe_json_dumps(artwork_json.get('theme_titles')),
            
            # Images and media
            artwork_json.get('image_id'),
            self.safe_json_dumps(artwork_json.get('alt_image_ids')),
            thumbnail.get('lqip'),
            thumbnail.get('width'),
            thumbnail.get('height'),
            thumbnail.get('alt_text'),
            
            # Related content
            self.safe_json_dumps(artwork_json.get('document_ids')),
            self.safe_json_dumps(artwork_json.get('sound_ids')),
            self.safe_json_dumps(artwork_json.get('video_ids')),
            self.safe_json_dumps(artwork_json.get('text_ids')),
            self.safe_json_dumps(artwork_json.get('section_ids')),
            self.safe_json_dumps(artwork_json.get('section_titles')),
            self.safe_json_dumps(artwork_json.get('site_ids')),
            
            # Search and autocomplete
            self.safe_json_dumps(artwork_json.get('suggest_autocomplete_all')),
            
            # Timestamps
            artwork_json.get('source_updated_at'),
            artwork_json.get('updated_at'),
            artwork_json.get('timestamp')
        )
    
    def process_artworks(self):
        """Process all artwork JSON files and insert into database"""
        artwork_files = list(self.json_dir.glob("*.json"))
        total_files = len(artwork_files)
        
        logger.info(f"Processing {total_files} artwork files...")
        
        # Prepare INSERT statement with all fields
        insert_sql = """
        INSERT OR REPLACE INTO artworks (
            id, api_model, api_link, main_reference_number,
            title, alt_titles, is_boosted, has_not_been_viewed_much, boost_rank,
            date_start, date_end, date_display, date_qualifier_title, date_qualifier_id,
            artist_display, artist_id, artist_title, alt_artist_ids, artist_ids, artist_titles,
            place_of_origin, latitude, longitude, latlon,
            description, short_description,
            dimensions, dimensions_detail, medium_display, inscriptions,
            credit_line, catalogue_display, publication_history, exhibition_history, 
            provenance_text, edition, publishing_verification_level, internal_department_id, 
            fiscal_year, fiscal_year_deaccession,
            is_public_domain, is_zoomable, max_zoom_window_size, copyright_notice,
            has_multimedia_resources, has_educational_resources, has_advanced_imaging,
            colorfulness, color_h, color_l, color_s, color_percentage, color_population,
            is_on_view, on_loan_display, gallery_title, gallery_id,
            nomisma_id,
            artwork_type_title, artwork_type_id, department_title, department_id,
            category_ids, category_titles, term_titles,
            style_id, style_title, alt_style_ids, style_ids, style_titles,
            classification_id, classification_title, alt_classification_ids, 
            classification_ids, classification_titles,
            subject_id, alt_subject_ids, subject_ids, subject_titles,
            material_id, alt_material_ids, material_ids, material_titles,
            technique_id, alt_technique_ids, technique_ids, technique_titles,
            theme_titles,
            image_id, alt_image_ids, thumbnail_lqip, thumbnail_width, 
            thumbnail_height, thumbnail_alt_text,
            document_ids, sound_ids, video_ids, text_ids, section_ids, 
            section_titles, site_ids,
            suggest_autocomplete_all,
            source_updated_at, updated_at, timestamp
        ) VALUES (""" + ",".join(["?"] * 105) + ")"
        
        processed = 0
        errors = 0
        
        for json_file in artwork_files:
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    artwork_data = json.load(f)
                
                # Extract all data
                artwork_tuple = self.extract_artwork_data(artwork_data)
                
                # Insert into database
                self.conn.execute(insert_sql, artwork_tuple)
                
                processed += 1
                
                # Progress update every 1000 files
                if processed % 1000 == 0:
                    logger.info(f"Processed {processed}/{total_files} artworks ({processed/total_files*100:.1f}%)")
                    self.conn.commit()  # Commit periodically
                    
            except Exception as e:
                errors += 1
                logger.error(f"Error processing {json_file}: {e}")
                
        # Final commit
        self.conn.commit()
        logger.info(f"Processing complete! {processed} artworks processed, {errors} errors")
        
    def build_database(self):
        """Main method to build the complete database"""
        logger.info("Starting complete Chicago Art Institute database build...")
        
        # Connect to database
        self.conn = sqlite3.connect(self.db_path)
        self.conn.execute("PRAGMA journal_mode=WAL")  # Better performance
        self.conn.execute("PRAGMA synchronous=NORMAL")  # Better performance
        
        try:
            # Create schema
            self.create_database_schema()
            
            # Process all artworks
            self.process_artworks()
            
            # Analyze database for query optimization
            logger.info("Analyzing database for query optimization...")
            self.conn.execute("ANALYZE")
            self.conn.commit()
            
            # Get final statistics
            cursor = self.conn.execute("SELECT COUNT(*) FROM artworks")
            total_count = cursor.fetchone()[0]
            
            # Get database file size
            db_size_mb = os.path.getsize(self.db_path) / (1024 * 1024)
            
            logger.info(f"✅ Database build complete!")
            logger.info(f"📊 Total artworks: {total_count:,}")
            logger.info(f"💾 Database size: {db_size_mb:.1f} MB")
            logger.info(f"🗃️ Database location: {self.db_path}")
            
        finally:
            self.conn.close()

def main():
    # Configuration
    json_dir = "artic-api-data/json/artworks"
    db_path = "chicago_artworks_complete.db"
    
    # Build database
    builder = ArtworksDatabaseBuilder(json_dir, db_path)
    builder.build_database()
    
    print("\n🎉 Complete Chicago Art Institute database ready!")
    print(f"📁 Location: {db_path}")
    print("💡 Now you can query 134k+ artworks with ALL metadata instantly!")

if __name__ == "__main__":
    main()
