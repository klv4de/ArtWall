#!/usr/bin/env python3
"""
Chicago Art Institute Complete Database Builder (Fixed Version)
Converts all 134k+ artwork JSON files into a comprehensive SQLite database.
"""

import json
import sqlite3
import os
from pathlib import Path
import logging

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
            alt_titles TEXT,
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
            alt_artist_ids TEXT,
            artist_ids TEXT,
            artist_titles TEXT,
            
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
            dimensions_detail TEXT,
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
            category_ids TEXT,
            category_titles TEXT,
            term_titles TEXT,
            
            -- Style
            style_id INTEGER,
            style_title TEXT,
            alt_style_ids TEXT,
            style_ids TEXT,
            style_titles TEXT,
            
            -- Classification details
            classification_id TEXT,
            classification_title TEXT,
            alt_classification_ids TEXT,
            classification_ids TEXT,
            classification_titles TEXT,
            
            -- Subject matter
            subject_id INTEGER,
            alt_subject_ids TEXT,
            subject_ids TEXT,
            subject_titles TEXT,
            
            -- Materials
            material_id TEXT,
            alt_material_ids TEXT,
            material_ids TEXT,
            material_titles TEXT,
            
            -- Techniques
            technique_id INTEGER,
            alt_technique_ids TEXT,
            technique_ids TEXT,
            technique_titles TEXT,
            
            -- Themes
            theme_titles TEXT,
            
            -- Images and media
            image_id TEXT,
            alt_image_ids TEXT,
            thumbnail_lqip TEXT,
            thumbnail_width INTEGER,
            thumbnail_height INTEGER,
            thumbnail_alt_text TEXT,
            
            -- Related content
            document_ids TEXT,
            sound_ids TEXT,
            video_ids TEXT,
            text_ids TEXT,
            section_ids TEXT,
            section_titles TEXT,
            site_ids TEXT,
            
            -- Search and autocomplete
            suggest_autocomplete_all TEXT,
            
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
        
    def safe_json_dumps(self, obj):
        """Safely convert object to JSON string"""
        if obj is None:
            return None
        try:
            return json.dumps(obj)
        except (TypeError, ValueError):
            return str(obj)
    
    def process_artworks(self):
        """Process all artwork JSON files and insert into database"""
        artwork_files = list(self.json_dir.glob("*.json"))
        total_files = len(artwork_files)
        
        logger.info(f"Processing {total_files} artwork files...")
        
        processed = 0
        errors = 0
        
        for json_file in artwork_files:
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    artwork_data = json.load(f)
                
                # Handle thumbnail and color data
                thumbnail = artwork_data.get('thumbnail', {}) or {}
                color = artwork_data.get('color', {}) or {}
                
                # Insert artwork data using named parameters for clarity
                self.conn.execute("""
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
                    ) VALUES (
                        :id, :api_model, :api_link, :main_reference_number,
                        :title, :alt_titles, :is_boosted, :has_not_been_viewed_much, :boost_rank,
                        :date_start, :date_end, :date_display, :date_qualifier_title, :date_qualifier_id,
                        :artist_display, :artist_id, :artist_title, :alt_artist_ids, :artist_ids, :artist_titles,
                        :place_of_origin, :latitude, :longitude, :latlon,
                        :description, :short_description,
                        :dimensions, :dimensions_detail, :medium_display, :inscriptions,
                        :credit_line, :catalogue_display, :publication_history, :exhibition_history,
                        :provenance_text, :edition, :publishing_verification_level, :internal_department_id,
                        :fiscal_year, :fiscal_year_deaccession,
                        :is_public_domain, :is_zoomable, :max_zoom_window_size, :copyright_notice,
                        :has_multimedia_resources, :has_educational_resources, :has_advanced_imaging,
                        :colorfulness, :color_h, :color_l, :color_s, :color_percentage, :color_population,
                        :is_on_view, :on_loan_display, :gallery_title, :gallery_id,
                        :nomisma_id,
                        :artwork_type_title, :artwork_type_id, :department_title, :department_id,
                        :category_ids, :category_titles, :term_titles,
                        :style_id, :style_title, :alt_style_ids, :style_ids, :style_titles,
                        :classification_id, :classification_title, :alt_classification_ids,
                        :classification_ids, :classification_titles,
                        :subject_id, :alt_subject_ids, :subject_ids, :subject_titles,
                        :material_id, :alt_material_ids, :material_ids, :material_titles,
                        :technique_id, :alt_technique_ids, :technique_ids, :technique_titles,
                        :theme_titles,
                        :image_id, :alt_image_ids, :thumbnail_lqip, :thumbnail_width,
                        :thumbnail_height, :thumbnail_alt_text,
                        :document_ids, :sound_ids, :video_ids, :text_ids, :section_ids,
                        :section_titles, :site_ids,
                        :suggest_autocomplete_all,
                        :source_updated_at, :updated_at, :timestamp
                    )
                """, {
                    'id': artwork_data.get('id'),
                    'api_model': artwork_data.get('api_model'),
                    'api_link': artwork_data.get('api_link'),
                    'main_reference_number': artwork_data.get('main_reference_number'),
                    
                    'title': artwork_data.get('title'),
                    'alt_titles': self.safe_json_dumps(artwork_data.get('alt_titles')),
                    'is_boosted': artwork_data.get('is_boosted'),
                    'has_not_been_viewed_much': artwork_data.get('has_not_been_viewed_much'),
                    'boost_rank': artwork_data.get('boost_rank'),
                    
                    'date_start': artwork_data.get('date_start'),
                    'date_end': artwork_data.get('date_end'),
                    'date_display': artwork_data.get('date_display'),
                    'date_qualifier_title': artwork_data.get('date_qualifier_title'),
                    'date_qualifier_id': artwork_data.get('date_qualifier_id'),
                    
                    'artist_display': artwork_data.get('artist_display'),
                    'artist_id': artwork_data.get('artist_id'),
                    'artist_title': artwork_data.get('artist_title'),
                    'alt_artist_ids': self.safe_json_dumps(artwork_data.get('alt_artist_ids')),
                    'artist_ids': self.safe_json_dumps(artwork_data.get('artist_ids')),
                    'artist_titles': self.safe_json_dumps(artwork_data.get('artist_titles')),
                    
                    'place_of_origin': artwork_data.get('place_of_origin'),
                    'latitude': artwork_data.get('latitude'),
                    'longitude': artwork_data.get('longitude'),
                    'latlon': artwork_data.get('latlon'),
                    
                    'description': artwork_data.get('description'),
                    'short_description': artwork_data.get('short_description'),
                    
                    'dimensions': artwork_data.get('dimensions'),
                    'dimensions_detail': self.safe_json_dumps(artwork_data.get('dimensions_detail')),
                    'medium_display': artwork_data.get('medium_display'),
                    'inscriptions': artwork_data.get('inscriptions'),
                    
                    'credit_line': artwork_data.get('credit_line'),
                    'catalogue_display': artwork_data.get('catalogue_display'),
                    'publication_history': artwork_data.get('publication_history'),
                    'exhibition_history': artwork_data.get('exhibition_history'),
                    'provenance_text': artwork_data.get('provenance_text'),
                    'edition': artwork_data.get('edition'),
                    'publishing_verification_level': artwork_data.get('publishing_verification_level'),
                    'internal_department_id': artwork_data.get('internal_department_id'),
                    'fiscal_year': artwork_data.get('fiscal_year'),
                    'fiscal_year_deaccession': artwork_data.get('fiscal_year_deaccession'),
                    
                    'is_public_domain': artwork_data.get('is_public_domain'),
                    'is_zoomable': artwork_data.get('is_zoomable'),
                    'max_zoom_window_size': artwork_data.get('max_zoom_window_size'),
                    'copyright_notice': artwork_data.get('copyright_notice'),
                    
                    'has_multimedia_resources': artwork_data.get('has_multimedia_resources'),
                    'has_educational_resources': artwork_data.get('has_educational_resources'),
                    'has_advanced_imaging': artwork_data.get('has_advanced_imaging'),
                    
                    'colorfulness': artwork_data.get('colorfulness'),
                    'color_h': color.get('h'),
                    'color_l': color.get('l'),
                    'color_s': color.get('s'),
                    'color_percentage': color.get('percentage'),
                    'color_population': color.get('population'),
                    
                    'is_on_view': artwork_data.get('is_on_view'),
                    'on_loan_display': artwork_data.get('on_loan_display'),
                    'gallery_title': artwork_data.get('gallery_title'),
                    'gallery_id': artwork_data.get('gallery_id'),
                    
                    'nomisma_id': artwork_data.get('nomisma_id'),
                    
                    'artwork_type_title': artwork_data.get('artwork_type_title'),
                    'artwork_type_id': artwork_data.get('artwork_type_id'),
                    'department_title': artwork_data.get('department_title'),
                    'department_id': artwork_data.get('department_id'),
                    
                    'category_ids': self.safe_json_dumps(artwork_data.get('category_ids')),
                    'category_titles': self.safe_json_dumps(artwork_data.get('category_titles')),
                    'term_titles': self.safe_json_dumps(artwork_data.get('term_titles')),
                    
                    'style_id': artwork_data.get('style_id'),
                    'style_title': artwork_data.get('style_title'),
                    'alt_style_ids': self.safe_json_dumps(artwork_data.get('alt_style_ids')),
                    'style_ids': self.safe_json_dumps(artwork_data.get('style_ids')),
                    'style_titles': self.safe_json_dumps(artwork_data.get('style_titles')),
                    
                    'classification_id': artwork_data.get('classification_id'),
                    'classification_title': artwork_data.get('classification_title'),
                    'alt_classification_ids': self.safe_json_dumps(artwork_data.get('alt_classification_ids')),
                    'classification_ids': self.safe_json_dumps(artwork_data.get('classification_ids')),
                    'classification_titles': self.safe_json_dumps(artwork_data.get('classification_titles')),
                    
                    'subject_id': artwork_data.get('subject_id'),
                    'alt_subject_ids': self.safe_json_dumps(artwork_data.get('alt_subject_ids')),
                    'subject_ids': self.safe_json_dumps(artwork_data.get('subject_ids')),
                    'subject_titles': self.safe_json_dumps(artwork_data.get('subject_titles')),
                    
                    'material_id': artwork_data.get('material_id'),
                    'alt_material_ids': self.safe_json_dumps(artwork_data.get('alt_material_ids')),
                    'material_ids': self.safe_json_dumps(artwork_data.get('material_ids')),
                    'material_titles': self.safe_json_dumps(artwork_data.get('material_titles')),
                    
                    'technique_id': artwork_data.get('technique_id'),
                    'alt_technique_ids': self.safe_json_dumps(artwork_data.get('alt_technique_ids')),
                    'technique_ids': self.safe_json_dumps(artwork_data.get('technique_ids')),
                    'technique_titles': self.safe_json_dumps(artwork_data.get('technique_titles')),
                    
                    'theme_titles': self.safe_json_dumps(artwork_data.get('theme_titles')),
                    
                    'image_id': artwork_data.get('image_id'),
                    'alt_image_ids': self.safe_json_dumps(artwork_data.get('alt_image_ids')),
                    'thumbnail_lqip': thumbnail.get('lqip'),
                    'thumbnail_width': thumbnail.get('width'),
                    'thumbnail_height': thumbnail.get('height'),
                    'thumbnail_alt_text': thumbnail.get('alt_text'),
                    
                    'document_ids': self.safe_json_dumps(artwork_data.get('document_ids')),
                    'sound_ids': self.safe_json_dumps(artwork_data.get('sound_ids')),
                    'video_ids': self.safe_json_dumps(artwork_data.get('video_ids')),
                    'text_ids': self.safe_json_dumps(artwork_data.get('text_ids')),
                    'section_ids': self.safe_json_dumps(artwork_data.get('section_ids')),
                    'section_titles': self.safe_json_dumps(artwork_data.get('section_titles')),
                    'site_ids': self.safe_json_dumps(artwork_data.get('site_ids')),
                    
                    'suggest_autocomplete_all': self.safe_json_dumps(artwork_data.get('suggest_autocomplete_all')),
                    
                    'source_updated_at': artwork_data.get('source_updated_at'),
                    'updated_at': artwork_data.get('updated_at'),
                    'timestamp': artwork_data.get('timestamp')
                })
                
                processed += 1
                
                # Progress update every 1000 files
                if processed % 1000 == 0:
                    logger.info(f"Processed {processed}/{total_files} artworks ({processed/total_files*100:.1f}%)")
                    self.conn.commit()  # Commit periodically
                    
            except Exception as e:
                errors += 1
                if errors <= 5:  # Show first few errors
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
    
    # Remove old database if it exists
    if os.path.exists(db_path):
        os.remove(db_path)
        print(f"Removed old database: {db_path}")
    
    # Build database
    builder = ArtworksDatabaseBuilder(json_dir, db_path)
    builder.build_database()
    
    print("\n🎉 Complete Chicago Art Institute database ready!")
    print(f"📁 Location: {db_path}")
    print("💡 Now you can query 134k+ artworks with ALL metadata instantly!")

if __name__ == "__main__":
    main()
