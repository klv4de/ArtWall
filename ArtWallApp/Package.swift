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
        .package(url: "https://github.com/sindresorhus/macos-wallpaper", from: "2.3.2")
    ],
    targets: [
        .executableTarget(
            name: "ArtWall",
            dependencies: [
                .product(name: "Wallpaper", package: "macos-wallpaper")
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
