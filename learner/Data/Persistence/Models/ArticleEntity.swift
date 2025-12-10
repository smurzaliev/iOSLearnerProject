//
//  ArticleEntity.swift
//  learner
//
//  SwiftData Persistence Model
//
//  📚 LEARNING TOPICS:
//  • SwiftData - Modern persistence framework (iOS 17+)
//  • @Model Macro - Automatic SwiftData model generation
//  • Relationships - One-to-many, many-to-many
//  • @Attribute - Property customization
//  • @Relationship - Relationship configuration
//  • Cascade Delete - Automatic cleanup
//  • Transformable - Custom type storage
//

import Foundation
import SwiftData

/// 🎯 SWIFTDATA MODEL
///
/// ✅ WHAT IS SWIFTDATA?
/// - Modern replacement for Core Data
/// - Uses Swift macros for automatic code generation
/// - Type-safe queries
/// - SwiftUI integration
/// - Less boilerplate than Core Data
///
/// ✅ @MODEL MACRO:
/// - Marks class as SwiftData model
/// - Automatically generates persistence code
/// - Creates schema information
/// - Enables queries and relationships
///
/// ⚠️ INTERVIEW QUESTION:
/// "SwiftData vs Core Data?"
/// - SwiftData: Modern, macro-based, SwiftUI-first, less code
/// - Core Data: Mature, more features, works on older iOS
/// - Both use SQLite underneath
/// - SwiftData is the future, Core Data still widely used
///

@Model
final class ArticleEntity {

    // MARK: - Properties

    /// 📌 PRIMARY KEY
    /// @Attribute(.unique) makes this the primary identifier
    /// Prevents duplicate entries
    @Attribute(.unique) var id: UUID

    /// Basic properties - automatically persisted
    var title: String
    var articleDescription: String
    var content: String
    var author: String
    var publishedDate: Date

    /// 📌 TRANSFORMABLE ATTRIBUTE
    /// URL is not directly storable, so SwiftData transforms it
    /// Converts URL ↔ Data automatically
    var imageURL: URL?

    /// Enum stored as raw value (String)
    var category: String

    /// 📌 ARRAY TRANSFORMATION
    /// Arrays of simple types are automatically handled
    var tags: [String]

    /// 📚 COMPUTED PROPERTY
    /// Not stored in database, calculated on access
    /// Same as domain model
    var readingTime: Int {
        let wordCount = content.split(separator: " ").count
        return max(1, wordCount / 200)
    }

    // MARK: - Metadata

    /// Additional metadata for favorites
    var isFavorite: Bool
    var favoritedDate: Date?
    var readCount: Int

    /// 📌 @RELATIONSHIP
    /// Demonstrates one-to-many relationship
    /// One article can have many notes
    ///
    /// ✅ DELETE RULE:
    /// - .cascade: Delete notes when article is deleted
    /// - .nullify: Set foreign key to nil
    /// - .deny: Prevent deletion if notes exist
    @Relationship(deleteRule: .cascade, inverse: \NoteEntity.article)
    var notes: [NoteEntity]?

    // MARK: - Initialization

    /// 📌 REQUIRED INITIALIZER
    /// SwiftData models need explicit initializers
    /// All properties must be initialized
    init(
        id: UUID = UUID(),
        title: String,
        articleDescription: String,
        content: String,
        author: String,
        publishedDate: Date = Date(),
        imageURL: URL? = nil,
        category: String,
        tags: [String] = [],
        isFavorite: Bool = false,
        favoritedDate: Date? = nil,
        readCount: Int = 0,
        notes: [NoteEntity]? = nil
    ) {
        self.id = id
        self.title = title
        self.articleDescription = articleDescription
        self.content = content
        self.author = author
        self.publishedDate = publishedDate
        self.imageURL = imageURL
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.favoritedDate = favoritedDate
        self.readCount = readCount
        self.notes = notes
    }
}

// MARK: - Conversion Extensions

/// 📚 MAPPER PATTERN
/// Convert between domain model and persistence model
/// Keeps layers independent
extension ArticleEntity {

    /// Convert domain Article to ArticleEntity
    convenience init(from article: Article) {
        self.init(
            id: article.id,
            title: article.title,
            articleDescription: article.description,
            content: article.content,
            author: article.author,
            publishedDate: article.publishedDate,
            imageURL: article.imageURL,
            category: article.category.rawValue,
            tags: article.tags,
            isFavorite: false,
            favoritedDate: nil,
            readCount: 0
        )
    }

    /// Convert ArticleEntity to domain Article
    func toDomain() -> Article {
        Article(
            id: id,
            title: title,
            description: articleDescription,
            content: content,
            author: author,
            publishedDate: publishedDate,
            imageURL: imageURL,
            category: Article.Category(rawValue: category) ?? .technology,
            tags: tags
        )
    }
}

// MARK: - Note Entity (Relationship Example)

/// 📚 RELATIONSHIP EXAMPLE
/// Demonstrates one-to-many relationship
@Model
final class NoteEntity {

    @Attribute(.unique) var id: UUID
    var text: String
    var createdDate: Date

    /// 📌 INVERSE RELATIONSHIP
    /// Points back to the parent article
    /// SwiftData maintains this automatically
    var article: ArticleEntity?

    init(
        id: UUID = UUID(),
        text: String,
        createdDate: Date = Date(),
        article: ArticleEntity? = nil
    ) {
        self.id = id
        self.text = text
        self.createdDate = createdDate
        self.article = article
    }
}

// MARK: - Interview Talking Points

/// 📚 SWIFTDATA INTERVIEW QUESTIONS:
///
/// Q: "How does SwiftData work internally?"
/// A: - Uses Swift macros to generate code at compile time
///    - @Model expands to property wrappers and schema code
///    - Creates SQLite database under the hood
///    - ModelContext manages the persistence context
///
/// Q: "What are the main SwiftData components?"
/// A: 1. @Model - Marks class as persistable
///    2. ModelContainer - Database container
///    3. ModelContext - Manages changes and saves
///    4. @Query - Fetches data in SwiftUI views
///
/// Q: "How do you query SwiftData?"
/// A: In SwiftUI:
/// ```swift
/// @Query(filter: #Predicate<ArticleEntity> { $0.isFavorite })
/// var favorites: [ArticleEntity]
/// ```
///
/// In code:
/// ```swift
/// let descriptor = FetchDescriptor<ArticleEntity>(
///     predicate: #Predicate { $0.isFavorite },
///     sortBy: [SortDescriptor(\.publishedDate, order: .reverse)]
/// )
/// let articles = try context.fetch(descriptor)
/// ```
///
/// Q: "How to handle migrations?"
/// A: - SwiftData handles lightweight migrations automatically
///    - For complex changes, use VersionedSchema and MigrationPlan
///    - Define old and new schemas explicitly
///
/// Q: "SwiftData relationships explained?"
/// A: - @Relationship macro defines connections
///    - deleteRule: What happens when parent is deleted
///    - inverse: Bidirectional relationship maintenance
///    - One-to-many: Parent has array, child has single reference
///    - Many-to-many: Both sides have arrays
///
/// Example many-to-many:
/// ```swift
/// @Model class Article {
///     @Relationship(inverse: \Tag.articles) var tags: [Tag]
/// }
///
/// @Model class Tag {
///     @Relationship(inverse: \Article.tags) var articles: [Article]
/// }
/// ```
///
/// Q: "Performance optimization in SwiftData?"
/// A: 1. Use @Query with predicates (database-level filtering)
///    2. Fetch only needed properties
///    3. Use batch operations for multiple changes
///    4. Index frequently queried properties
///    5. Avoid loading large relationships eagerly
///
/// Q: "How to test SwiftData?"
/// A: - Use ModelContainer with inMemory: true
///    - No disk writes, fast tests
///    - Clean slate for each test
/// ```swift
/// let container = try ModelContainer(
///     for: ArticleEntity.self,
///     configurations: ModelConfiguration(isStoredInMemoryOnly: true)
/// )
/// ```
