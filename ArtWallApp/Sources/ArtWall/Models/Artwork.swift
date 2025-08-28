import Foundation

// MARK: - Chicago Art Institute API Models
struct ArtworkSearchResponse: Codable {
    let data: [Artwork]
    let pagination: Pagination
    let info: APIInfo
}

struct ArtworkResponse: Codable {
    let data: Artwork
    let info: APIInfo
}

struct Artwork: Codable, Identifiable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let mediumDisplay: String?
    let dimensions: String?
    let imageId: String?
    let altText: String?
    let isPublicDomain: Bool
    let departmentTitle: String?
    let classificationTitle: String?
    let artworkTypeTitle: String?
    let githubImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, dimensions
        case artistDisplay = "artist_display"
        case dateDisplay = "date_display"
        case mediumDisplay = "medium_display"
        case imageId = "image_id"
        case altText = "alt_text"
        case isPublicDomain = "is_public_domain"
        case departmentTitle = "department_title"
        case classificationTitle = "classification_title"
        case artworkTypeTitle = "artwork_type_title"
        case githubImageURL = "github_image_url"
    }
    
    // Computed properties for filtering
    var isPainting: Bool {
        guard let medium = mediumDisplay?.lowercased() else { return false }
        let paintingKeywords = ["oil on canvas", "oil on panel", "oil on board", "tempera on panel", "acrylic on canvas"]
        return paintingKeywords.contains { medium.contains($0) }
    }
    
    var isEuropeanDepartment: Bool {
        guard let department = departmentTitle else { return false }
        
        // Accept paintings from these departments
        let acceptableDepartments = [
            "Painting and Sculpture of Europe",
            "European Painting",
            "European Art",
            "Paintings",
            "Modern Art" // Many European masterpieces are in Modern Art
        ]
        
        return acceptableDepartments.contains { department.contains($0) }
    }
    
    var hasImage: Bool {
        return imageId != nil && !imageId!.isEmpty
    }
    
    var imageURL: URL? {
        // Use GitHub images first, fallback to Chicago Art Institute if needed
        if let githubURL = githubImageURL {
            return URL(string: githubURL)
        }
        
        // Fallback to Chicago IIIF service
        guard let imageId = imageId else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/843,/0/default.jpg")
    }
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case total, limit, offset
        case totalPages = "total_pages"
    }
}

struct APIInfo: Codable {
    let licenseText: String
    let licenseLinks: [String]
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case licenseText = "license_text"
        case licenseLinks = "license_links"
        case version
    }
}
