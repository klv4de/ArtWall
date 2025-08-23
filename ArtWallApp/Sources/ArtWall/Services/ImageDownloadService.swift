import Foundation
import SwiftUI

@MainActor
class ImageDownloadService: ObservableObject {
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var downloadStatus = ""
    @Published var currentDownloadIndex = 0
    @Published var totalDownloads = 0
    
    private let baseDownloadPath: URL
    
    init() {
        // Create download directory in ~/Pictures/ArtWall/
        let picturesPath = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        self.baseDownloadPath = picturesPath.appendingPathComponent("ArtWall")
        
        // Ensure the base directory exists
        try? FileManager.default.createDirectory(at: baseDownloadPath, withIntermediateDirectories: true)
    }
    
    /// Downloads all images for a collection to local storage
    func downloadCollection(_ collection: ArtCollection) async throws {
        isDownloading = true
        downloadProgress = 0.0
        currentDownloadIndex = 0
        totalDownloads = collection.allArtworks.count
        
        // Create collection-specific directory
        let collectionPath = baseDownloadPath.appendingPathComponent(sanitizeFileName(collection.title))
        try FileManager.default.createDirectory(at: collectionPath, withIntermediateDirectories: true)
        
        downloadStatus = "Preparing to download \(totalDownloads) artworks..."
        
        for (index, artwork) in collection.allArtworks.enumerated() {
            currentDownloadIndex = index + 1
            downloadStatus = "Downloading \(artwork.title) (\(currentDownloadIndex)/\(totalDownloads))"
            
            try await downloadArtworkImage(artwork, to: collectionPath)
            
            downloadProgress = Double(currentDownloadIndex) / Double(totalDownloads)
        }
        
        downloadStatus = "Download complete! \(totalDownloads) artworks saved."
        isDownloading = false
        
        print("🎉 Successfully downloaded collection '\(collection.title)' to: \(collectionPath.path)")
    }
    
    /// Downloads a single artwork image
    private func downloadArtworkImage(_ artwork: Artwork, to directory: URL) async throws {
        // Use the GitHub image URL since we already have high-quality images there
        let imageUrl = "https://raw.githubusercontent.com/klv4de/ArtWall/main/github_collections/images/\(artwork.id).jpg"
        
        guard let url = URL(string: imageUrl) else {
            throw ImageDownloadError.invalidURL(imageUrl)
        }
        
        // Download the image data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageDownloadError.downloadFailed(url.absoluteString)
        }
        
        // Create filename: "ArtworkID_SanitizedTitle.jpg"
        let fileName = "\(artwork.id)_\(sanitizeFileName(artwork.title)).jpg"
        let filePath = directory.appendingPathComponent(fileName)
        
        // Save the image data
        try data.write(to: filePath)
        
        print("✅ Downloaded: \(fileName)")
    }
    
    // Removed unused functions since we're using GitHub images directly
    
    /// Sanitizes filename by removing invalid characters
    private func sanitizeFileName(_ name: String) -> String {
        let invalidChars = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidChars).joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(100) // Limit length to avoid filesystem issues
            .description
    }
    
    /// Checks if collection is already downloaded (has images, not just folder)
    func isCollectionDownloaded(_ collection: ArtCollection) -> Bool {
        let collectionPath = baseDownloadPath.appendingPathComponent(sanitizeFileName(collection.title))
        
        // Check if directory exists
        guard FileManager.default.fileExists(atPath: collectionPath.path) else {
            return false
        }
        
        // Check if it has the expected number of image files
        do {
            let files = try FileManager.default.contentsOfDirectory(at: collectionPath, includingPropertiesForKeys: nil)
            let imageFiles = files.filter { $0.pathExtension.lowercased() == "jpg" }
            return imageFiles.count >= collection.allArtworks.count
        } catch {
            return false
        }
    }
    
    /// Gets the local path for a downloaded collection
    func getCollectionPath(_ collection: ArtCollection) -> URL {
        return baseDownloadPath.appendingPathComponent(sanitizeFileName(collection.title))
    }
}

enum ImageDownloadError: LocalizedError {
    case invalidURL(String)
    case downloadFailed(String)
    case fileWriteError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid image URL: \(url)"
        case .downloadFailed(let url):
            return "Failed to download image from: \(url)"
        case .fileWriteError(let path):
            return "Failed to write image to: \(path)"
        }
    }
}
