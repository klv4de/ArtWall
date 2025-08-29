import SwiftUI

struct CollectionDetailsView: View {
    let collection: ArtCollection
    @Environment(\.dismiss) private var dismiss
    @StateObject private var downloadService = ImageDownloadService()
    @ObservedObject private var rotationEngine = WallpaperRotationEngine.shared
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
                
                // Old rotation controls removed - now handled by bottom player
                
                // Resume functionality is now handled by bottom player
                if false { // Disabled - using bottom player instead
                    VStack(alignment: .trailing, spacing: 4) {
                        Button(action: {
                            logger.info("User clicked 'Resume Rotation' for: \(collection.title)", category: .ui)
                            resumeRotation()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                Text("Resume")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.borderless)
                        
                        Text("⏸️ Rotation Paused")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("Collection ready")
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
                            ArtworkCard(artwork: artwork, collectionTitle: collection.title)
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
                
                // Download complete - now start wallpaper rotation
                await MainActor.run {
                    showingDownloadProgress = false
                    collectionApplied = true
                    
                    // Start wallpaper rotation with the downloaded collection
                    startWallpaperRotation()
                    
                    print("🎉 Collection applied and rotation started: \(collection.title)")
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
    
    private func startWallpaperRotation() {
        // Use the same path that ImageDownloadService uses
        let collectionPath = downloadService.getCollectionPath(collection)
        
        logger.info("Starting wallpaper rotation for collection: \(collection.title)", category: .wallpaper)
        rotationEngine.startRotation(collectionName: collection.title, collectionPath: collectionPath)
    }
    
    private func resumeRotation() {
        logger.info("Resuming wallpaper rotation for collection: \(collection.title)", category: .wallpaper)
        rotationEngine.resumeRotation()
    }
}

struct ArtworkCard: View {
    let artwork: Artwork
    let collectionTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Use GitHub images for instant loading
            AsyncImage(url: artwork.imageURL, transaction: Transaction(animation: .easeInOut(duration: 0.3))) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.7)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(Color.black.opacity(0.05))
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Image unavailable")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
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