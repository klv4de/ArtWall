import SwiftUI

struct ContentView: View {
    @State private var featuredArtwork: Artwork?
    @StateObject private var artService = ChicagoArtService()
    private let logger = ArtWallLogger.shared
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 20) {
            // Featured artwork or placeholder
            if let artwork = featuredArtwork {
                AsyncImage(url: artwork.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                        )
                }
                .frame(width: 400, height: 300)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
            }
            
            Text("ArtWall")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Curated Fine Art for Your Desktop")
                .font(.headline)
                .foregroundColor(.secondary)
            
            NavigationLink(destination: CollectionsListView()) {
                Text("Browse Collections")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(minWidth: 1000, minHeight: 700)
        .toolbar(.hidden)
        }
        .task {
            logger.info("ContentView appeared - loading featured artwork", category: .app)
            await loadFeaturedArtwork()
        }
    }
    
    private func loadFeaturedArtwork() async {
        // Create instant featured artwork (no API call needed!)
        let instantArtwork = Artwork(
            id: 81555,
            title: "Lunch at the Restaurant Fournaise (The Rowers' Lunch)",
            artistDisplay: "Pierre-Auguste Renoir (French, 1841–1919)",
            dateDisplay: "1875",
            mediumDisplay: "Oil on canvas",
            dimensions: nil,
            imageId: "1a1b74fe-ff2a-8991-0581-5d420f0b840e", // Real image ID from our data
            altText: nil,
            isPublicDomain: true,
            departmentTitle: "Painting and Sculpture of Europe",
            classificationTitle: "painting",
            artworkTypeTitle: nil
        )
        
        await MainActor.run {
            featuredArtwork = instantArtwork
        }
        
        logger.success("Loaded featured artwork: \(instantArtwork.title)", category: .app)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
