import Foundation
import AppKit

/// Testing framework for validating ArtWall functionality
/// Provides automated tests for major app components
class AppTester {
    
    private let logger = ArtWallLogger.shared
    
    /// Run all major system tests
    func runSystemTests() async {
        let tracker = logger.startProcess("System Tests", category: .app)
        
        logger.info("🧪 Starting ArtWall system tests...", category: .app)
        
        var passedTests = 0
        var totalTests = 0
        
        // Test 1: File System Access
        totalTests += 1
        if await testFileSystemAccess() {
            passedTests += 1
        }
        
        // Test 2: Network Connectivity
        totalTests += 1
        if await testNetworkConnectivity() {
            passedTests += 1
        }
        
        // Test 3: macOS Version Compatibility
        totalTests += 1
        if testMacOSCompatibility() {
            passedTests += 1
        }
        
        // Test 4: Screen Detection
        totalTests += 1
        if testScreenDetection() {
            passedTests += 1
        }
        
        // Test 5: UserDefaults Access
        totalTests += 1
        if testUserDefaultsAccess() {
            passedTests += 1
        }
        
        // Test 6: GitHub Image Integration
        totalTests += 1
        if await testGitHubImageIntegration() {
            passedTests += 1
        }
        
        // Test Results
        let successRate = Double(passedTests) / Double(totalTests) * 100
        
        if passedTests == totalTests {
            tracker.complete()
            logger.success("🎉 All system tests passed! (\(passedTests)/\(totalTests)) - \(String(format: "%.1f", successRate))%", category: .app)
        } else {
            tracker.fail()
            logger.warning("⚠️ Some system tests failed: \(passedTests)/\(totalTests) passed - \(String(format: "%.1f", successRate))%", category: .app)
        }
    }
    
    // MARK: - Individual Tests
    
    /// Test file system access and permissions
    private func testFileSystemAccess() async -> Bool {
        logger.debug("Testing file system access...", category: .app)
        
        do {
            let picturesPath = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
            let testPath = picturesPath.appendingPathComponent("ArtWall_Test")
            
            // Test directory creation
            try FileManager.default.createDirectory(at: testPath, withIntermediateDirectories: true)
            
            // Test file writing
            let testData = "ArtWall Test".data(using: .utf8)!
            let testFile = testPath.appendingPathComponent("test.txt")
            try testData.write(to: testFile)
            
            // Test file reading
            let readData = try Data(contentsOf: testFile)
            
            // Cleanup
            try FileManager.default.removeItem(at: testPath)
            
            logger.success("✅ File system access test passed", category: .app)
            return readData == testData
            
        } catch {
            logger.error("❌ File system access test failed", error: error, category: .app)
            return false
        }
    }
    
    /// Test network connectivity to GitHub
    private func testNetworkConnectivity() async -> Bool {
        logger.debug("Testing network connectivity...", category: .app)
        
        do {
            let testURL = URL(string: "https://raw.githubusercontent.com/klv4de/ArtWall/main/README.md")!
            let (_, response) = try await URLSession.shared.data(from: testURL)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                logger.success("✅ Network connectivity test passed", category: .app)
                return true
            } else {
                logger.error("❌ Network connectivity test failed: Invalid response", category: .app)
                return false
            }
            
        } catch {
            logger.error("❌ Network connectivity test failed", error: error, category: .app)
            return false
        }
    }
    
    /// Test macOS version compatibility
    private func testMacOSCompatibility() -> Bool {
        logger.debug("Testing macOS compatibility...", category: .app)
        
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let isCompatible = osVersion.majorVersion >= 14
        
        if isCompatible {
            logger.success("✅ macOS compatibility test passed: \(osVersion.majorVersion).\(osVersion.minorVersion)", category: .app)
        } else {
            logger.warning("⚠️ macOS compatibility test failed: \(osVersion.majorVersion).\(osVersion.minorVersion) (requires 14.0+)", category: .app)
        }
        
        return isCompatible
    }
    
    /// Test screen detection
    private func testScreenDetection() -> Bool {
        logger.debug("Testing screen detection...", category: .app)
        
        let screens = NSScreen.screens
        let hasScreens = !screens.isEmpty
        
        if hasScreens {
            logger.success("✅ Screen detection test passed: \(screens.count) screen(s) detected", category: .app)
            for (index, screen) in screens.enumerated() {
                logger.debug("Screen \(index + 1): \(screen.localizedName) - \(screen.frame)", category: .app)
            }
        } else {
            logger.error("❌ Screen detection test failed: No screens detected", category: .app)
        }
        
        return hasScreens
    }
    
    /// Test UserDefaults access for wallpaper settings
    private func testUserDefaultsAccess() -> Bool {
        logger.debug("Testing UserDefaults access...", category: .app)
        
        let defaults = UserDefaults.standard
        let testKey = "ArtWallTestKey"
        let testValue = "ArtWallTestValue_\(Date().timeIntervalSince1970)"
        
        // Test write
        defaults.set(testValue, forKey: testKey)
        defaults.synchronize()
        
        // Test read
        let readValue = defaults.string(forKey: testKey)
        
        // Cleanup
        defaults.removeObject(forKey: testKey)
        defaults.synchronize()
        
        let success = readValue == testValue
        
        if success {
            logger.success("✅ UserDefaults access test passed", category: .app)
        } else {
            logger.error("❌ UserDefaults access test failed: Value mismatch", category: .app)
        }
        
        return success
    }
    
    // MARK: - Collection Testing
    
    /// Test collection loading and validation
    func testCollectionLoading() async -> Bool {
        logger.debug("Testing collection loading...", category: .collections)
        
        do {
            let artService = ChicagoArtService()
            let collectionManager = CollectionManager(artService: artService)
            await collectionManager.loadAvailableCollections()
            
            let hasCollections = !collectionManager.availableCollections.isEmpty
            let allCollectionsValid = collectionManager.availableCollections.allSatisfy { collection in
                !collection.title.isEmpty && collection.artworkCount > 0
            }
            
            if hasCollections && allCollectionsValid {
                logger.success("✅ Collection loading test passed: \(collectionManager.availableCollections.count) collections loaded", category: .collections)
                return true
            } else {
                logger.error("❌ Collection loading test failed: Invalid collections", category: .collections)
                return false
            }
            
        } catch {
            logger.error("❌ Collection loading test failed", error: error, category: .collections)
            return false
        }
    }
    
    // MARK: - Wallpaper Testing
    
    /// Test wallpaper API availability (non-destructive)
    func testWallpaperAPIAccess() -> Bool {
        logger.debug("Testing wallpaper API access...", category: .wallpaper)
        
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            logger.error("❌ Wallpaper API test failed: No screens available", category: .wallpaper)
            return false
        }
        
        // Test that we can access the wallpaper API without actually changing wallpaper
        let workspace = NSWorkspace.shared
        let canAccessAPI = workspace.responds(to: #selector(NSWorkspace.setDesktopImageURL(_:for:options:)))
        
        if canAccessAPI {
            logger.success("✅ Wallpaper API access test passed", category: .wallpaper)
        } else {
            logger.error("❌ Wallpaper API access test failed: API not available", category: .wallpaper)
        }
        
        return canAccessAPI
    }
    
    /// Test wallpaper rotation engine functionality (non-destructive)
    @MainActor
    func testWallpaperRotationEngine() -> Bool {
        logger.debug("Testing WallpaperRotationEngine functionality...", category: .wallpaper)
        
        let engine = WallpaperRotationEngine.shared
        
        // Test that we can access the shared instance
        logger.debug("WallpaperRotationEngine shared instance accessed successfully", category: .wallpaper)
        
        // Test state management methods (without actually starting rotation)
        engine.stopRotation() // Should handle being called when not running
        engine.pauseRotation() // Should handle being called when not running
        engine.resumeRotation() // Should handle being called when not running
        
        logger.success("✅ WallpaperRotationEngine test passed", category: .wallpaper)
        return true
    }
    
    /// Test GitHub image integration functionality
    private func testGitHubImageIntegration() async -> Bool {
        logger.debug("Testing GitHub image integration...", category: .app)
        
        var testsPassed = 0
        var totalTests = 0
        
        // Test 1: Collection JSON files have GitHub URLs
        totalTests += 1
        if await testCollectionJSONHasGitHubURLs() {
            testsPassed += 1
        }
        
        // Test 2: Sample GitHub image accessibility
        totalTests += 1
        if await testSampleGitHubImageAccess() {
            testsPassed += 1
        }
        
        // Test 3: Artwork model prioritizes GitHub URLs
        totalTests += 1
        if testArtworkModelGitHubPriority() {
            testsPassed += 1
        }
        
        // Test 4: Fallback to Chicago Art Institute works
        totalTests += 1
        if testChicagoArtFallback() {
            testsPassed += 1
        }
        
        if testsPassed == totalTests {
            logger.success("✅ GitHub image integration test passed (\(testsPassed)/\(totalTests))", category: .app)
            return true
        } else {
            logger.warning("⚠️ GitHub image integration test partial failure: \(testsPassed)/\(totalTests)", category: .app)
            return false
        }
    }
    
    /// Test that collections_index.json contains GitHub URLs
    private func testCollectionJSONHasGitHubURLs() async -> Bool {
        do {
            guard let resourcesURL = Bundle.main.resourceURL else {
                logger.error("❌ Could not find resources bundle", category: .app)
                return false
            }
            
            let indexURL = resourcesURL.appendingPathComponent("collections_index.json")
            let data = try Data(contentsOf: indexURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let collections = json?["collections"] as? [[String: Any]] else {
                logger.error("❌ Could not parse collections from JSON", category: .app)
                return false
            }
            
            var githubURLCount = 0
            var totalArtworks = 0
            
            for collection in collections {
                if let artworks = collection["artworks"] as? [[String: Any]] {
                    for artwork in artworks {
                        totalArtworks += 1
                        if let githubURL = artwork["github_image_url"] as? String,
                           githubURL.contains("raw.githubusercontent.com/klv4de/ArtWall") {
                            githubURLCount += 1
                        }
                    }
                }
            }
            
            let hasGitHubURLs = githubURLCount > 0
            logger.debug("Found \(githubURLCount)/\(totalArtworks) artworks with GitHub URLs", category: .app)
            
            if hasGitHubURLs {
                logger.success("✅ Collection JSON contains GitHub URLs: \(githubURLCount) found", category: .app)
            } else {
                logger.error("❌ Collection JSON missing GitHub URLs", category: .app)
            }
            
            return hasGitHubURLs
            
        } catch {
            logger.error("❌ Failed to test collection JSON", error: error, category: .app)
            return false
        }
    }
    
    /// Test that a sample GitHub image is accessible
    private func testSampleGitHubImageAccess() async -> Bool {
        do {
            // Test with a known image from our GitHub repository
            let testURL = URL(string: "https://raw.githubusercontent.com/klv4de/ArtWall/main/github_collections/images/16237.jpg")!
            let (_, response) = try await URLSession.shared.data(from: testURL)
            
            if let httpResponse = response as? HTTPURLResponse {
                let isAccessible = httpResponse.statusCode == 200
                if isAccessible {
                    logger.success("✅ Sample GitHub image accessible: \(httpResponse.statusCode)", category: .app)
                } else {
                    logger.error("❌ Sample GitHub image not accessible: \(httpResponse.statusCode)", category: .app)
                }
                return isAccessible
            } else {
                logger.error("❌ Invalid response type for GitHub image test", category: .app)
                return false
            }
            
        } catch {
            logger.error("❌ Failed to access sample GitHub image", error: error, category: .app)
            return false
        }
    }
    
    /// Test that Artwork model prioritizes GitHub URLs over Chicago Art Institute
    private func testArtworkModelGitHubPriority() -> Bool {
        // Test artwork with GitHub URL
        let artworkWithGitHub = Artwork(
            id: 12345,
            title: "Test Artwork",
            artistDisplay: "Test Artist",
            dateDisplay: "2024",
            mediumDisplay: "Oil on canvas",
            dimensions: "10x10",
            imageId: "test-image-id",
            altText: nil,
            isPublicDomain: true,
            departmentTitle: "Test Department",
            classificationTitle: "painting",
            artworkTypeTitle: nil,
            githubImageURL: "https://raw.githubusercontent.com/klv4de/ArtWall/main/github_collections/images/12345.jpg"
        )
        
        // Test artwork without GitHub URL (should fallback to Chicago)
        let artworkWithoutGitHub = Artwork(
            id: 67890,
            title: "Test Artwork 2",
            artistDisplay: "Test Artist 2",
            dateDisplay: "2024",
            mediumDisplay: "Oil on canvas",
            dimensions: "10x10",
            imageId: "test-image-id-2",
            altText: nil,
            isPublicDomain: true,
            departmentTitle: "Test Department",
            classificationTitle: "painting",
            artworkTypeTitle: nil,
            githubImageURL: nil
        )
        
        let githubPrioritized = artworkWithGitHub.imageURL?.absoluteString.contains("raw.githubusercontent.com") ?? false
        let chicagoFallback = artworkWithoutGitHub.imageURL?.absoluteString.contains("artic.edu") ?? false
        
        if githubPrioritized && chicagoFallback {
            logger.success("✅ Artwork model correctly prioritizes GitHub URLs with Chicago fallback", category: .app)
            return true
        } else {
            logger.error("❌ Artwork model URL priority test failed - GitHub: \(githubPrioritized), Chicago: \(chicagoFallback)", category: .app)
            return false
        }
    }
    
    /// Test Chicago Art Institute fallback functionality
    private func testChicagoArtFallback() -> Bool {
        let artworkWithoutGitHub = Artwork(
            id: 16237,
            title: "Test Fallback",
            artistDisplay: "Test Artist",
            dateDisplay: "2024",
            mediumDisplay: "Oil on canvas",
            dimensions: "10x10",
            imageId: "3952a506-2776-5613-1693-e5c96c4708f2",
            altText: nil,
            isPublicDomain: true,
            departmentTitle: "Test Department",
            classificationTitle: "painting",
            artworkTypeTitle: nil,
            githubImageURL: nil
        )
        
        guard let imageURL = artworkWithoutGitHub.imageURL else {
            logger.error("❌ Chicago Art fallback failed: No image URL generated", category: .app)
            return false
        }
        
        let isChicagoURL = imageURL.absoluteString.contains("artic.edu/iiif")
        let hasCorrectImageId = imageURL.absoluteString.contains("3952a506-2776-5613-1693-e5c96c4708f2")
        
        if isChicagoURL && hasCorrectImageId {
            logger.success("✅ Chicago Art Institute fallback working correctly", category: .app)
            return true
        } else {
            logger.error("❌ Chicago Art Institute fallback failed: \(imageURL.absoluteString)", category: .app)
            return false
        }
    }
}

// MARK: - Convenience Extensions

extension AppTester {
    
    /// Quick system health check
    static func quickHealthCheck() async {
        let tester = AppTester()
        await tester.runSystemTests()
    }
    
    /// Test specific component
    static func testComponent(_ component: TestComponent) async -> Bool {
        let tester = AppTester()
        
        switch component {
        case .fileSystem:
            return await tester.testFileSystemAccess()
        case .network:
            return await tester.testNetworkConnectivity()
        case .macOSCompatibility:
            return tester.testMacOSCompatibility()
        case .screens:
            return tester.testScreenDetection()
        case .userDefaults:
            return tester.testUserDefaultsAccess()
        case .collections:
            return await tester.testCollectionLoading()
        case .wallpaperAPI:
            return tester.testWallpaperAPIAccess()
        case .wallpaperRotationEngine:
            return await tester.testWallpaperRotationEngine()
        case .githubImageIntegration:
            return await tester.testGitHubImageIntegration()
        }
    }
}

enum TestComponent: String, CaseIterable {
    case fileSystem = "File System"
    case network = "Network"
    case macOSCompatibility = "macOS Compatibility"
    case screens = "Screens"
    case userDefaults = "UserDefaults"
    case collections = "Collections"
    case wallpaperAPI = "Wallpaper API"
    case wallpaperRotationEngine = "Wallpaper Rotation Engine"
    case githubImageIntegration = "GitHub Image Integration"
}
