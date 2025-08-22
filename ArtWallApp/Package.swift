// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtWall",
    platforms: [
        .macOS(.v13)
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
