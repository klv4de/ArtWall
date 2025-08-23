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
}
