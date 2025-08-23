import Foundation
import os.log

/// Comprehensive logging system for ArtWall
/// Provides structured logging with different levels and categories
class ArtWallLogger {
    
    // MARK: - Log Categories
    enum Category: String, CaseIterable {
        case app = "ArtWall.App"
        case collections = "ArtWall.Collections"
        case download = "ArtWall.Download"
        case wallpaper = "ArtWall.Wallpaper"
        case ui = "ArtWall.UI"
        case network = "ArtWall.Network"
        case fileSystem = "ArtWall.FileSystem"
        case error = "ArtWall.Error"
    }
    
    // MARK: - Log Levels
    enum Level: String {
        case debug = "🔍 DEBUG"
        case info = "ℹ️ INFO"
        case success = "✅ SUCCESS"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
        case critical = "🚨 CRITICAL"
    }
    
    // MARK: - Singleton
    static let shared = ArtWallLogger()
    
    // MARK: - Properties
    private let osLog: OSLog
    private let logFileURL: URL
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.artwall.logger", qos: .utility)
    
    // MARK: - Initialization
    private init() {
        self.osLog = OSLog(subsystem: "com.artwall.app", category: "general")
        
        // Create log file in ~/Library/Logs/ArtWall/
        let logsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Logs")
            .appendingPathComponent("ArtWall")
        
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        let logFileName = "artwall-\(Self.currentDateString()).log"
        self.logFileURL = logsDirectory.appendingPathComponent(logFileName)
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Initialize log file
        initializeLogFile()
    }
    
    // MARK: - Public Logging Methods
    
    /// Log debug information
    func debug(_ message: String, category: Category = .app, function: String = #function, file: String = #file, line: Int = #line) {
        log(message, level: .debug, category: category, function: function, file: file, line: line)
    }
    
    /// Log general information
    func info(_ message: String, category: Category = .app, function: String = #function, file: String = #file, line: Int = #line) {
        log(message, level: .info, category: category, function: function, file: file, line: line)
    }
    
    /// Log success events
    func success(_ message: String, category: Category = .app, function: String = #function, file: String = #file, line: Int = #line) {
        log(message, level: .success, category: category, function: function, file: file, line: line)
    }
    
    /// Log warnings
    func warning(_ message: String, category: Category = .app, function: String = #function, file: String = #file, line: Int = #line) {
        log(message, level: .warning, category: category, function: function, file: file, line: line)
    }
    
    /// Log errors
    func error(_ message: String, error: Error? = nil, category: Category = .error, function: String = #function, file: String = #file, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, category: category, function: function, file: file, line: line)
    }
    
    /// Log critical issues
    func critical(_ message: String, error: Error? = nil, category: Category = .error, function: String = #function, file: String = #file, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .critical, category: category, function: function, file: file, line: line)
    }
    
    // MARK: - Process Tracking
    
    /// Start tracking a process
    func startProcess(_ processName: String, category: Category = .app) -> ProcessTracker {
        let tracker = ProcessTracker(processName: processName, category: category, logger: self)
        info("Started process: \(processName)", category: category)
        return tracker
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: Level, category: Category, function: String, file: String, line: Int) {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logEntry = "[\(timestamp)] \(level.rawValue) [\(category.rawValue)] \(fileName):\(line) \(function) | \(message)"
        
        // Console output
        print(logEntry)
        
        // OS Log (for Console.app)
        os_log("%{public}@", log: osLog, type: osLogType(for: level), logEntry)
        
        // File logging (async to avoid blocking)
        queue.async { [weak self] in
            self?.writeToFile(logEntry)
        }
    }
    
    private func osLogType(for level: Level) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info, .success:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
    
    private func writeToFile(_ logEntry: String) {
        let data = (logEntry + "\n").data(using: .utf8)!
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: logFileURL)
        }
    }
    
    private func initializeLogFile() {
        let initMessage = """
        =====================================
        ArtWall Application Log
        Started: \(dateFormatter.string(from: Date()))
        macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)
        =====================================
        """
        
        queue.async { [weak self] in
            self?.writeToFile(initMessage)
        }
    }
    
    private static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Log File Management
    
    /// Get the current log file URL
    var currentLogFileURL: URL {
        return logFileURL
    }
    
    /// Clean up old log files (keep last 7 days)
    func cleanupOldLogs() {
        queue.async {
            let logsDirectory = self.logFileURL.deletingLastPathComponent()
            guard let files = try? FileManager.default.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey]) else { return }
            
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            
            for file in files {
                guard file.pathExtension == "log" else { continue }
                
                if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   creationDate < cutoffDate {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        }
    }
}

// MARK: - Process Tracker

/// Tracks the lifecycle of a process for performance and debugging
class ProcessTracker {
    private let processName: String
    private let category: ArtWallLogger.Category
    private let logger: ArtWallLogger
    private let startTime: Date
    
    init(processName: String, category: ArtWallLogger.Category, logger: ArtWallLogger) {
        self.processName = processName
        self.category = category
        self.logger = logger
        self.startTime = Date()
    }
    
    /// Mark process as completed successfully
    func complete() {
        let duration = Date().timeIntervalSince(startTime)
        logger.success("Completed process: \(processName) (took \(String(format: "%.2f", duration))s)", category: category)
    }
    
    /// Mark process as failed
    func fail(error: Error? = nil) {
        let duration = Date().timeIntervalSince(startTime)
        logger.error("Failed process: \(processName) (took \(String(format: "%.2f", duration))s)", error: error, category: category)
    }
    
    /// Log progress update
    func progress(_ message: String) {
        logger.info("[\(processName)] \(message)", category: category)
    }
}

// MARK: - Convenience Extensions

extension ArtWallLogger {
    
    /// Log collection-related events
    static func logCollection(_ message: String, level: Level = .info) {
        shared.log(message, level: level, category: .collections, function: "", file: "", line: 0)
    }
    
    /// Log download-related events
    static func logDownload(_ message: String, level: Level = .info) {
        shared.log(message, level: level, category: .download, function: "", file: "", line: 0)
    }
    
    /// Log wallpaper-related events
    static func logWallpaper(_ message: String, level: Level = .info) {
        shared.log(message, level: level, category: .wallpaper, function: "", file: "", line: 0)
    }
}
