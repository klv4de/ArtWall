import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss
    
    /// Parse HTML description to plain text for display
    private func parseHTMLDescription(_ htmlString: String) -> String {
        // Remove HTML tags and decode entities for display
        let withoutTags = htmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let withoutNewlines = withoutTags.replacingOccurrences(of: "\n", with: " ")
        let cleaned = withoutNewlines.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic HTML entity decoding
        let decoded = cleaned
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        
        return decoded
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Done button on left, title centered, invisible spacer on right
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Done")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Artwork Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible spacer to balance the Done button and truly center the title
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Done")
                }
                .font(.headline)
                .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Large image with better framing
                VStack(spacing: 0) {
                    AsyncImage(url: artwork.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .aspectRatio(4/3, contentMode: .fit)
                            .overlay(
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Loading artwork...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            )
                    }
                    .frame(maxHeight: 500)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                // Artwork information with better hierarchy
                VStack(alignment: .leading, spacing: 16) {
                    // Title section
                    VStack(alignment: .leading, spacing: 6) {
                        Text(artwork.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .lineSpacing(2)
                        
                        if let artist = artwork.artistDisplay {
                            Text(artist)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Metadata section
                    VStack(alignment: .leading, spacing: 8) {
                        if let date = artwork.dateDisplay {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let medium = artwork.mediumDisplay {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(medium)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let dimensions = artwork.dimensions {
                            HStack {
                                Image(systemName: "ruler")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(dimensions)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Artwork description with better styling
                    if let description = artwork.description, !description.isEmpty {
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text("About this artwork")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(parseHTMLDescription(description))
                                .font(.body)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 24) // Indent to align with icon
                        }
                    }
                }
            }
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            }
        }
    }
}