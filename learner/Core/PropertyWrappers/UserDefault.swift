//
//  UserDefault.swift
//  learner
//
//  Custom Property Wrapper for UserDefaults
//
//  📚 LEARNING TOPICS:
//  • Property Wrappers - Custom @attributes
//  • UserDefaults - Simple persistence
//  • Generics - Type-safe wrappers
//  • Projected Values - $ syntax
//  • Where Clauses - Generic constraints
//

import Foundation
import Combine

/// 🎯 PROPERTY WRAPPERS
///
/// ✅ WHAT ARE PROPERTY WRAPPERS?
/// - Introduced in Swift 5.1
/// - Reusable property behavior
/// - Syntax: @WrapperName above property
/// - SwiftUI uses them extensively (@State, @Binding, @Published)
///
/// ✅ BENEFITS:
/// - Eliminate boilerplate code
/// - Encapsulate common patterns
/// - Type-safe and reusable
/// - Declarative syntax
///
/// ⚠️ INTERVIEW QUESTION:
/// "How do property wrappers work?"
/// - Compiler transforms @Wrapped var x into a wrapped property
/// - Creates private _x storage
/// - Provides wrappedValue getter/setter
/// - Optional projectedValue ($x)
///

/// 📚 CUSTOM PROPERTY WRAPPER
///
/// Simplifies UserDefaults access
/// Instead of:
/// ```swift
/// UserDefaults.standard.set(value, forKey: "key")
/// let value = UserDefaults.standard.string(forKey: "key")
/// ```
///
/// Use:
/// ```swift
/// @UserDefault("key", defaultValue: "")
/// var setting: String
/// ```
@propertyWrapper
struct UserDefault<Value> {

    // MARK: - Properties

    /// Key for UserDefaults storage
    let key: String

    /// Default value if key doesn't exist
    let defaultValue: Value

    /// UserDefaults instance (allows testing with different suite)
    let storage: UserDefaults

    /// 📚 PROJECTED VALUE
    /// Accessed with $ prefix: $property
    /// Can be any type you want
    /// Common uses: Publisher, Binding, additional functionality
    var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    /// 📌 COMBINE INTEGRATION
    /// Publishes changes to the value
    /// Allows observing UserDefaults changes reactively
    private let subject: CurrentValueSubject<Value, Never>

    // MARK: - Initialization

    init(
        _ key: String,
        defaultValue: Value,
        storage: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage

        // Initialize subject with current value
        let initialValue = storage.object(forKey: key) as? Value ?? defaultValue
        self.subject = CurrentValueSubject(initialValue)
    }

    // MARK: - Property Wrapper Protocol

    /// 📌 WRAPPED VALUE
    /// This is the actual value accessed when using the property
    /// Must be named exactly "wrappedValue"
    var wrappedValue: Value {
        get {
            // 📚 TYPE CASTING
            // UserDefaults returns Any?, must cast to expected type
            // Nil coalescing (??) provides default if key missing or wrong type
            storage.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Store new value
            storage.set(newValue, forKey: key)

            // 📚 SYNCHRONIZE
            // Not needed in modern iOS (auto-syncs)
            // But can force immediate write
            // storage.synchronize()

            // Publish change to subscribers
            subject.send(newValue)

            print("💾 [UserDefault] Saved \(key) = \(newValue)")
        }
    }
}

// MARK: - Codable Support

/// 📚 GENERIC EXTENSION WITH CONSTRAINT
///
/// ✅ WHERE CLAUSE:
/// - Adds constraints to generic types
/// - This extension only applies when Value is Codable
/// - Allows storing complex types in UserDefaults
///
extension UserDefault where Value: Codable {

    /// Enhanced wrapper for Codable types
    /// Automatically encodes/decodes from JSON
    init(
        _ key: String,
        defaultValue: Value,
        storage: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage

        // Decode from stored data
        let initialValue: Value
        if let data = storage.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Value.self, from: data) {
            initialValue = decoded
        } else {
            initialValue = defaultValue
        }

        self.subject = CurrentValueSubject(initialValue)
    }

    var wrappedValue: Value {
        get {
            guard let data = storage.data(forKey: key),
                  let decoded = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }
            return decoded
        }
        set {
            // 📌 CODABLE ENCODING
            // Encode to JSON data
            if let encoded = try? JSONEncoder().encode(newValue) {
                storage.set(encoded, forKey: key)
                subject.send(newValue)
            }
        }
    }
}

// MARK: - Usage Examples

/// 📚 HOW TO USE:
///
/// 1️⃣ SIMPLE TYPES:
/// ```swift
/// class Settings {
///     @UserDefault("username", defaultValue: "Guest")
///     var username: String
///
///     @UserDefault("isDarkMode", defaultValue: false)
///     var isDarkMode: Bool
///
///     @UserDefault("fontSize", defaultValue: 16.0)
///     var fontSize: Double
/// }
///
/// let settings = Settings()
/// settings.username = "John" // Automatically saved
/// print(settings.username)   // Automatically loaded
/// ```
///
/// 2️⃣ CODABLE TYPES:
/// ```swift
/// struct UserPreferences: Codable {
///     var theme: String
///     var notifications: Bool
/// }
///
/// class Settings {
///     @UserDefault("preferences", defaultValue: UserPreferences(
///         theme: "light",
///         notifications: true
///     ))
///     var preferences: UserPreferences
/// }
/// ```
///
/// 3️⃣ OBSERVING CHANGES (Combine):
/// ```swift
/// class ViewModel {
///     @UserDefault("darkMode", defaultValue: false)
///     var isDarkMode: Bool
///
///     var cancellables = Set<AnyCancellable>()
///
///     func observeChanges() {
///         // $ accesses the projectedValue (Publisher)
///         $isDarkMode
///             .sink { newValue in
///                 print("Dark mode changed: \(newValue)")
///             }
///             .store(in: &cancellables)
///     }
/// }
/// ```

// MARK: - Interview Questions

/// 📚 PROPERTY WRAPPER INTERVIEW QUESTIONS:
///
/// Q: "How do you create a property wrapper?"
/// A: 1. Create a struct/class with @propertyWrapper
///    2. Implement wrappedValue property
///    3. Optional: Implement projectedValue
///    4. Use with @ syntax
///
/// Q: "What's projectedValue for?"
/// A: - Additional functionality beyond the wrapped value
///    - SwiftUI examples:
///      - @State projects a Binding
///      - @Published projects a Publisher
///    - Accessed with $ prefix
///
/// Q: "Common property wrappers in SwiftUI?"
/// A: @State - Local view state
///    @Binding - Two-way binding to state
///    @ObservedObject - External observable object
///    @StateObject - Owned observable object
///    @EnvironmentObject - Shared environment object
///    @Environment - System environment values
///    @Published - Publishes property changes
///
/// Q: "Can property wrappers be composed?"
/// A: Yes! Example:
/// ```swift
/// @Published @UserDefault("count", defaultValue: 0)
/// var count: Int
/// ```
/// The order matters - outer wrapper wraps inner
///
/// Q: "wrappedValue vs projectedValue?"
/// A: wrappedValue: The actual value (accessed directly)
///    projectedValue: Additional interface (accessed with $)
///
/// Example:
/// ```swift
/// @State var count = 0
/// count          // wrappedValue (Int)
/// $count         // projectedValue (Binding<Int>)
/// ```
///
/// Q: "How to debug property wrappers?"
/// A: - Use print in getter/setter
///    - Access backing storage with _propertyName
///    - Understand the transformation:
///
/// ```swift
/// @UserDefault("key", defaultValue: 0)
/// var value: Int
///
/// // Becomes:
/// private var _value = UserDefault("key", defaultValue: 0)
/// var value: Int {
///     get { _value.wrappedValue }
///     set { _value.wrappedValue = newValue }
/// }
/// var $value: AnyPublisher<Int, Never> {
///     _value.projectedValue
/// }
/// ```

// MARK: - Advanced: Thread-Safe Property Wrapper

/// 📚 BONUS: THREAD-SAFE WRAPPER
///
/// ⚠️ NOTE: Property wrappers with actors are complex
/// This is a simplified example for learning purposes
///
/// For production code, use actors directly instead of wrapping them
/// in property wrappers, or use @MainActor for UI-related state.
///
/// Example of proper actor usage:
/// ```swift
/// actor Counter {
///     private var value = 0
///
///     func increment() {
///         value += 1
///     }
///
///     func getValue() -> Int {
///         value
///     }
/// }
///
/// // Usage:
/// let counter = Counter()
/// await counter.increment()
/// let value = await counter.getValue()
/// ```
