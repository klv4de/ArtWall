import Foundation

class ChicagoArtService: ObservableObject {
    private let apiBase = "https://api.artic.edu/api/v1"
    private let session = URLSession.shared
    private let apiDelay: TimeInterval = 3.0  // 3-second delay between API calls
    
    // API Settings (matching our Python script)
    private let maxAPICallsPerSession = 100
    private let searchLimit = 100  // Max per API call
    private let targetDepartment = "Painting and Sculpture of Europe"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchEuropeanPaintings(limit: Int = 24) async -> [Artwork] {
        isLoading = true
        errorMessage = nil
        
        do {
            let artworks = try await searchArtworks(query: "oil on canvas", limit: limit)
            let filtered = filterSuitableArtworks(artworks)
            
            await MainActor.run {
                isLoading = false
            }
            
            return filtered
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    func fetchFeaturedArtwork() async -> Artwork? {
        do {
            // Search for famous masterpieces specifically
            let artworks = try await searchArtworks(query: "Monet Water Lilies", limit: 5)
            let filtered = filterSuitableArtworks(artworks)
            
            // Return the first suitable masterpiece
            return filtered.first
        } catch {
            print("❌ Failed to fetch featured artwork: \(error)")
            return nil
        }
    }
    
    private func searchArtworks(query: String, limit: Int) async throws -> [Artwork] {
        // Construct API URL (matching our Python logic)
        var components = URLComponents(string: "\(apiBase)/artworks/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(min(limit, searchLimit))),
            URLQueryItem(name: "fields", value: "id,title,artist_display,date_display,medium_display,dimensions,image_id,alt_text,is_public_domain,department_title,classification_title,artwork_type_title")
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        print("🔍 Searching Chicago API: \(url)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📡 API Response: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let searchResponse = try JSONDecoder().decode(ArtworkSearchResponse.self, from: data)
        print("📊 Found \(searchResponse.data.count) artworks")
        
        // Rate limiting - wait before next API call
        try await Task.sleep(nanoseconds: UInt64(apiDelay * 1_000_000_000))
        
        return searchResponse.data
    }
    
    private func filterSuitableArtworks(_ artworks: [Artwork]) -> [Artwork] {
        let filtered = artworks.filter { artwork in
            // Must be public domain
            guard artwork.isPublicDomain else {
                print("❌ Not public domain: \(artwork.title)")
                return false
            }
            
            // Must have an image
            guard artwork.hasImage else {
                print("❌ No image: \(artwork.title)")
                return false
            }
            
            // Must be from European department
            guard artwork.isEuropeanDepartment else {
                print("❌ Not European department: \(artwork.title) - \(artwork.departmentTitle ?? "Unknown")")
                return false
            }
            
            // Must be a painting (matching our Python logic)
            guard artwork.isPainting else {
                print("❌ Not a painting: \(artwork.title) - \(artwork.mediumDisplay ?? "Unknown medium")")
                return false
            }
            
            print("✅ Suitable painting: \(artwork.title) - \(artwork.mediumDisplay ?? "")")
            return true
        }
        
        print("🎨 Filtered to \(filtered.count) suitable European paintings")
        return filtered
    }
    
    func downloadImage(from artwork: Artwork) async -> Data? {
        guard let imageURL = artwork.imageURL else {
            print("❌ No image URL for: \(artwork.title)")
            return nil
        }
        
        do {
            print("⬇️ Downloading: \(artwork.title)")
            let (data, _) = try await session.data(from: imageURL)
            print("✅ Downloaded \(data.count) bytes for: \(artwork.title)")
            
            // Rate limiting
            try await Task.sleep(nanoseconds: UInt64(apiDelay * 1_000_000_000))
            
            return data
        } catch {
            print("❌ Failed to download \(artwork.title): \(error)")
            return nil
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid API response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}
