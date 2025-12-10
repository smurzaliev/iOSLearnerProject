//
//  DIContainer.swift
//  learner
//
//  Dependency Injection Container
//
//  📚 LEARNING TOPICS:
//  • Dependency Injection - Inversion of Control
//  • Service Locator Pattern - Centralized dependency management
//  • Singleton Pattern - When and how to use
//  • Protocol-Oriented Programming - Abstraction
//  • SOLID Principles - Dependency Inversion
//

import Foundation
import SwiftData
import SwiftUI

/// 🎯 DEPENDENCY INJECTION
///
/// ✅ WHAT IS DEPENDENCY INJECTION?
/// - Design pattern for providing dependencies from outside
/// - Objects don't create their dependencies
/// - Dependencies are "injected" via initializer, property, or method
///
/// ✅ BENEFITS:
/// - Loose coupling between components
/// - Easy to test (inject mocks)
/// - Easy to swap implementations
/// - Clear dependencies (visible in init)
///
/// ✅ TYPES OF DI:
/// 1. Constructor Injection (preferred) - via init()
/// 2. Property Injection - via property setters
/// 3. Method Injection - via method parameters
///
/// ⚠️ INTERVIEW QUESTION:
/// "Dependency Injection vs Service Locator?"
/// - DI: Dependencies pushed in (explicit, testable)
/// - Service Locator: Dependencies pulled out (implicit, global state)
/// - DI is preferred for testability
/// - Service Locator acceptable for app-level container
///

@MainActor
final class DIContainer {

    // MARK: - Singleton

    /// 📌 SINGLETON PATTERN
    ///
    /// ✅ WHEN TO USE:
    /// - Truly global state (like DI container)
    /// - Single instance makes sense (database, network)
    /// - Lazy initialization needed
    ///
    /// ⚠️ WHEN NOT TO USE:
    /// - For testability (hard to mock singletons)
    /// - When multiple instances needed
    /// - For objects with lifecycle
    ///
    /// 💡 ALTERNATIVE:
    /// Pass container as parameter instead of using shared
    static let shared = DIContainer()

    // MARK: - Dependencies

    /// 📚 LAZY PROPERTIES
    /// - Initialized on first access
    /// - Useful for expensive objects
    /// - Thread-safe in Swift (initialized once)

    /// SwiftData ModelContainer
    /// Manages the database
    lazy var modelContainer: ModelContainer = {
        let schema = Schema([
            ArticleEntity.self,
            NoteEntity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false // Change to true for testing
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            print("✅ [DI] ModelContainer initialized")
            return container
        } catch {
            // 📌 FATAL ERROR
            // Use only when app can't continue without this
            // In production, consider graceful degradation
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    /// ModelContext for main actor
    /// Used by UI for data operations
    lazy var modelContext: ModelContext = {
        let context = ModelContext(modelContainer)
        print("✅ [DI] ModelContext created")
        return context
    }()

    // MARK: - Repositories

    /// 📚 FACTORY METHOD
    /// Creates repository with all dependencies
    ///
    /// ✅ WHY NOT LAZY?
    /// - Returns isolated actor
    /// - Different contexts might need different instances
    /// - Allows customization per call
    func makeArticleRepository() -> ArticleRepositoryImpl {
        ArticleRepositoryImpl(
            modelContext: modelContext
        )
    }

    // MARK: - Use Cases

    /// 📚 FACTORY FOR USE CASES
    /// Each use case gets fresh repository instance
    /// Demonstrates factory pattern
    func makeFetchArticlesUseCase() -> FetchArticlesUseCase {
        let repository = makeArticleRepository()
        return FetchArticlesUseCase(repository: repository)
    }

    // MARK: - Private Initialization

    /// 📌 PRIVATE INIT
    /// Enforces singleton pattern
    /// Only one instance can exist (via .shared)
    private init() {
        print("🏗️ [DI] Container initialized")
    }
}

// MARK: - Singleton Access

/// 📚 SINGLETON PATTERN
///
/// ✅ BENEFITS:
/// - Single source of truth for dependencies
/// - Easy access throughout the app
/// - Lazy initialization
///
/// ⚠️ NOTE:
/// In this learning project, we use the singleton pattern for simplicity.
/// In production apps, consider passing dependencies explicitly
/// through initializers for better testability.

// MARK: - Usage Examples

/// 📚 HOW TO USE:
///
/// 1️⃣ IN APP ENTRY POINT:
/// ```swift
/// @main
/// struct MyApp: App {
///     let container = DIContainer.shared
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .modelContainer(container.modelContainer)
///         }
///     }
/// }
/// ```
///
/// 2️⃣ IN VIEWS:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         // Create ViewModels with dependencies
///         HomeView(
///             viewModel: HomeViewModel(
///                 fetchArticlesUseCase: DIContainer.shared.makeFetchArticlesUseCase()
///             )
///         )
///     }
/// }
/// ```
///
/// 3️⃣ IN TESTS:
/// ```swift
/// func testArticleList() {
///     // Create ViewModels with mock dependencies
///     let mockRepo = MockArticleRepository()
///     let useCase = FetchArticlesUseCase(repository: mockRepo)
///     let viewModel = HomeViewModel(fetchArticlesUseCase: useCase)
///
///     // Test viewModel
/// }
/// ```

// MARK: - Interview Questions

/// 📚 DEPENDENCY INJECTION INTERVIEW QUESTIONS:
///
/// Q: "What are SOLID principles?"
/// A: S - Single Responsibility: Each class has one job
///    O - Open/Closed: Open for extension, closed for modification
///    L - Liskov Substitution: Subtypes must be substitutable
///    I - Interface Segregation: Many specific interfaces > one general
///    D - Dependency Inversion: Depend on abstractions, not concretions
///
/// Q: "How does DI relate to SOLID?"
/// A: DI is the implementation of Dependency Inversion Principle (D)
///    High-level modules depend on abstractions (protocols)
///    Low-level modules implement those abstractions
///
/// Q: "Why use constructor injection?"
/// A: - Makes dependencies explicit
///    - Object is always in valid state
///    - Immutable dependencies (let)
///    - Easy to see what object needs
///    - Compiler checks missing dependencies
///
/// Q: "What's wrong with singletons?"
/// A: - Global mutable state
///    - Hard to test (can't swap implementation)
///    - Hidden dependencies
///    - Tight coupling
///    - Can cause issues in multi-threaded environments
///
///    Use singletons sparingly, prefer DI
///
/// Q: "How to make code testable with DI?"
/// A: 1. Depend on protocols, not concrete types
///    2. Inject dependencies via initializer
///    3. Create mock implementations of protocols
///    4. Pass mocks in tests
///
/// Example:
/// ```swift
/// // Production
/// let viewModel = ArticleListViewModel(
///     fetchUseCase: container.makeFetchArticlesUseCase()
/// )
///
/// // Testing
/// let mockUseCase = MockFetchArticlesUseCase()
/// let viewModel = ArticleListViewModel(
///     fetchUseCase: mockUseCase
/// )
/// ```
///
/// Q: "What's the difference between DI and Service Locator?"
/// A: Dependency Injection:
///    - Dependencies pushed into object
///    - Explicit dependencies
///    - Better for testing
///    - Compile-time safety
///
///    Service Locator:
///    - Object pulls dependencies
///    - Implicit dependencies
///    - Harder to test
///    - Runtime dependency resolution
///
///    DI is generally preferred
