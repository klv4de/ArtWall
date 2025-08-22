import SwiftUI

struct CollectionsListView: View {
    @StateObject private var artService = ChicagoArtService()
    @State private var collections: [ArtCollection] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header - Clean title only, no back button
                VStack(spacing: 0) {
                    Text("Collections")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                // Main content
                if collections.isEmpty {
                    if artService.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading collections...")
                                .font(.headline)
                            Text("Fetching artwork previews...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No Collections Available")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Collections are being prepared...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 300), spacing: 20)
                        ], spacing: 20) {
                            ForEach(collections) { collection in
                                NavigationLink(destination: CollectionDetailsView(collection: collection)) {
                                    CollectionCard(collection: collection)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
                
                if let error = artService.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .task {
            await loadCollections()
        }
    }
    
    private func loadCollections() async {
        // Load European paintings collection with 24 images
        let artworks = await artService.fetchEuropeanPaintings(limit: 24)
        
        await MainActor.run {
            if !artworks.isEmpty {
                print("🎨 Creating collection with \(artworks.count) artworks")
                print("🖼️ First 4 artwork URLs for thumbnails:")
                for (index, artwork) in artworks.prefix(4).enumerated() {
                    print("  \(index + 1). \(artwork.title): \(artwork.imageURL?.absoluteString ?? "No URL")")
                }
                
                let europeanCollection = ArtCollection.europeanPaintings(with: artworks)
                collections = [europeanCollection]
            } else {
                print("❌ No artworks loaded for collection")
            }
        }
    }
}

struct CollectionCard: View {
    let collection: ArtCollection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 2x2 grid of thumbnail images
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ], spacing: 2) {
                ForEach(Array(collection.thumbnailArtworks.prefix(4).enumerated()), id: \.offset) { index, artwork in
                    AsyncImage(url: artwork.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.6)
                            )
                    }
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(6)
                }
                
                // Fill empty spots if less than 4 images
                ForEach(collection.thumbnailArtworks.count..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 100)
                        .cornerRadius(6)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary.opacity(0.5))
                        )
                }
            }
            .frame(height: 202) // 2 * 100 + 2 spacing
            .cornerRadius(8)
            
            // Collection info
            VStack(alignment: .leading, spacing: 6) {
                Text(collection.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(collection.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Text("\(collection.totalCount) artworks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(collection.source)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

struct CollectionsListView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsListView()
    }
}
