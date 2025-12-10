//
//  ArticleRepositoryProtocol.swift
//  learner
//
//  Repository Pattern - Domain Interface
//
//  📚 LEARNING TOPICS:
//  • Protocol-Oriented Programming (POP) - Swift's paradigm
//  • Repository Pattern - Abstract data sources
//  • Dependency Inversion Principle (SOLID) - Depend on abstractions
//  • Async/Await - Modern asynchronous programming
//  • Combine Framework - Reactive programming
//  • Protocol as Type - Polymorphism in Swift
//

import Foundation
import Combine

/// 🎯 REPOSITORY PATTERN
///
/// ✅ WHAT IS REPOSITORY PATTERN?
/// - Abstraction layer between domain and data layers
/// - Provides clean API for data operations
/// - Hides implementation details (network, database, cache)
/// - Allows swapping implementations (mock for testing, real for production)
///
/// ✅ BENEFITS:
/// - Testability: Easy to mock for unit tests
/// - Flexibility: Change data source without affecting business logic
/// - Single Responsibility: Domain doesn't care about HOW data is fetched
/// - Dependency Inversion: High-level modules don't depend on low-level modules
///
/// ⚠️ INTERVIEW QUESTION:
/// "Why use protocols instead of concrete classes?"
/// - Protocols enable polymorphism without inheritance
/// - Easier to test (can create test doubles)
/// - Supports composition over inheritance
/// - Adheres to SOLID principles (D - Dependency Inversion)
///
protocol ArticleRepositoryProtocol {

    // MARK: - Async/Await Methods

    /// 📚 ASYNC/AWAIT - Modern Swift Concurrency
    ///
    /// ✅ ASYNC KEYWORD:
    /// - Marks function as asynchronous
    /// - Returns a value asynchronously
    /// - Must be called with 'await'
    ///
    /// ✅ THROWS KEYWORD:
    /// - Function can throw errors
    /// - Caller must use try-catch or propagate with try
    ///
    /// ✅ WHY ASYNC/AWAIT vs COMPLETION HANDLERS?
    /// - Sequential code (no callback pyramids)
    /// - Better error handling (throws instead of Result)
    /// - Structured concurrency (automatic cancellation)
    /// - Type-safe (no @escaping issues)

    /// Fetches articles from remote or cache
    /// - Parameters:
    ///   - category: Optional category filter
    ///   - page: Pagination support
    /// - Returns: Array of articles
    /// - Throws: NetworkError if fetching fails
    func fetchArticles(
        category: Article.Category?,
        page: Int
    ) async throws -> [Article]

    /// Searches articles by query
    /// - Parameter query: Search terms
    /// - Returns: Matching articles
    /// - Throws: NetworkError if search fails
    func searchArticles(query: String) async throws -> [Article]

    /// Fetches a single article by ID
    /// - Parameter id: Article identifier
    /// - Returns: Article if found, nil otherwise
    /// - Throws: NetworkError if fetching fails
    func getArticle(id: UUID) async throws -> Article?

    // MARK: - Local Storage (SwiftData)

    /// 📚 SWIFTDATA OPERATIONS
    /// These methods work with local persistent storage

    /// Saves article to favorites
    /// - Parameter article: Article to save
    /// - Throws: Persistence errors
    func saveArticle(_ article: Article) async throws

    /// Removes article from favorites
    /// - Parameter id: Article ID to remove
    /// - Throws: Persistence errors
    func deleteArticle(id: UUID) async throws

    /// Fetches all saved articles
    /// - Returns: Array of favorite articles
    /// - Throws: Persistence errors
    func fetchFavoriteArticles() async throws -> [Article]

    /// Checks if article is saved
    /// - Parameter id: Article ID to check
    /// - Returns: true if article is in favorites
    func isFavorite(id: UUID) async -> Bool

    // MARK: - Combine Publishers

    /// 📚 COMBINE FRAMEWORK - Reactive Programming
    ///
    /// ✅ WHAT IS COMBINE?
    /// - Apple's reactive programming framework
    /// - Handles asynchronous events over time
    /// - Declarative API for processing values
    ///
    /// ✅ PUBLISHER:
    /// - Emits values over time
    /// - Can complete successfully or with error
    /// - Think of it as a "stream" of data
    ///
    /// ✅ ANYPUBLISHER:
    /// - Type-erased publisher
    /// - Hides implementation details
    /// - Makes the protocol cleaner
    ///
    /// ✅ WHY BOTH ASYNC/AWAIT AND COMBINE?
    /// - async/await: One-shot operations (fetch once)
    /// - Combine: Continuous updates (observe changes over time)

    /// Publisher that emits favorite articles whenever they change
    /// - Returns: Publisher that emits article arrays
    ///
    /// 💡 USE CASE:
    /// SwiftUI views can subscribe to this and automatically update
    /// when favorites change (add/remove)
    var favoritesPublisher: AnyPublisher<[Article], Never> { get }

    /// Publisher that emits when articles are updated
    /// - Returns: Publisher that emits when data changes
    var articlesPublisher: AnyPublisher<[Article], Never> { get }
}

// MARK: - Protocol Extension (Default Implementations)

/// 📚 PROTOCOL EXTENSIONS
///
/// ✅ POWERFUL FEATURE:
/// - Provide default implementations
/// - Add methods to protocols without breaking conformance
/// - Share code across all conforming types
///
/// ⚠️ INTERVIEW QUESTION:
/// "What's the difference between protocol requirements and protocol extensions?"
/// - Requirements: Must be implemented by conforming types
/// - Extensions: Optional, can be overridden
///
extension ArticleRepositoryProtocol {

    /// Default implementation: fetch all articles (no category filter)
    func fetchArticles(page: Int = 1) async throws -> [Article] {
        try await fetchArticles(category: nil, page: page)
    }

    /// Default implementation: fetch first page
    func fetchArticles(category: Article.Category?) async throws -> [Article] {
        try await fetchArticles(category: category, page: 1)
    }
}

// MARK: - Why This Matters (Interview Context)

/// 📚 INTERVIEW TALKING POINTS:
///
/// 1️⃣ DEPENDENCY INVERSION PRINCIPLE (SOLID - D)
///    "High-level modules should not depend on low-level modules. Both should depend on abstractions."
///    - Domain layer (high-level) depends on ArticleRepositoryProtocol (abstraction)
///    - Data layer (low-level) implements ArticleRepositoryProtocol
///    - Can swap implementations without changing domain logic
///
/// 2️⃣ TESTABILITY:
///    ```swift
///    class MockArticleRepository: ArticleRepositoryProtocol {
///        func fetchArticles(...) async throws -> [Article] {
///            return [.preview] // Return test data
///        }
///        // ... other methods
///    }
///    ```
///    Easy to create mocks for unit testing!
///
/// 3️⃣ OPEN/CLOSED PRINCIPLE (SOLID - O):
///    - Open for extension (can add new implementations)
///    - Closed for modification (protocol stays stable)
///
/// 4️⃣ INTERFACE SEGREGATION (SOLID - I):
///    - Protocol is focused and cohesive
///    - Could split into smaller protocols if needed:
///      - ArticleReadRepository
///      - ArticleFavoriteRepository
///
/// 5️⃣ ASYNC/AWAIT INTEGRATION:
///    Modern Swift concurrency is first-class in the protocol
///    Shows understanding of latest Swift features
///
/// 6️⃣ COMBINE INTEGRATION:
///    Demonstrates knowledge of reactive programming
///    Shows when to use observers vs one-shot requests
