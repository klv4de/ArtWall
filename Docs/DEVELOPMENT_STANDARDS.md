# ArtWall Development Standards

**Date**: January 21, 2025  
**Status**: MANDATORY - All Development Must Follow These Standards

## 🎯 **Core Development Principles**

### **1. MANDATORY: Logging for All New Features**

**RULE**: Every new component, service, or major feature MUST include comprehensive logging.

#### **Required Logging Coverage:**
- **Process Start/End**: Log when major operations begin and complete
- **Error Handling**: All errors must be logged with context and recovery actions
- **User Interactions**: All button clicks and navigation events
- **Data Operations**: File I/O, API calls, database operations
- **Performance Tracking**: Use ProcessTracker for operations >1 second

#### **Implementation Checklist:**
```swift
// ✅ REQUIRED: Add logger to every new class
private let logger = ArtWallLogger.shared

// ✅ REQUIRED: Log initialization
init() {
    logger.info("MyNewService initialized", category: .app)
}

// ✅ REQUIRED: Track major processes
func doSomething() {
    let tracker = logger.startProcess("My Process", category: .app)
    
    do {
        // ... work ...
        tracker.complete()
        logger.success("Process completed", category: .app)
    } catch {
        tracker.fail(error: error)
        logger.error("Process failed", error: error, category: .app)
        throw error
    }
}

// ✅ REQUIRED: Log user interactions
Button(action: {
    logger.info("User clicked MyButton", category: .ui)
    performAction()
}) {
    Text("My Button")
}
```

### **2. MANDATORY: Testing for All New Components**

**RULE**: Every new service or major component MUST include automated tests.

#### **Required Test Coverage:**
- **Component Initialization**: Verify proper setup
- **Core Functionality**: Test primary use cases
- **Error Scenarios**: Test failure conditions and recovery
- **Integration Points**: Test interactions with other components

#### **Implementation Checklist:**
```swift
// ✅ REQUIRED: Add test methods to AppTester.swift
extension AppTester {
    func testMyNewComponent() -> Bool {
        logger.debug("Testing MyNewComponent...", category: .app)
        
        do {
            // Test component functionality
            let component = MyNewComponent()
            let result = component.doSomething()
            
            logger.success("✅ MyNewComponent test passed", category: .app)
            return true
        } catch {
            logger.error("❌ MyNewComponent test failed", error: error, category: .app)
            return false
        }
    }
}

// ✅ REQUIRED: Add to TestComponent enum
enum TestComponent: String, CaseIterable {
    // ... existing cases ...
    case myNewComponent = "My New Component"
}
```

### **3. MANDATORY: Documentation Updates**

**RULE**: All new features must update relevant documentation.

#### **Required Documentation:**
- **LOGGING_AND_TESTING.md**: Add component to coverage analysis
- **TECH_STACK_DECISIONS.md**: Document architectural decisions
- **PRD.md**: Update feature status and roadmap
- **README.md**: Update user-facing features

### **4. MANDATORY: Error Handling Standards**

**RULE**: All new code must follow consistent error handling patterns.

#### **Error Handling Checklist:**
```swift
// ✅ REQUIRED: Structured error types
enum MyComponentError: LocalizedError {
    case invalidInput(String)
    case networkFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let details):
            return "Invalid input: \(details)"
        case .networkFailure(let details):
            return "Network error: \(details)"
        }
    }
}

// ✅ REQUIRED: Comprehensive error logging
do {
    try performOperation()
} catch let error as MyComponentError {
    logger.error("Specific component error", error: error, category: .error)
    throw error
} catch {
    logger.error("Unexpected error in MyComponent", error: error, category: .error)
    throw MyComponentError.networkFailure(error.localizedDescription)
}
```

## 🔧 **Implementation Standards**

### **Code Quality Requirements**

#### **1. Compilation Standards**
- **ZERO TOLERANCE**: Code must compile cleanly before any commits [[memory:7041134]]
- **No Warnings**: Address all compiler warnings before submission
- **Clean Build**: Verify with fresh build before committing

#### **2. UI/UX Standards**
- **Consistent Components**: Use reusable components following design system [[memory:7039715]]
- **User Approval**: No UI changes without explicit approval [[memory:7039715]]
- **Accessibility**: All UI elements must be accessible

#### **3. Performance Standards**
- **Process Tracking**: Operations >1 second must use ProcessTracker
- **Timeout Protection**: Network operations must have timeouts
- **Graceful Degradation**: Handle partial failures appropriately

### **Development Workflow**

#### **1. Pre-Development Checklist**
- [ ] Read all current documentation
- [ ] Understand existing logging patterns
- [ ] Review similar components for consistency
- [ ] Plan logging and testing approach

#### **2. During Development**
- [ ] Add logging as you write code (not as an afterthought)
- [ ] Test error scenarios and edge cases
- [ ] Verify timeout and fallback behaviors
- [ ] Update documentation incrementally

#### **3. Pre-Commit Checklist**
- [ ] All code compiles cleanly
- [ ] Logging implemented for all major operations
- [ ] Tests added for new components
- [ ] Documentation updated
- [ ] Error handling follows standards
- [ ] User approval received for UI changes

## 📊 **Quality Gates**

### **Automated Checks**
- **System Tests**: Must pass all AppTester health checks
- **Compilation**: Zero errors, zero warnings
- **Logging Coverage**: All major processes must have logging

### **Manual Review**
- **Code Review**: Verify logging and testing standards
- **Documentation Review**: Ensure complete documentation updates
- **User Experience**: Verify UI consistency and accessibility

## 🚨 **Enforcement**

### **Blocking Criteria**
The following issues BLOCK all development progress:
1. **Compilation Errors**: Fix immediately, never work around
2. **Missing Logging**: No new features without comprehensive logging
3. **Missing Tests**: No new components without automated tests
4. **Undocumented Changes**: All major changes must be documented

### **Review Process**
1. **Self-Review**: Developer verifies all standards met
2. **Documentation Review**: All docs updated appropriately
3. **Testing Verification**: All tests pass and new tests added
4. **User Approval**: UI changes approved before implementation

## 📚 **Reference Templates**

### **New Service Template**
```swift
import Foundation

class MyNewService: ObservableObject {
    private let logger = ArtWallLogger.shared
    
    init() {
        logger.info("MyNewService initialized", category: .app)
    }
    
    func performOperation() async throws {
        let tracker = logger.startProcess("My Operation", category: .app)
        
        do {
            logger.debug("Starting operation with parameters...", category: .app)
            
            // ... implementation ...
            
            tracker.complete()
            logger.success("Operation completed successfully", category: .app)
        } catch {
            tracker.fail(error: error)
            logger.error("Operation failed", error: error, category: .app)
            throw error
        }
    }
}
```

### **New View Template**
```swift
import SwiftUI

struct MyNewView: View {
    private let logger = ArtWallLogger.shared
    
    var body: some View {
        VStack {
            Button("My Action") {
                logger.info("User clicked My Action button", category: .ui)
                performAction()
            }
        }
        .task {
            logger.info("MyNewView appeared", category: .ui)
            await loadData()
        }
    }
    
    private func performAction() {
        let tracker = logger.startProcess("My View Action", category: .ui)
        
        // ... implementation ...
        
        tracker.complete()
    }
}
```

### **New Test Template**
```swift
// Add to AppTester.swift
func testMyNewComponent() -> Bool {
    logger.debug("Testing MyNewComponent functionality...", category: .app)
    
    do {
        let component = MyNewComponent()
        
        // Test initialization
        guard component.isInitialized else {
            logger.error("❌ MyNewComponent initialization test failed", category: .app)
            return false
        }
        
        // Test core functionality
        let result = try component.performOperation()
        guard result.isValid else {
            logger.error("❌ MyNewComponent functionality test failed", category: .app)
            return false
        }
        
        logger.success("✅ MyNewComponent test passed", category: .app)
        return true
        
    } catch {
        logger.error("❌ MyNewComponent test failed", error: error, category: .app)
        return false
    }
}
```

## 🎯 **Success Metrics**

### **Development Quality Indicators**
- **100% Logging Coverage**: All major processes logged
- **100% Test Coverage**: All components have automated tests
- **Zero Compilation Issues**: Clean builds always
- **Complete Documentation**: All changes documented
- **User Satisfaction**: UI changes approved and consistent

### **Debugging Efficiency Metrics**
- **Issue Resolution Time**: <30 minutes with comprehensive logs
- **Root Cause Identification**: <5 minutes with process tracking
- **System Health Visibility**: Real-time status via automated tests

---

## 🚀 **Implementation Priority**

**IMMEDIATE**: All future development must follow these standards
**RETROACTIVE**: Existing code already meets these standards (completed January 2025)
**ENFORCEMENT**: These standards are non-negotiable for code quality

---

## 🏗️ **Architecture Standards (Updated August 2025)**

### **Service Architecture Patterns**
- **Single Responsibility**: Each service handles one domain (downloads, wallpapers, logging, testing)
- **Singleton Pattern**: Use `static let shared` for services that need persistent state across navigation
- **Dependency Injection**: Services should be injected rather than created inline
- **Error Propagation**: Use structured error types, don't swallow exceptions
- **State Management**: Use `@Published` properties for UI-observable state

### **SwiftUI Integration Patterns**
- **State Management**: Use `@StateObject` for owned objects, `@ObservedObject` for shared instances
- **Singleton Integration**: Use `@ObservedObject` with `.shared` instances for persistent state
- **View Composition**: Break complex views into smaller, reusable components
- **Performance**: Use `LazyVGrid` for large collections, `AsyncImage` for network images
- **Navigation**: Use SwiftUI's native navigation with proper dismissal handling

### **Image Loading Architecture**
- **GitHub CDN First**: Always prioritize GitHub-hosted images for reliability and performance
- **Fallback Strategy**: Maintain Chicago Art Institute API as fallback in `Artwork.imageURL`
- **URL Caching**: Use `URLCache.shared` configuration for system-level image caching
- **Testing**: Verify GitHub image accessibility in automated tests

### **Singleton Implementation Standards**
```swift
// ✅ CORRECT: Singleton with private init
class MySharedService: ObservableObject {
    static let shared = MySharedService()
    
    @Published var state: ServiceState = .idle
    private let logger = ArtWallLogger.shared
    
    private init() {
        logger.info("MySharedService shared instance initialized", category: .app)
    }
}

// ✅ CORRECT: SwiftUI integration
struct MyView: View {
    @ObservedObject private var service = MySharedService.shared
    
    var body: some View {
        // UI that reacts to shared service state
    }
}
```

---

## 🚀 **Performance Optimization Standards**

### **MANDATORY: Performance Testing and Optimization**

**RULE**: All performance-critical operations must be measured and optimized.

#### **Performance Optimization Checklist:**
```swift
// ✅ REQUIRED: Measure timing for critical operations
logger.debug("Starting performance-critical operation", category: .performance)
let startTime = Date()

// Perform operation
try performCriticalOperation()

let duration = Date().timeIntervalSince(startTime)
logger.success("Operation completed in \(String(format: "%.3f", duration))s", category: .performance)
```

#### **Performance Standards:**
- **Wallpaper Operations**: < 0.02 seconds for optimal user experience
- **Collection Loading**: < 2.0 seconds for good user experience  
- **Image Downloads**: Progress tracking required for operations > 1 second
- **UI Responsiveness**: No blocking operations on main thread

#### **Optimization Approaches (Validated):**
1. **Code Streamlining**: Remove unnecessary operations (97% speed improvement achieved)
2. **Logging Optimization**: Minimize verbose logging in performance-critical paths
3. **API Call Optimization**: Direct API usage without wrapper overhead
4. **System Integration**: Prefer proven approaches over experimental system modifications

#### **Performance Anti-Patterns (Learned from Experience):**
- **System-level modifications** (PlistBuddy, etc.) can create worse user experiences
- **Premature system optimization** before understanding root causes
- **Complex solutions** when simple optimizations provide better results
- **Verbose logging** in performance-critical loops

### **MANDATORY: Multi-Monitor Considerations**

**RULE**: All wallpaper operations must account for multi-monitor complexity.

#### **Multi-Monitor Standards:**
```swift
// ✅ REQUIRED: Log screen detection
let screens = NSScreen.screens
logger.debug("Found \(screens.count) screens", category: .wallpaper)

// ✅ REQUIRED: Use .all for consistent behavior
try Wallpaper.set(imageURL, screen: .all, scale: .fit, fillColor: .black)

// ✅ REQUIRED: Acknowledge sequential behavior as system limitation
logger.info("Multi-monitor sequential application is macOS system behavior", category: .wallpaper)
```

---

**These standards ensure ArtWall maintains the highest quality, reliability, maintainability, and performance excellence as it grows and evolves.**
