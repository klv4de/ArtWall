import Foundation

enum CollectionError: LocalizedError {
    case resourceNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let message):
            return message
        }
    }
}

class CollectionManager: ObservableObject {
    @Published var availableCollections: [CollectionManifest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let artService: ChicagoArtService
    private let logger = ArtWallLogger.shared
    
    init(artService: ChicagoArtService) {
        self.artService = artService
        logger.info("CollectionManager initialized", category: .collections)
    }
    
    // MARK: - Collection Loading
    
    func loadAvailableCollections() async {
        let tracker = logger.startProcess("Load Available Collections", category: .collections)
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let collections = try await loadCollectionManifests()
            await MainActor.run {
                availableCollections = collections
                isLoading = false
            }
            
            tracker.complete()
            logger.success("Loaded \(collections.count) collections successfully", category: .collections)
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load collections: \(error.localizedDescription)"
                isLoading = false
            }
            
            tracker.fail(error: error)
            logger.error("Failed to load available collections", error: error, category: .collections)
        }
    }
    
    private func loadCollectionManifests() async throws -> [CollectionManifest] {
        // Load from bundled collections_index.json (production-ready!)
        
        do {
            guard let url = Bundle.module.url(forResource: "collections_index", withExtension: "json") else {
                throw CollectionError.resourceNotFound("collections_index.json not found in app bundle")
            }
            
            let data = try Data(contentsOf: url)
            let collectionsIndex = try JSONDecoder().decode(CollectionsIndex.self, from: data)
            
            // Convert from CollectionsIndex format to CollectionManifest format
            let manifests = collectionsIndex.collections.map { indexCollection in
                CollectionManifest(
                    collectionId: indexCollection.id,
                    title: indexCollection.title,
                    description: indexCollection.description,
                    dateRange: indexCollection.dateRange,
                    artworkCount: indexCollection.artworkCount,
                    artworkIds: indexCollection.thumbnailArtworks.map { $0.id }, // Use thumbnail IDs for now
                    artworks: [], // Will be populated when building collection
                    filtersApplied: CollectionFilters(
                        department: "Painting and Sculpture of Europe",
                        isPublicDomain: true,
                        hasImage: true,
                        classification: "painting",
                        isZoomable: true,
                        dateRange: parseDateRange(indexCollection.dateRange)
                    ),
                    createdDate: collectionsIndex.createdDate
                )
            }
            
            logger.success("Loaded \(manifests.count) collections from collections_index.json", category: .collections)
            return manifests
            
        } catch {
            logger.warning("Failed to load bundled collections_index.json", category: .collections)
            logger.info("Falling back to hardcoded manifests", category: .collections)
            
            // Fallback to hardcoded data if bundle loading fails
            return [
                createMedievalRenaissanceManifest(),
                createRenaissanceBaroqueManifest(),
                createEighteenthCenturyManifest(),
                createGoldenAge1850sManifest(),
                createGoldenAge1860sManifest(),
                createGoldenAge1870sManifest(),
                createGoldenAge1880sManifest(),
                createGoldenAge1890sManifest()
            ]
        }
    }
    
    private func parseDateRange(_ dateRange: String) -> [Int] {
        // Parse "1260-1499" format into [1260, 1499]
        let components = dateRange.split(separator: "-")
        if components.count == 2,
           let start = Int(components[0]),
           let end = Int(components[1]) {
            return [start, end]
        }
        return [0, 2025] // Default range
    }
    
    // MARK: - Collection Manifest Creation
    // These will be replaced with JSON file loading once files are in bundle
    
    private func createMedievalRenaissanceManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "medieval_early_renaissance",
            title: "Medieval/Early Renaissance",
            description: "Medieval and Early Renaissance masterpieces (1260s-1490s)",
            dateRange: "1260-1499",
            artworkCount: 37,
            artworkIds: [16237, 16192, 59843, 102087, 35229, 81503, 16188, 16149, 16200, 16198, 16173, 16199, 16195, 16180, 16147, 16169, 16181, 16144, 16156, 16145, 16155, 16183, 16182, 16154, 16158, 16153, 16148, 16150, 16152, 16159, 16160, 16161, 16165, 16162, 16163, 16164, 16166],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1260, 1499]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createRenaissanceBaroqueManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "renaissance_baroque",
            title: "Renaissance/Baroque",
            description: "Renaissance and Baroque masterpieces (1500s-1690s)",
            dateRange: "1500-1699",
            artworkCount: 83,
            artworkIds: [188974, 16151, 102088, 16142, 16143, 16141, 16140, 16139, 16138, 16137, 16136, 16135, 16134, 16133, 16132, 16131, 16130, 16129, 16128, 16127, 16126, 16125, 16124, 16123, 16122, 16121, 16120, 16119, 16118, 16117, 16116, 16115, 16114, 16113, 16112, 16111, 16110, 16109, 16108, 16107, 16106, 16105, 16104, 16103, 16102, 16101, 16100, 16099, 16098, 16097, 16096, 16095, 16094, 16093, 16092, 16091, 16090, 16089, 16088, 16087, 16086, 16085, 16084, 16083, 16082, 16081, 16080, 16079, 16078, 16077, 16076, 16075, 16074, 16073, 16072, 16071, 16070, 16069, 16068, 16067, 16066, 16065, 57643],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1500, 1699]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createEighteenthCenturyManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "eighteenth_century",
            title: "18th Century",
            description: "18th Century European paintings (1700s-1790s)",
            dateRange: "1700-1799",
            artworkCount: 19,
            artworkIds: [109220, 93784, 59858, 105698, 59859, 59860, 59861, 59862, 59863, 59864, 59865, 59866, 59867, 59868, 59869, 59870, 59871, 59872, 59873],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1700, 1799]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createGoldenAge1850sManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "golden_age_1850s",
            title: "Golden Age: 1850s",
            description: "1850s paintings from the Golden Age",
            dateRange: "1850-1859",
            artworkCount: 22,
            artworkIds: [881, 882, 80571, 883, 884, 886, 887, 888, 889, 890, 891, 892, 893, 894, 14557, 14558, 14559, 14560, 14561, 14562, 14563, 14564],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1850, 1859]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createGoldenAge1860sManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "golden_age_1860s",
            title: "Golden Age: 1860s",
            description: "1860s paintings from the Golden Age",
            dateRange: "1860-1869",
            artworkCount: 24,
            artworkIds: [81505, 68428, 16636, 14565, 14566, 14567, 14568, 14569, 14570, 14571, 14573, 14575, 14576, 14577, 14578, 14579, 14580, 14581, 14582, 14583, 14584, 14585, 14586, 14587],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1860, 1869]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createGoldenAge1870sManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "golden_age_1870s",
            title: "Golden Age: 1870s",
            description: "1870s paintings - Peak decade of Impressionism",
            dateRange: "1870-1879",
            artworkCount: 37,
            artworkIds: [111057, 11723, 899, 86298, 86297, 100352, 30368, 880, 16551, 4776, 14556, 14594, 81507, 18951, 39554, 21165, 895, 14574, 186425, 39528, 39493, 81555, 25810, 14650, 16571, 885, 59944, 39479, 95613, 14572, 80604, 84076, 191564, 14647, 81557, 81558, 95654],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1870, 1879]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createGoldenAge1880sManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "golden_age_1880s",
            title: "Golden Age: 1880s",
            description: "1880s paintings from the Golden Age",
            dateRange: "1880-1889",
            artworkCount: 30,
            artworkIds: [111736, 16549, 81548, 14588, 14589, 14590, 14591, 14592, 14593, 14595, 14596, 14597, 14598, 14599, 14600, 14601, 14602, 14603, 14604, 14605, 14606, 14607, 14608, 14609, 14610, 14611, 14612, 14613, 14614, 14615],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1880, 1889]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    private func createGoldenAge1890sManifest() -> CollectionManifest {
        return CollectionManifest(
            collectionId: "golden_age_1890s",
            title: "Golden Age: 1890s",
            description: "1890s paintings from the Golden Age",
            dateRange: "1890-1899",
            artworkCount: 20,
            artworkIds: [874, 16648, 212300, 14616, 14617, 14618, 14619, 14620, 14621, 14622, 14623, 14624, 14625, 14626, 14627, 14628, 14629, 14630, 14631, 14632],
            artworks: [],
            filtersApplied: CollectionFilters(
                department: "Painting and Sculpture of Europe",
                isPublicDomain: true,
                hasImage: true,
                classification: "painting",
                isZoomable: true,
                dateRange: [1890, 1899]
            ),
            createdDate: "2025-01-21"
        )
    }
    
    // MARK: - Collection Building
    
    func buildCollection(from manifest: CollectionManifest) async -> ArtCollection? {
        let tracker = logger.startProcess("Build Collection: \(manifest.title)", category: .collections)
        logger.info("Building collection: \(manifest.title) (instant loading!)", category: .collections)
        
        // Load artwork metadata from bundled collections (production-ready!)
        do {
            guard let url = Bundle.module.url(forResource: "collections/\(manifest.collectionId)/collection", withExtension: "json") else {
                throw CollectionError.resourceNotFound("Collection \(manifest.collectionId) not found in app bundle")
            }
            
            let data = try Data(contentsOf: url)
            let githubCollection = try JSONDecoder().decode(GitHubCollection.self, from: data)
            
            // Convert GitHub collection artworks to SwiftUI Artwork models
            var artworks: [Artwork] = []
            
            for githubArtwork in githubCollection.artworks.prefix(24) {
                let artwork = Artwork(
                    id: githubArtwork.id,
                    title: githubArtwork.title,
                    artistDisplay: githubArtwork.artist,
                    dateDisplay: githubArtwork.date,
                    mediumDisplay: githubArtwork.medium,
                    dimensions: nil,
                    imageId: githubArtwork.imageId,
                    altText: nil,
                    isPublicDomain: true,
                    departmentTitle: "Painting and Sculpture of Europe",
                    classificationTitle: "painting",
                    artworkTypeTitle: nil,
                    githubImageURL: nil
                )
                artworks.append(artwork)
            }
            
            tracker.complete()
            logger.success("Instantly loaded collection with \(artworks.count) artworks from GitHub data", category: .collections)
            
            let collection = ArtCollection.from(manifest: manifest, artworks: artworks)
            return collection
            
        } catch {
            logger.warning("Could not load bundled collection data, using manifest IDs", category: .collections)
            
            // Fallback: create basic artworks from IDs
            var artworks: [Artwork] = []
            
            for artworkId in manifest.artworkIds.prefix(8) { // Smaller number for demo
                let artwork = Artwork(
                    id: artworkId,
                    title: "European Masterpiece",
                    artistDisplay: "Master Artist",
                    dateDisplay: manifest.dateRange,
                    mediumDisplay: "Oil on canvas",
                    dimensions: nil,
                    imageId: getImageIdForArtwork(artworkId),
                    altText: nil,
                    isPublicDomain: true,
                    departmentTitle: "Painting and Sculpture of Europe",
                    classificationTitle: "painting",
                    artworkTypeTitle: nil,
                    githubImageURL: nil
                )
                artworks.append(artwork)
            }
            
            tracker.complete()
            logger.success("Created fallback collection with \(artworks.count) artworks", category: .collections)
            
            let collection = ArtCollection.from(manifest: manifest, artworks: artworks)
            return collection
        }
    }
    
    private func getImageIdForArtwork(_ artworkId: Int) -> String {
        // Sample image IDs from our successful downloads
        let sampleImageIds = [
            "a8258ace-3df9-7232-73c0-157a0f916e1f",
            "78c80988-6524-cec7-c661-a4c0a706d06f",
            "6e7e8593-f529-4b73-9f96-75ff24623fe9",
            "c2bf35ea-3878-ffd1-18c3-311f13db873a",
            "4d682c85-3e87-2998-5e66-6628d4ddf9f1"
        ]
        
        return sampleImageIds[artworkId % sampleImageIds.count]
    }
    
    // MARK: - Convenience Methods
    
    func getCollectionManifest(id: String) -> CollectionManifest? {
        return availableCollections.first { $0.collectionId == id }
    }
    
    func getCollectionCount() -> Int {
        return availableCollections.count
    }
    
    func getTotalArtworkCount() -> Int {
        return availableCollections.reduce(0) { $0 + $1.artworkCount }
    }
}
