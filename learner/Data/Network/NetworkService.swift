//
//  NetworkService.swift
//  learner
//
//  Modern Networking with Async/Await
//
//  📚 LEARNING TOPICS:
//  • URLSession with async/await - Modern networking
//  • Generic Functions - Type-safe API calls
//  • Codable - JSON encoding/decoding
//  • Error Handling - Custom errors and propagation
//  • HTTP Methods - REST API patterns
//  • Request/Response Models - Type safety
//  • Result Type - Success/Failure handling
//

import Foundation

/// 🎯 NETWORK SERVICE
///
/// ✅ MODERN NETWORKING APPROACH:
/// - Async/await instead of completion handlers
/// - Generic methods for type safety
/// - Protocol-based for testability
/// - Centralized error handling
///
/// ⚠️ INTERVIEW QUESTION:
/// "Why async/await over completion handlers?"
/// 1. Sequential code (no pyramid of doom)
/// 2. Better error handling (try-catch)
/// 3. Automatic thread safety
/// 4. Cancellation support (Task)
/// 5. Type safety (no @escaping gotchas)
///

actor NetworkService {

    // MARK: - Properties

    /// 📌 URLSESSION
    /// - System framework for networking
    /// - Supports async/await natively (iOS 15+)
    /// - Can be customized with URLSessionConfiguration
    private let session: URLSession

    /// Base URL for API endpoints
    /// In production, this would come from environment config
    private let baseURL: URL

    /// 📌 ACTOR ISOLATION
    /// Actor ensures thread-safe access to shared state
    /// Only one task can access these properties at a time

    // MARK: - Initialization

    init(
        baseURL: URL = URL(string: "https://newsapi.org/v2")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - Public API

    /// 📚 GENERIC FUNCTION
    /// - T: Decodable means any type that conforms to Decodable
    /// - Allows type-safe decoding of different response types
    /// - Avoids code duplication
    ///
    /// ✅ GENERICS BENEFITS:
    /// - Type safety at compile time
    /// - Code reuse
    /// - No runtime type casting
    ///
    /// Example usage:
    /// ```
    /// let articles: ArticlesResponse = try await fetch(endpoint: .articles)
    /// let user: UserResponse = try await fetch(endpoint: .user)
    /// ```
    func fetch<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        // Build request
        let request = try buildRequest(for: endpoint)

        print("🌐 [Network] Fetching: \(request.url?.absoluteString ?? "")")

        do {
            // 📌 ASYNC/AWAIT URLSession
            // New API in iOS 15+: data(for:delegate:)
            // Returns (Data, URLResponse) tuple
            let (data, response) = try await session.data(for: request)

            // Validate HTTP response
            try validateResponse(response)

            // 📌 GENERIC DECODING
            // T is inferred from the return type at call site
            let decoded = try decodeJSON(T.self, from: data)

            print("✅ [Network] Successfully decoded \(T.self)")
            return decoded

        } catch let urlError as URLError {
            // 📌 ERROR TRANSFORMATION
            // Convert URLError to our domain-specific NetworkError
            throw NetworkError.from(urlError: urlError)

        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError, data: nil)

        } catch let networkError as NetworkError {
            // Already our error type
            throw networkError

        } catch {
            // Unknown error
            throw NetworkError.unknown
        }
    }

    /// 📚 ASYNC UPLOAD (Multipart form data)
    /// Example: Uploading images
    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        data: Data,
        mimeType: String
    ) async throws -> T {
        var request = try buildRequest(for: endpoint)
        request.httpMethod = "POST"
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, response) = try await session.data(for: request)
        try validateResponse(response)

        return try decodeJSON(T.self, from: responseData)
    }

    // MARK: - Private Helpers

    /// Builds URLRequest from endpoint configuration
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        // Construct full URL
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL(endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // 📌 URL COMPONENTS (for query parameters)
        if let parameters = endpoint.parameters, !parameters.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            request.url = components?.url
        }

        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOS-LearningApp/1.0", forHTTPHeaderField: "User-Agent")

        // Timeout
        request.timeoutInterval = 30

        return request
    }

    /// Validates HTTP response status code
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        // 📌 HTTP STATUS CODES
        // 2xx = Success
        // 3xx = Redirection
        // 4xx = Client errors
        // 5xx = Server errors

        if let error = NetworkError.from(httpResponse: httpResponse) {
            throw error
        }
    }

    /// 📚 GENERIC JSON DECODING
    /// - Uses JSONDecoder
    /// - Can customize decoding strategy
    /// - Type-safe with generics
    private func decodeJSON<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()

        // 📌 CUSTOM DECODING STRATEGIES
        // Convert snake_case JSON keys to camelCase Swift properties
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Handle different date formats
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 format first
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            // Try custom format
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = customFormatter.date(from: dateString) {
                return date
            }

            // Fallback to current date
            return Date()
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Log the actual data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("❌ [Network] Failed to decode JSON: \(jsonString)")
            }
            throw error
        }
    }
}

// MARK: - API Endpoint Configuration

/// 📚 ENDPOINT CONFIGURATION
/// Encapsulates all information needed to make a request
///
/// ✅ @UNCHECKED SENDABLE:
/// - Uses @unchecked because [String: Any] is not Sendable
/// - Safe in this case because:
///   1. All properties are immutable (let)
///   2. Created once and never modified
///   3. Dictionary values are basic types (String, Int, Bool)
///
/// 💡 PRODUCTION TIP:
/// For real apps, use Codable parameters instead:
/// struct APIEndpoint<Parameters: Codable & Sendable> { ... }
struct APIEndpoint: @unchecked Sendable {
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?

    init(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
    }
}

/// HTTP Methods
enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoints (Static Factory)

/// 📚 FACTORY PATTERN
/// Static methods for creating common endpoints
/// Ensures consistency and reduces errors
extension APIEndpoint {

    /// Get articles endpoint
    static func articles(
        category: Article.Category? = nil,
        page: Int = 1
    ) -> APIEndpoint {
        var params: [String: Any] = [
            "page": page,
            "apiKey": "demo_key" // In production: use secure storage
        ]

        if let category = category {
            params["category"] = category.rawValue
        }

        return APIEndpoint(
            path: "/top-headlines",
            method: .get,
            parameters: params
        )
    }

    /// Search articles endpoint
    static func search(query: String, page: Int = 1) -> APIEndpoint {
        APIEndpoint(
            path: "/everything",
            method: .get,
            parameters: [
                "q": query,
                "page": page,
                "apiKey": "demo_key"
            ]
        )
    }

    /// Get article by ID
    static func article(id: UUID) -> APIEndpoint {
        APIEndpoint(
            path: "/articles/\(id.uuidString)",
            method: .get
        )
    }
}

// MARK: - Interview Questions & Answers

/// 📚 COMMON INTERVIEW QUESTIONS:
///
/// Q: "How do you handle authentication tokens?"
/// A: Store in Keychain, inject via headers:
/// ```swift
/// private let tokenManager: TokenManager
///
/// var request = URLRequest(...)
/// request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
/// ```
///
/// Q: "How do you implement request retry logic?"
/// A: Use Task with retry count:
/// ```swift
/// func fetchWithRetry<T>(..., retries: Int = 3) async throws -> T {
///     for attempt in 0..<retries {
///         do {
///             return try await fetch(...)
///         } catch {
///             if attempt == retries - 1 { throw error }
///             try await Task.sleep(nanoseconds: 1_000_000_000)
///         }
///     }
/// }
/// ```
///
/// Q: "How do you cancel network requests?"
/// A: Use Task cancellation:
/// ```swift
/// let task = Task {
///     try await networkService.fetch(...)
/// }
/// task.cancel() // Cancels the request
/// ```
///
/// Q: "Generic vs non-generic networking?"
/// A: - Generic: Type-safe, reusable, compile-time checks
///    - Non-generic: More flexible, dynamic typing
///    - Use generics when you know the response type
///
/// Q: "Why use Actor for NetworkService?"
/// A: - Protects shared state (cache, configuration)
///    - Thread-safe by default
///    - Prevents data races in concurrent requests
///    - Integrates naturally with async/await
