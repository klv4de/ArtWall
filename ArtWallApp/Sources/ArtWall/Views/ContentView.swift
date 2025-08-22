import SwiftUI

struct ContentView: View {
    @State private var showingCollections = false
    @State private var featuredArtwork: Artwork?
    @StateObject private var artService = ChicagoArtService()
    
    var body: some View {
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
            
            Button("Browse Collections") {
                showingCollections = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 500)
        .sheet(isPresented: $showingCollections) {
            CollectionsListView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .task {
            await loadFeaturedArtwork()
        }
    }
    
    private func loadFeaturedArtwork() async {
        let artwork = await artService.fetchFeaturedArtwork()
        await MainActor.run {
            featuredArtwork = artwork
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
