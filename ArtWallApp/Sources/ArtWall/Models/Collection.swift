import Foundation

// MARK: - GitHub Collection Models (from built collections)
struct GitHubCollection: Codable {
    let collectionId: String
    let title: String
    let description: String
    let dateRange: String
    let artworkCount: Int
    let artworks: [GitHubArtwork]
    let githubReady: Bool
    let imageBaseUrl: String
    
    enum CodingKeys: String, CodingKey {
        case collectionId = "collection_id"
        case title, description
        case dateRange = "date_range"
        case artworkCount = "artwork_count"
        case artworks
        case githubReady = "github_ready"
        case imageBaseUrl = "image_base_url"
    }
}

struct GitHubArtwork: Codable {
    let id: Int
    let title: String
    let artist: String?
    let date: String?
    let medium: String?
    let imageId: String
    let imageUrl: String
    let githubImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, artist, date, medium
        case imageId = "image_id"
        case imageUrl = "image_url"
        case githubImageUrl = "github_image_url"
    }
}

// MARK: - Collection Manifest Models (from JSON files)
struct CollectionManifest: Codable {
    let collectionId: String
    let title: String
    let description: String
    let dateRange: String
    let artworkCount: Int
    let artworkIds: [Int]
    let artworks: [CollectionArtworkPreview]
    let filtersApplied: CollectionFilters
    let createdDate: String
    
    enum CodingKeys: String, CodingKey {
        case collectionId = "collection_id"
        case title, description
        case dateRange = "date_range"
        case artworkCount = "artwork_count"
        case artworkIds = "artwork_ids"
        case artworks
        case filtersApplied = "filters_applied"
        case createdDate = "created_date"
    }
}

struct CollectionArtworkPreview: Codable {
    let id: Int
    let title: String
    let artist: String?
    let date: String?
    let medium: String?
    let year: Int?
}

struct CollectionFilters: Codable {
    let department: String
    let isPublicDomain: Bool
    let hasImage: Bool
    let classification: String
    let isZoomable: Bool
    let dateRange: [Int]
    
    enum CodingKeys: String, CodingKey {
        case department
        case isPublicDomain = "is_public_domain"
        case hasImage = "has_image"
        case classification
        case isZoomable = "is_zoomable"
        case dateRange = "date_range"
    }
}

// MARK: - SwiftUI Collection Model
struct ArtCollection: Identifiable {
    let id: String
    let title: String
    let description: String
    let dateRange: String
    let thumbnailArtworks: [Artwork] // First 4 artworks for preview
    let allArtworks: [Artwork] // All artworks in collection
    let totalCount: Int
    let source: String
    
    // Create from manifest + fetched artworks
    static func from(manifest: CollectionManifest, artworks: [Artwork]) -> ArtCollection {
        return ArtCollection(
            id: manifest.collectionId,
            title: manifest.title,
            description: manifest.description,
            dateRange: manifest.dateRange,
            thumbnailArtworks: Array(artworks.prefix(4)),
            allArtworks: artworks,
            totalCount: artworks.count,
            source: "Chicago Art Institute"
        )
    }
    
    // Legacy method for backward compatibility
    static func europeanPaintings(with artworks: [Artwork]) -> ArtCollection {
        return ArtCollection(
            id: "european_paintings",
            title: "European Paintings",
            description: "Curated masterpieces from the Chicago Art Institute featuring works by Monet, Van Gogh, Renoir, and other masters of European art.",
            dateRange: "Various periods",
            thumbnailArtworks: Array(artworks.prefix(4)),
            allArtworks: artworks,
            totalCount: artworks.count,
            source: "Chicago Art Institute"
        )
    }
}
