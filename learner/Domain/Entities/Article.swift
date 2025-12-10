//
//  Article.swift
//  learner
//
//  Domain Entity - Core Business Model
//
//  📚 LEARNING TOPICS:
//  • Domain-Driven Design (DDD) - Entities represent core business concepts
//  • Value Objects vs Entities - Entities have identity (ID), value objects don't
//  • Identifiable Protocol - Makes objects uniquely identifiable for SwiftUI
//  • Hashable & Equatable - For collections and comparisons
//  • Codable - For JSON serialization/deserialization
//  • Structs vs Classes - Structs for immutable data, value semantics
//

import Foundation

/// 🎯 DOMAIN ENTITY
/// This represents the core business concept of an Article in our domain.
///
/// ✅ WHY STRUCT?
/// - Value semantics (copy-on-write) prevents unexpected mutations
/// - Thread-safe by default (no shared mutable state)
/// - Preferred in Swift for data models
/// - Better performance for small to medium-sized data
///
/// ✅ CLEAN ARCHITECTURE PRINCIPLE:
/// - Domain entities are INDEPENDENT of frameworks (no SwiftUI, no SwiftData here)
/// - Pure business logic - can be used in any platform (iOS, macOS, watchOS)
/// - No external dependencies
///
struct Article: Identifiable, Hashable, Codable, Sendable {

    // MARK: - Properties

    /// 📌 Identifiable Conformance
    /// The `id` property makes this conform to Identifiable protocol
    /// This is essential for SwiftUI's ForEach, List, and other ID-based views
    let id: UUID

    /// Article metadata
    let title: String
    let description: String
    let content: String
    let author: String
    let publishedDate: Date
    let imageURL: URL?
    let category: Category
    let tags: [String]

    /// Computed property - doesn't get encoded/decoded
    /// Shows how to exclude properties from Codable
    var readingTime: Int {
        // Rough estimate: average reading speed is 200 words per minute
        let wordCount = content.split(separator: " ").count
        return max(1, wordCount / 200)
    }

    // MARK: - Nested Types

    /// 📚 NESTED ENUM
    /// Demonstrates organizing related types within the parent
    /// Also shows CaseIterable for getting all cases
    enum Category: String, Codable, CaseIterable, Sendable {
        case technology = "Technology"
        case science = "Science"
        case business = "Business"
        case health = "Health"
        case entertainment = "Entertainment"
        case sports = "Sports"

        /// Custom properties on enum cases
        var icon: String {
            switch self {
            case .technology: return "laptopcomputer"
            case .science: return "flask"
            case .business: return "briefcase"
            case .health: return "heart"
            case .entertainment: return "tv"
            case .sports: return "sportscourt"
            }
        }

        /// Demonstrates computed properties on enums
        var color: String {
            switch self {
            case .technology: return "blue"
            case .science: return "green"
            case .business: return "orange"
            case .health: return "red"
            case .entertainment: return "purple"
            case .sports: return "yellow"
            }
        }
    }

    // MARK: - Initialization

    /// 📌 MEMBERWISE INITIALIZER
    /// Swift provides this automatically, but we can customize it
    /// Notice: All parameters have default values for easier testing
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        content: String,
        author: String,
        publishedDate: Date = Date(),
        imageURL: URL? = nil,
        category: Category,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
        self.author = author
        self.publishedDate = publishedDate
        self.imageURL = imageURL
        self.category = category
        self.tags = tags
    }

    // MARK: - Codable Implementation

    /// 📚 CUSTOM CODING KEYS
    /// Maps Swift property names to JSON keys
    /// Useful when API uses snake_case and Swift uses camelCase
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case author
        case publishedDate = "published_date"  // 👈 Snake case in JSON
        case imageURL = "image_url"            // 👈 Converts to URL automatically
        case category
        case tags
        // Note: readingTime is NOT here, so it won't be encoded/decoded
    }

    // MARK: - Hashable & Equatable

    /// 📌 HASHABLE
    /// Swift synthesizes this automatically for structs with Hashable properties
    /// But we can customize it if needed:
    ///
    /// func hash(into hasher: inout Hasher) {
    ///     hasher.combine(id)  // Only hash the ID for performance
    /// }

    /// 📌 EQUATABLE
    /// Also synthesized automatically, compares all properties
    /// Custom implementation would look like:
    ///
    /// static func == (lhs: Article, rhs: Article) -> Bool {
    ///     lhs.id == rhs.id  // Two articles are equal if IDs match
    /// }
}

// MARK: - Extensions

/// 📚 EXTENSION FOR MOCK DATA
/// Separate concerns: core model vs testing/preview data
extension Article {

    /// 🎯 STATIC FACTORY METHOD
    /// Creates sample data for previews and tests
    /// This pattern is called "Factory Method"
    static var preview: Article {
        Article(
            title: "The Future of AI in Mobile Development",
            description: "Exploring how artificial intelligence is revolutionizing iOS app development",
            content: """
            Artificial Intelligence is transforming how we build mobile applications. \
            From ML models integrated directly into apps using Core ML, to natural language \
            processing with Apple's NLP framework, the possibilities are endless. \
            SwiftUI's declarative syntax combined with Create ML makes it easier than ever \
            to add intelligence to your apps without being a data scientist.
            """,
            author: "Sarah Johnson",
            category: .technology,
            tags: ["AI", "Swift", "iOS", "Machine Learning"]
        )
    }

    /// Array of preview data
    static var previews: [Article] {
        [
            Article(
                title: "SwiftUI Performance Optimization",
                description: "Best practices for building fast SwiftUI apps",
                content: "Performance is crucial for user experience...",
                author: "John Doe",
                category: .technology,
                tags: ["SwiftUI", "Performance"]
            ),
            Article(
                title: "Understanding Async/Await",
                description: "Deep dive into Swift's modern concurrency",
                content: "Async/await revolutionizes asynchronous programming...",
                author: "Jane Smith",
                category: .technology,
                tags: ["Swift", "Concurrency", "Async"]
            ),
            Article(
                title: "Breakthrough in Quantum Computing",
                description: "Scientists achieve new milestone",
                content: "Quantum computing reaches new heights...",
                author: "Dr. Alex Chen",
                category: .science,
                tags: ["Quantum", "Research"]
            )
        ]
    }
}

// MARK: - Sendable Conformance

/// 📚 SENDABLE PROTOCOL
/// New in Swift 5.5+ for concurrency safety
///
/// ✅ What is Sendable?
/// - Marker protocol indicating a type is safe to share across concurrency domains
/// - Structs with all Sendable properties automatically conform
/// - Classes must use @unchecked Sendable or have all properties Sendable + immutable
///
/// ✅ Why does it matter?
/// - Prevents data races at compile time
/// - Ensures values can safely cross actor boundaries
/// - Required for async/await and actor isolation
///
/// Our Article struct is Sendable because:
/// 1. It's a struct (value type - copied when passed)
/// 2. All properties are Sendable (String, Int, Date, UUID, URL, etc.)
/// 3. No mutable reference types
