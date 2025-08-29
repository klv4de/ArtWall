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
            // Header with back button and centered title
            HStack {
                // Back button on left
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back to Collection")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Centered title
                Text("Artwork Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible spacer to balance the back button for perfect centering
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back to Collection")
                    }
                    .font(.headline)
                }
                .opacity(0)
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Large image
                    AsyncImage(url: artwork.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(4/3, contentMode: .fit)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    
                    // Artwork information
                    VStack(alignment: .leading, spacing: 12) {
                        Text(artwork.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let artist = artwork.artistDisplay {
                            Text(artist)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        if let date = artwork.dateDisplay {
                            Text(date)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let medium = artwork.mediumDisplay {
                            Text(medium)
                                .font(.subheadline)
                                .foregroundColor(Color.secondary.opacity(0.7))
                        }
                        
                        if let dimensions = artwork.dimensions {
                            Text("Dimensions: \(dimensions)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Artwork description
                        if let description = artwork.description, !description.isEmpty {
                            Divider()
                                .padding(.vertical, 8)
                            
                            Text("About this artwork")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.bottom, 4)
                            
                            // Display HTML description as attributed text
                            Text(parseHTMLDescription(description))
                                .font(.body)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
            }
        }
        .toolbar(.hidden)
    }
}
