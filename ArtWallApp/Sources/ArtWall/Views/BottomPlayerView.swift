import SwiftUI

struct BottomPlayerView: View {
    @ObservedObject private var rotationEngine = WallpaperRotationEngine.shared
    private let logger = ArtWallLogger.shared
    
    private func getCurrentArtworkURL() -> URL? {
        return rotationEngine.currentImageURL
    }
    
    private func getCurrentArtworkTitle() -> String {
        return rotationEngine.getCurrentArtworkTitle()
    }
    
    private func getCurrentArtworkArtist() -> String {
        return rotationEngine.getCurrentArtworkArtist()
    }
    
    private func getCurrentArtworkYear() -> String {
        return rotationEngine.getCurrentArtworkDate()
    }
    
    private func getCurrentArtworkSource() -> String {
        return rotationEngine.getCurrentArtworkSource()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top divider
            Divider()
            
            HStack(spacing: 16) {
                // Artwork thumbnail (left side) - made bigger
                AsyncImage(url: getCurrentArtworkURL()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo.artframe")
                                .foregroundColor(.gray)
                                .font(.title)
                        )
                }
                .frame(width: 90, height: 90) // Increased from 60x60
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Artwork info (center) - using live data
                VStack(alignment: .leading, spacing: 1) {
                    Text(getCurrentArtworkTitle())
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(getCurrentArtworkArtist())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(getCurrentArtworkYear())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(getCurrentArtworkSource())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(rotationEngine.currentCollection ?? "No Collection")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(rotationEngine.totalImages) artworks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Countdown timer (center-right) - using live data
                VStack(spacing: 2) {
                    Text("Next in")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(rotationEngine.timeUntilNext))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .monospacedDigit()
                }
                
                // Control buttons (right side)
                HStack(spacing: 12) {
                    Button(action: {
                        logger.info("User clicked Previous button in bottom player", category: .ui)
                        // TODO: Implement previous image functionality
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        logger.info("User clicked Pause/Resume button in bottom player", category: .ui)
                        if rotationEngine.isPaused {
                            rotationEngine.resumeRotation()
                        } else {
                            rotationEngine.pauseRotation()
                        }
                    }) {
                        Image(systemName: rotationEngine.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        logger.info("User clicked Next button in bottom player", category: .ui)
                        rotationEngine.nextWallpaper()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16) // Increased padding
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(height: 110) // Increased from 80 to accommodate larger image
        .onAppear {
            logger.info("BottomPlayerView appeared", category: .ui)
        }
    }
}

struct BottomPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        BottomPlayerView()
            .frame(width: 1000)
    }
}
