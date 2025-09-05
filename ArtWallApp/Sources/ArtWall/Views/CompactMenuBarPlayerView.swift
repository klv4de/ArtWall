import SwiftUI

struct CompactMenuBarPlayerView: View {
    @ObservedObject private var rotationEngine = WallpaperRotationEngine.shared
    @State private var showingArtworkDetail = false
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
    
    private func handleDoubleClick() {
        guard let currentArtwork = rotationEngine.getCurrentArtwork() else {
            logger.warning("Double-click on artwork but no current artwork available", category: .ui)
            return
        }
        
        logger.info("User double-clicked artwork in menu bar - opening details for: \(currentArtwork.title)", category: .ui)
        showingArtworkDetail = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if rotationEngine.isRotating {
                VStack(spacing: 0) {
                    // Header - Clean and centered
                    VStack(spacing: 8) {
                        HStack {
                            Text("ArtWall")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            // Status indicator
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(rotationEngine.isPaused ? Color.orange : Color.green)
                                    .frame(width: 6, height: 6)
                                
                                Text(rotationEngine.isPaused ? "Paused" : "Active")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Collection name - centered and prominent
                        Text(rotationEngine.currentCollection ?? "No Collection")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                    
                    // Artwork section - left aligned for readability
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // Artwork thumbnail
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
                                            .font(.title2)
                                    )
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(6)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .onTapGesture(count: 2) {
                                handleDoubleClick()
                            }
                            
                            // Artwork info - clean left alignment
                            VStack(alignment: .leading, spacing: 3) {
                                Text(getCurrentArtworkTitle())
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Text(getCurrentArtworkArtist())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Text(getCurrentArtworkYear())
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .onTapGesture(count: 2) {
                                handleDoubleClick()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        // Progress indicator - centered
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text("\(rotationEngine.currentImageIndex + 1)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                
                                Text("of")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("\(rotationEngine.totalImages)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("Next in \(formatTime(rotationEngine.timeUntilNext))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    
                    Divider()
                    
                    // Controls section - centered and balanced
                    VStack(spacing: 12) {
                        // Media controls - centered
                        HStack(spacing: 20) {
                            Button(action: {
                                logger.info("User clicked Previous button in menu bar", category: .ui)
                                rotationEngine.previousWallpaper()
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                logger.info("User clicked Pause/Resume button in menu bar", category: .ui)
                                if rotationEngine.isPaused {
                                    rotationEngine.resumeRotation()
                                } else {
                                    rotationEngine.pauseRotation()
                                }
                            }) {
                                Image(systemName: rotationEngine.isPaused ? "play.fill" : "pause.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                logger.info("User clicked Next button in menu bar", category: .ui)
                                rotationEngine.nextWallpaper()
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                logger.info("User clicked Stop button in menu bar", category: .ui)
                                rotationEngine.stopRotation()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Divider()
                        
                        // App controls - left aligned for consistency
                        VStack(spacing: 8) {
                            Button(action: {
                                logger.info("User clicked 'Open ArtWall' in menu bar", category: .ui)
                                NSApp.activate(ignoringOtherApps: true)
                            }) {
                                HStack {
                                    Image(systemName: "app.badge")
                                        .font(.subheadline)
                                    Text("Open ArtWall")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                logger.info("User clicked Quit in menu bar", category: .ui)
                                NSApplication.shared.terminate(nil)
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .font(.subheadline)
                                    Text("Quit ArtWall")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                }
                .frame(width: 300) // Slightly wider for better proportions
                
            } else {
                // No rotation active - clean centered design
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("ArtWall")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 6, height: 6)
                            
                            Text("Inactive")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                    
                    // Message section
                    VStack(spacing: 8) {
                        Image(systemName: "photo.artframe")
                            .font(.title2)
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("No rotation active")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Apply a collection to start")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    Divider()
                    
                    // Actions
                    VStack(spacing: 8) {
                        Button(action: {
                            logger.info("User clicked 'Open ArtWall' in menu bar (no rotation)", category: .ui)
                            NSApp.activate(ignoringOtherApps: true)
                        }) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .font(.subheadline)
                                Text("Open ArtWall")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            logger.info("User clicked Quit in menu bar (no rotation)", category: .ui)
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.subheadline)
                                Text("Quit ArtWall")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .frame(width: 300)
            }
        }
        .onAppear {
            logger.info("CompactMenuBarPlayerView appeared", category: .ui)
        }
        .sheet(isPresented: $showingArtworkDetail) {
            if let artwork = rotationEngine.getCurrentArtwork() {
                NavigationStack {
                    ArtworkDetailView(artwork: artwork)
                }
            }
        }
    }
}

struct CompactMenuBarPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CompactMenuBarPlayerView()
    }
}
