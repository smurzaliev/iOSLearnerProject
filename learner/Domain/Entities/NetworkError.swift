//
//  NetworkError.swift
//  learner
//
//  Custom Error Types for Domain Layer
//
//  📚 LEARNING TOPICS:
//  • Error Handling in Swift - Error protocol
//  • Custom Error Types - Domain-specific errors
//  • LocalizedError - User-friendly error messages
//  • Enum with Associated Values - Attach context to errors
//  • Error Propagation - Throwing and catching errors
//

import Foundation

/// 🎯 CUSTOM ERROR TYPE
///
/// ✅ WHY CUSTOM ERRORS?
/// - Type-safe error handling
/// - Attach contextual information (associated values)
/// - Provide user-friendly messages
/// - Better than using NSError or generic Error
///
/// ✅ ERROR HANDLING STRATEGIES:
/// 1. Result<Success, Failure> - For async completion
/// 2. throws/try/catch - For synchronous code
/// 3. Optional - For non-critical failures
///
/// ⚠️ INTERVIEW QUESTION:
/// "When to use Result vs throws vs Optional?"
/// - Result: Async callbacks, functional programming, explicit handling
/// - throws: Synchronous operations, clear error flow
/// - Optional: Missing values, non-exceptional cases
///
enum NetworkError: Error {

    // MARK: - Cases with Associated Values

    /// 📌 ASSOCIATED VALUES
    /// Enums can carry additional data with each case
    /// This is a powerful Swift feature for type-safe data

    /// Server returned an error status code
    /// Associated value: HTTP status code
    case serverError(statusCode: Int)

    /// Network request failed (no internet, timeout, etc.)
    /// Associated value: underlying error for debugging
    case requestFailed(Error)

    /// Failed to decode JSON response
    /// Associated values: decoding error and raw data for debugging
    case decodingError(Error, Data?)

    /// Invalid URL construction
    /// Associated value: the attempted URL string
    case invalidURL(String)

    /// No internet connection
    case noConnection

    /// Request was cancelled (user or timeout)
    case cancelled

    /// Unknown/unexpected error
    case unknown

    // MARK: - Computed Properties

    /// 📚 COMPUTED PROPERTIES ON ENUMS
    /// Provides contextual information based on the case
    var isRetriable: Bool {
        switch self {
        case .serverError(let statusCode):
            // 5xx errors are typically retriable (server issues)
            // 4xx errors are not (client issues)
            return statusCode >= 500
        case .noConnection, .requestFailed:
            return true
        case .decodingError, .invalidURL, .cancelled, .unknown:
            return false
        }
    }

    /// Returns HTTP status code if available
    var statusCode: Int? {
        // 📌 PATTERN MATCHING
        // Extract associated values using if case let
        if case .serverError(let code) = self {
            return code
        }
        return nil
    }
}

// MARK: - LocalizedError Conformance

/// 📚 LOCALIZEDERROR PROTOCOL
/// Provides user-facing error descriptions
/// iOS uses these for alerts and error displays
///
/// ✅ PROPERTIES:
/// - errorDescription: What went wrong
/// - failureReason: Why it went wrong
/// - recoverySuggestion: How to fix it
/// - helpAnchor: Additional help (rarely used)
///
extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode):
            return "Server error occurred (Status: \(statusCode))"

        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"

        case .decodingError(let error, _):
            // 💡 TIP: In production, log the raw data for debugging
            // but don't show it to users (might contain sensitive info)
            return "Failed to process server response: \(error.localizedDescription)"

        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"

        case .noConnection:
            return "No internet connection available"

        case .cancelled:
            return "Request was cancelled"

        case .unknown:
            return "An unexpected error occurred"
        }
    }

    var failureReason: String? {
        switch self {
        case .serverError(let statusCode):
            if statusCode >= 500 {
                return "The server is experiencing issues"
            } else if statusCode == 404 {
                return "The requested resource was not found"
            } else if statusCode == 401 || statusCode == 403 {
                return "Authentication failed"
            } else {
                return "The request was rejected by the server"
            }

        case .requestFailed:
            return "Unable to connect to the server"

        case .decodingError:
            return "The server response format was unexpected"

        case .invalidURL:
            return "The URL format is incorrect"

        case .noConnection:
            return "Your device is not connected to the internet"

        case .cancelled:
            return "The operation was stopped"

        case .unknown:
            return "An unexpected issue occurred"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .serverError(let statusCode):
            if statusCode >= 500 {
                return "Please try again later"
            } else if statusCode == 401 || statusCode == 403 {
                return "Please log in again"
            } else {
                return "Please check your request and try again"
            }

        case .requestFailed, .noConnection:
            return "Please check your internet connection and try again"

        case .decodingError:
            return "Please update the app or contact support if the issue persists"

        case .invalidURL:
            return "Please contact support"

        case .cancelled:
            return "You can try the operation again"

        case .unknown:
            return "Please try again or contact support"
        }
    }
}

// MARK: - Custom Error Mapping

/// 📚 EXTENSION FOR ERROR CONVERSION
/// Demonstrates factory pattern for error creation
extension NetworkError {

    /// 🎯 FACTORY METHOD
    /// Creates appropriate NetworkError from URLError
    ///
    /// ✅ PATTERN: ADAPTER PATTERN
    /// Converts one error type to another (URLError → NetworkError)
    static func from(urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection

        case .cancelled:
            return .cancelled

        case .timedOut, .cannotConnectToHost, .cannotFindHost:
            return .requestFailed(urlError)

        default:
            return .requestFailed(urlError)
        }
    }

    /// Creates NetworkError from HTTP response
    static func from(httpResponse: HTTPURLResponse) -> NetworkError? {
        // 200-299 are success codes
        guard !(200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        return .serverError(statusCode: httpResponse.statusCode)
    }

    /// Creates NetworkError from decoding failure
    static func decodingFailed(_ error: Error, data: Data? = nil) -> NetworkError {
        .decodingError(error, data)
    }
}

// MARK: - Interview Tips

/// 📚 INTERVIEW QUESTIONS & ANSWERS:
///
/// Q: "What's the difference between Error and NSError?"
/// A: Error is a protocol (Swift-native, type-safe, can be enums with associated values).
///    NSError is a class (Objective-C bridging, uses error codes and domains).
///    Error is preferred in Swift for type safety.
///
/// Q: "When would you use throwing functions vs Result type?"
/// A: - throws: Synchronous operations, clear error propagation, traditional flow
///    - Result: Async callbacks, functional composition, storing errors for later
///    - async throws: Modern async operations (best of both worlds)
///
/// Q: "How do you handle errors in async/await?"
/// A: Use do-try-catch with async throws functions, or Result type with async functions
///
/// Example:
/// ```
/// func fetchData() async throws -> Data {
///     // throws propagates errors up
/// }
///
/// // Usage:
/// do {
///     let data = try await fetchData()
/// } catch let error as NetworkError {
///     // Handle our custom error
/// } catch {
///     // Handle other errors
/// }
/// ```
///
/// Q: "What is error propagation?"
/// A: Errors can be:
///    1. Caught and handled (do-catch)
///    2. Propagated up (re-throw with try in throwing function)
///    3. Converted to optional (try?)
///    4. Forced (try! - use sparingly, only when guaranteed safe)
