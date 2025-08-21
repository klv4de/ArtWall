import SwiftUI

struct ContentView: View {
    @State private var showingCollection = false
    @State private var loadedArtworks: [Artwork] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.artframe")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("ArtWall")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Curated Fine Art for Your Desktop")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Browse Collections") {
                showingCollection = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
        .sheet(isPresented: $showingCollection) {
            CollectionView(artworks: $loadedArtworks)
                .frame(minWidth: 900, minHeight: 700)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
