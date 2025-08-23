import SwiftUI

struct CollectionDetailsView: View {
    let collection: ArtCollection
    @Environment(\.dismiss) private var dismiss
    @StateObject private var downloadService = ImageDownloadService()
    @State private var showingDownloadProgress = false
    @State private var collectionApplied = false
    @State private var showingError = false
    @State private var errorMessage = ""
    private let logger = ArtWallLogger.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back to Collections")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Collection Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if collectionApplied {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Collection Applied")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text("Wallpaper changes every 30 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button(action: {
                        logger.info("User clicked 'Apply this collection' for: \(collection.title)", category: .ui)
                        startCollectionDownload()
                    }) {
                        Text("Apply this collection")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Collection header info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(collection.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(collection.totalCount) artworks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(collection.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Source: \(collection.source)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Artworks grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 200), spacing: 16)
                ], spacing: 16) {
                    ForEach(collection.allArtworks) { artwork in
                        NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                            ArtworkCard(artwork: artwork)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .toolbar(.hidden)
        .overlay(
            // Download Progress Overlay
            Group {
                if showingDownloadProgress {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        DownloadProgressView(downloadService: downloadService) {
                            // Cancel download
                            showingDownloadProgress = false
                            downloadService.isDownloading = false
                        }
                    }
                }
            }
        )
        .alert("Error", isPresented: $showingError) {
            Button("Try Again") {
                startCollectionDownload()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startCollectionDownload() {
        showingDownloadProgress = true
        
        Task {
            do {
                try await downloadService.downloadCollection(collection)
                
                // Download and wallpaper setup complete
                await MainActor.run {
                    showingDownloadProgress = false
                    collectionApplied = true
                    print("🎉 Collection applied successfully: \(collection.title)")
                }
            } catch {
                await MainActor.run {
                    showingDownloadProgress = false
                    errorMessage = "There was an error downloading or setting up your wallpaper collection. Please check your internet connection and try again."
                    showingError = true
                    print("❌ Collection setup failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ArtworkCard: View {
    let artwork: Artwork
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Actual image loading with AsyncImage
            AsyncImage(url: artwork.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .frame(height: 140)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let artist = artwork.artistDisplay {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let date = artwork.dateDisplay {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let medium = artwork.mediumDisplay {
                    Text(medium)
                        .font(.caption2)
                        .foregroundColor(Color.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct CollectionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample collection for preview
        let sampleArtworks: [Artwork] = []
        let sampleCollection = ArtCollection.europeanPaintings(with: sampleArtworks)
        CollectionDetailsView(collection: sampleCollection)
    }
}