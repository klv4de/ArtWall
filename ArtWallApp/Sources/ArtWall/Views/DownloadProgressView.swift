import SwiftUI

struct DownloadProgressView: View {
    @ObservedObject var downloadService: ImageDownloadService
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Header
            VStack(spacing: 8) {
                Text("Downloading Collection")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(downloadService.downloadStatus)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Progress Bar
            VStack(spacing: 12) {
                ProgressView(value: downloadService.downloadProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)
                
                HStack {
                    Text("\(downloadService.currentDownloadIndex) of \(downloadService.totalDownloads)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(downloadService.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Cancel Button
            Button("Cancel") {
                onCancel()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(30)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 400)
    }
}

// Preview removed due to Swift Package Manager macro limitations
