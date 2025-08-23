// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtWall",
    platforms: [
        .macOS(.v14) // macOS Sonoma 14.0+ required for reliable wallpaper automation
    ],
    products: [
        .executable(
            name: "ArtWall",
            targets: ["ArtWall"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "ArtWall",
            dependencies: [],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
