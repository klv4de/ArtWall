import Foundation

struct ArtCollection: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let thumbnailArtworks: [Artwork] // First 4 artworks for preview
    let totalCount: Int
    let source: String // e.g., "Chicago Art Institute"
    
    // For now, we'll have a static European collection
    static func europeanPaintings(with artworks: [Artwork]) -> ArtCollection {
        return ArtCollection(
            title: "European Paintings",
            description: "Curated masterpieces from the Chicago Art Institute featuring works by Monet, Van Gogh, Renoir, and other masters of European art.",
            thumbnailArtworks: Array(artworks.prefix(4)),
            totalCount: artworks.count,
            source: "Chicago Art Institute"
        )
    }
}
