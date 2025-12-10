//
//  FetchArticlesUseCase.swift
//  learner
//
//  Use Case - Business Logic Layer
//
//  📚 LEARNING TOPICS:
//  • Use Case Pattern - Single responsibility business logic
//  • Clean Architecture - Domain layer independence
//  • Async/Await - Asynchronous operations
//  • Dependency Injection - Constructor injection
//  • Protocol-Oriented Programming - Testable design
//  • Actor - Thread-safe state management
//

import Foundation

/// 🎯 USE CASE PATTERN
///
/// ✅ WHAT IS A USE CASE?
/// - Represents a single business operation
/// - Contains business logic and rules
/// - Orchestrates data flow between layers
/// - Independent of UI and frameworks
///
/// ✅ BENEFITS:
/// - Single Responsibility Principle (SOLID - S)
/// - Testable in isolation
/// - Reusable across different UIs (iOS, macOS, watchOS)
/// - Clear separation of concerns
///
/// ⚠️ INTERVIEW QUESTION:
/// "Why separate use cases from ViewModels?"
/// - ViewModels handle UI state and presentation logic
/// - Use cases handle business rules and data orchestration
/// - Use cases can be reused in different ViewModels
/// - Easier to test business logic without UI dependencies
///

/// 📚 ACTOR - Thread-Safe State Management
///
/// ✅ WHAT ARE ACTORS?
/// - New in Swift 5.5
/// - Reference type that protects its mutable state
/// - Prevents data races at compile time
/// - Access to actor properties requires 'await'
///
/// ✅ WHY USE ACTOR HERE?
/// - Caching logic needs thread safety
/// - Multiple concurrent requests might access cache
/// - Prevents race conditions automatically
///
/// ⚠️ INTERVIEW QUESTION:
/// "Actor vs Class with locks?"
/// - Actor: Compiler-enforced safety, cleaner code
/// - Class with locks: Manual synchronization, error-prone
/// - Actors integrate seamlessly with async/await
///
actor FetchArticlesUseCase {

    // MARK: - Properties

    /// 📌 DEPENDENCY INJECTION via PROTOCOL
    /// - Depends on abstraction (protocol), not implementation
    /// - Can inject mock repository for testing
    /// - Demonstrates Dependency Inversion Principle
    private let repository: ArticleRepositoryProtocol

    /// 📌 CACHE STATE (Protected by Actor)
    /// - Actor ensures thread-safe access
    /// - Multiple tasks can't modify this simultaneously
    /// - Access requires 'await' from outside the actor
    private var cache: [String: CachedResult] = [:]

    /// Cache entry with timestamp for expiration
    private struct CachedResult {
        let articles: [Article]
        let timestamp: Date

        var isExpired: Bool {
            // Cache expires after 5 minutes
            Date().timeIntervalSince(timestamp) > 300
        }
    }

    // MARK: - Initialization

    /// 📌 CONSTRUCTOR INJECTION
    /// - Dependencies passed via initializer
    /// - Makes dependencies explicit and testable
    /// - Preferred over property injection or service locator
    ///
    /// ✅ INTERVIEW TIP:
    /// "What are different types of Dependency Injection?"
    /// 1. Constructor Injection (used here) - Best for required dependencies
    /// 2. Property Injection - For optional dependencies
    /// 3. Method Injection - For operation-specific dependencies
    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Interface

    /// Executes the use case: fetch articles with caching logic
    ///
    /// 📚 BUSINESS RULES IMPLEMENTED HERE:
    /// 1. Check cache first
    /// 2. Return cached data if valid
    /// 3. Fetch from repository if cache miss or expired
    /// 4. Update cache with fresh data
    /// 5. Handle pagination
    ///
    /// - Parameters:
    ///   - category: Optional category filter
    ///   - page: Page number for pagination
    ///   - forceRefresh: Bypass cache and fetch fresh data
    /// - Returns: Array of articles
    /// - Throws: NetworkError if fetch fails
    ///
    /// ⚠️ NOTE: This is NOT marked as async on the actor itself
    /// because actor methods are implicitly async when called from outside
    func execute(
        category: Article.Category? = nil,
        page: Int = 1,
        forceRefresh: Bool = false
    ) async throws -> [Article] {

        // Create cache key based on parameters
        let cacheKey = makeCacheKey(category: category, page: page)

        // 📌 CACHE STRATEGY
        // Business rule: Use cache unless force refresh or expired
        if !forceRefresh,
           let cached = cache[cacheKey],
           !cached.isExpired {
            print("📦 [UseCase] Returning cached articles for key: \(cacheKey)")
            return cached.articles
        }

        print("🌐 [UseCase] Fetching articles from repository")

        // 📌 ERROR HANDLING
        // Let errors propagate to the caller (ViewModel)
        // ViewModel will handle presentation of errors
        do {
            let articles = try await repository.fetchArticles(
                category: category,
                page: page
            )

            // 📌 BUSINESS LOGIC: Filter and sort
            let processedArticles = applyBusinessRules(to: articles)

            // Update cache
            cache[cacheKey] = CachedResult(
                articles: processedArticles,
                timestamp: Date()
            )

            print("✅ [UseCase] Fetched \(articles.count) articles")
            return processedArticles

        } catch {
            print("❌ [UseCase] Failed to fetch articles: \(error)")
            throw error
        }
    }

    /// Clears the cache
    /// Useful for pull-to-refresh or logout scenarios
    func clearCache() {
        cache.removeAll()
        print("🗑️ [UseCase] Cache cleared")
    }

    // MARK: - Private Helpers

    /// Creates a unique cache key
    private func makeCacheKey(category: Article.Category?, page: Int) -> String {
        let categoryKey = category?.rawValue ?? "all"
        return "\(categoryKey)_page_\(page)"
    }

    /// 📚 BUSINESS RULES
    /// This is where domain-specific logic lives
    ///
    /// Examples of business rules:
    /// - Filter inappropriate content
    /// - Sort by relevance or date
    /// - Apply user preferences
    /// - Calculate derived values
    private func applyBusinessRules(to articles: [Article]) -> [Article] {
        articles
            // Remove articles older than 30 days (business rule)
            .filter { article in
                let thirtyDaysAgo = Calendar.current.date(
                    byAdding: .day,
                    value: -30,
                    to: Date()
                ) ?? Date()
                return article.publishedDate >= thirtyDaysAgo
            }
            // Sort by most recent first
            .sorted { $0.publishedDate > $1.publishedDate }
    }
}

// MARK: - Actor Isolation Explanation

/// 📚 UNDERSTANDING ACTOR ISOLATION:
///
/// ✅ HOW ACTORS WORK:
/// ```swift
/// let useCase = FetchArticlesUseCase(repository: repo)
///
/// // ❌ This won't compile (actor-isolated property):
/// // let cache = useCase.cache
///
/// // ✅ This works (async method call):
/// let articles = await useCase.execute()
/// ```
///
/// ✅ ACTOR VS CLASS:
/// ```swift
/// class UseCaseClass {
///     private var cache = [String: CachedResult]()
///     // ⚠️ Race condition possible!
///     func execute() async -> [Article] {
///         cache["key"] = value // Not thread-safe
///     }
/// }
///
/// actor UseCaseActor {
///     private var cache = [String: CachedResult]()
///     // ✅ Thread-safe automatically
///     func execute() async -> [Article] {
///         cache["key"] = value // Safe!
///     }
/// }
/// ```
///
/// ✅ INTERVIEW TALKING POINTS:
/// 1. Actors prevent data races at COMPILE TIME
/// 2. Only one task can access actor state at a time
/// 3. Async context automatically when calling from outside
/// 4. Synchronous access from within the same actor
/// 5. @MainActor for main thread operations (UI updates)

// MARK: - Alternative Approaches

/// 📚 OTHER WAYS TO IMPLEMENT USE CASES:
///
/// 1️⃣ PROTOCOL-BASED (More testable):
/// ```swift
/// protocol FetchArticlesUseCaseProtocol {
///     func execute(...) async throws -> [Article]
/// }
///
/// actor FetchArticlesUseCase: FetchArticlesUseCaseProtocol {
///     // Implementation
/// }
/// ```
///
/// 2️⃣ STRUCT WITH DEPENDENCY (No state):
/// ```swift
/// struct FetchArticlesUseCase {
///     let repository: ArticleRepositoryProtocol
///     func execute(...) async throws -> [Article] {
///         try await repository.fetchArticles(...)
///     }
/// }
/// ```
///
/// 3️⃣ STATIC METHOD (Stateless utility):
/// ```swift
/// enum FetchArticlesUseCase {
///     static func execute(
///         repository: ArticleRepositoryProtocol,
///         ...
///     ) async throws -> [Article] {
///         // Implementation
///     }
/// }
/// ```
///
/// 💡 CHOOSE BASED ON:
/// - Need for state → Actor/Class
/// - Thread safety required → Actor
/// - Stateless → Struct or static method
/// - Need to mock → Protocol
