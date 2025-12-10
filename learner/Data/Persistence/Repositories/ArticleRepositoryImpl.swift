//
//  ArticleRepositoryImpl.swift
//  learner
//
//  Repository Implementation - Data Layer
//
//  📚 LEARNING TOPICS:
//  • Repository Pattern Implementation
//  • Combine Framework - Publishers and Subjects
//  • SwiftData ModelContext - Persistence operations
//  • Async/Await - Asynchronous data operations
//  • Actor - Thread-safe repository
//  • Memory Management - Weak references and retain cycles
//

import Foundation
import Combine
import SwiftData

/// 🎯 REPOSITORY IMPLEMENTATION
///
/// ✅ RESPONSIBILITIES:
/// - Coordinate between network and local storage
/// - Implement caching strategy
/// - Transform data between layers (DTO ↔ Entity ↔ Domain)
/// - Publish changes to observers
///
/// ✅ WHY ACTOR?
/// - Thread-safe access to ModelContext
/// - Concurrent requests handled safely
/// - Prevents data races on shared state
///
/// ⚠️ INTERVIEW QUESTION:
/// "How do you decide between network and cache?"
/// Strategy depends on requirements:
/// 1. Network-first: Always fetch fresh data
/// 2. Cache-first: Use cache, fallback to network
/// 3. Cache-then-network: Show cache, update with network
/// 4. Network-only: Real-time data
/// 5. Cache-only: Offline mode
///
@MainActor
final class ArticleRepositoryImpl: ArticleRepositoryProtocol {

    // MARK: - Dependencies

    /// 📌 DEPENDENCY INJECTION
    /// All dependencies are injected, not created
    /// Makes testing easier (can inject mocks)
    private let modelContext: ModelContext

    // MARK: - Combine Publishers

    /// 📚 CURRENTVALUESUBJECT
    ///
    /// ✅ WHAT IS IT?
    /// - Holds and emits a current value
    /// - New subscribers immediately receive current value
    /// - Can send new values over time
    ///
    /// ✅ WHEN TO USE:
    /// - State that changes over time
    /// - Need current value always available
    /// - Multiple observers watching same data
    ///
    /// 💡 ALTERNATIVE: PASSTHROUGHSUBJECT
    /// - Doesn't hold a value
    /// - Only emits new events
    /// - Use for notifications/events
    private let favoritesSubject = CurrentValueSubject<[Article], Never>([])
    private let articlesSubject = CurrentValueSubject<[Article], Never>([])

    /// 📌 PUBLISHED PROPERTIES (Public Interface)
    /// AnyPublisher hides implementation details (type erasure)
    var favoritesPublisher: AnyPublisher<[Article], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }

    var articlesPublisher: AnyPublisher<[Article], Never> {
        articlesSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // 📌 INITIALIZATION NOTE:
        // We can't use 'await' in init, so we load favorites separately
        // In production, consider using Task in init or lazy loading
    }

    // MARK: - Network Operations

    /// 📚 ASYNC/AWAIT IMPLEMENTATION
    func fetchArticles(
        category: Article.Category?,
        page: Int
    ) async throws -> [Article] {

        // 🎯 FOR LEARNING: Return preview data
        // In production, this would fetch from network

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Return preview articles
        let articles = Article.previews.filter { article in
            if let category = category {
                return article.category == category
            }
            return true
        }

        // Update publisher
        articlesSubject.send(articles)

        print("✅ [Repository] Fetched \(articles.count) articles")
        return articles
    }

    func searchArticles(query: String) async throws -> [Article] {
        // Filter preview articles by query
        let articles = Article.previews.filter { article in
            article.title.localizedCaseInsensitiveContains(query) ||
            article.description.localizedCaseInsensitiveContains(query)
        }
        return articles
    }

    func getArticle(id: UUID) async throws -> Article? {
        // Try local first
        if let local = try fetchLocalArticle(id: id) {
            return local
        }

        // Return from previews
        return Article.previews.first { $0.id == id }
    }

    // MARK: - SwiftData Operations

    /// 📚 SWIFTDATA SAVE OPERATION
    func saveArticle(_ article: Article) async throws {
        // Check if already exists
        let descriptor = FetchDescriptor<ArticleEntity>(
            predicate: #Predicate { $0.id == article.id }
        )

        let existing = try modelContext.fetch(descriptor).first

        if let existing = existing {
            // Update existing
            existing.isFavorite = true
            existing.favoritedDate = Date()
            existing.readCount += 1
        } else {
            // Create new entity
            let entity = ArticleEntity(from: article)
            entity.isFavorite = true
            entity.favoritedDate = Date()
            modelContext.insert(entity)
        }

        // 📌 SWIFTDATA SAVE
        // Must explicitly save the context
        try modelContext.save()

        // Update publisher
        refreshFavorites()

        print("✅ [Repository] Saved article: \(article.title)")
    }

    func deleteArticle(id: UUID) async throws {
        let descriptor = FetchDescriptor<ArticleEntity>(
            predicate: #Predicate { $0.id == id }
        )

        if let entity = try modelContext.fetch(descriptor).first {
            // 📌 CASCADE DELETE
            // Related notes will be deleted automatically
            // because of @Relationship(deleteRule: .cascade)
            modelContext.delete(entity)
            try modelContext.save()

            refreshFavorites()
            print("🗑️ [Repository] Deleted article: \(id)")
        }
    }

    func fetchFavoriteArticles() async throws -> [Article] {
        // 📚 FETCH DESCRIPTOR
        // Modern SwiftData query API
        let descriptor = FetchDescriptor<ArticleEntity>(
            // Predicate macro for type-safe filtering
            predicate: #Predicate { $0.isFavorite == true },
            // Sort by favorited date, newest first
            sortBy: [SortDescriptor(\.favoritedDate, order: .reverse)]
        )

        let entities = try modelContext.fetch(descriptor)
        let articles = entities.map { $0.toDomain() }

        // Update publisher
        favoritesSubject.send(articles)

        return articles
    }

    func isFavorite(id: UUID) async -> Bool {
        let descriptor = FetchDescriptor<ArticleEntity>(
            predicate: #Predicate { $0.id == id && $0.isFavorite == true }
        )

        // 📌 ERROR HANDLING WITH NIL COALESCING
        // Return false if fetch fails (non-critical error)
        return (try? modelContext.fetch(descriptor).first) != nil
    }

    // MARK: - Private Helpers

    private func fetchLocalArticle(id: UUID) throws -> Article? {
        let descriptor = FetchDescriptor<ArticleEntity>(
            predicate: #Predicate { $0.id == id }
        )

        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    private func refreshFavorites() {
        // 📌 DO-TRY-CATCH
        // Handle errors locally, don't propagate
        Task {
            do {
                let favorites = try await fetchFavoriteArticles()
                favoritesSubject.send(favorites)
            } catch {
                print("❌ [Repository] Failed to refresh favorites: \(error)")
            }
        }
    }
}

// MARK: - DTOs (Data Transfer Objects)

/// 📚 DTO PATTERN
/// Separate models for network responses
/// Isolates API changes from domain

struct ArticlesResponse: Decodable {
    let articles: [ArticleDTO]

    /// 📌 CUSTOM CODING KEYS
    /// API might return "data", "items", or "articles"
    enum CodingKeys: String, CodingKey {
        case articles = "articles"
    }
}

struct ArticleDTO: Decodable {
    let id: UUID?
    let title: String
    let description: String?
    let content: String?
    let author: String?
    let publishedAt: String
    let urlToImage: String?
    let category: String?
    let tags: [String]?

    /// Convert DTO to domain model
    func toDomain() -> Article {
        Article(
            id: id ?? UUID(),
            title: title,
            description: description ?? "",
            content: content ?? "",
            author: author ?? "Unknown",
            publishedDate: parseDate(publishedAt),
            imageURL: urlToImage.flatMap { URL(string: $0) },
            category: Article.Category(rawValue: category ?? "Technology") ?? .technology,
            tags: tags ?? []
        )
    }

    private func parseDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
}

// MARK: - Interview Questions

/// 📚 REPOSITORY PATTERN INTERVIEW QUESTIONS:
///
/// Q: "Why separate DTO from Domain Model?"
/// A: - API structure ≠ Domain structure
///    - API changes don't affect business logic
///    - Domain models are pure Swift, DTOs are Codable
///    - Can combine multiple DTOs into one domain model
///
/// Q: "How do you handle offline mode?"
/// A: - Cache-first strategy
///    - Network operations update cache
///    - UI always reads from cache
///    - Sync when network available
///
/// Q: "What's the difference between CurrentValueSubject and PassthroughSubject?"
/// A: CurrentValueSubject:
///    - Stores current value
///    - New subscribers get immediate value
///    - Use for state
///    PassthroughSubject:
///    - No stored value
///    - Only emits new events
///    - Use for notifications
///
/// Q: "How do you prevent memory leaks with Combine?"
/// A: - Store subscriptions in Set<AnyCancellable>
///    - Cancel when object deallocates
///    - Use [weak self] in closures
///    - Avoid retain cycles in publisher chains
///
/// Example:
/// ```swift
/// class ViewModel {
///     var cancellables = Set<AnyCancellable>()
///
///     func observe() {
///         repository.favoritesPublisher
///             .sink { [weak self] articles in
///                 self?.updateUI(articles)
///             }
///             .store(in: &cancellables)
///     }
/// }
/// ```
///
/// Q: "Actor vs DispatchQueue for thread safety?"
/// A: - Actor: Swift concurrency, compile-time safety, cleaner
///    - DispatchQueue: Traditional, more control, manual
///    - Use actors with async/await
///    - Use queues for legacy code or specific needs
