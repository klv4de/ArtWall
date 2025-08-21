import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back to Collection")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Artwork Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
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
                    }
                }
                .padding(20)
            }
        }
    }
}
