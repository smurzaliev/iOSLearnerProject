//
//  View+Extensions.swift
//  learner
//
//  SwiftUI View Extensions
//
//  📚 LEARNING TOPICS:
//  • Extensions - Adding functionality to existing types
//  • ViewModifiers - Reusable view modifications
//  • Method Chaining - Fluent API design
//  • Conditional Modifiers - Apply based on conditions
//

import SwiftUI

/// 🎯 EXTENSIONS
///
/// ✅ WHAT ARE EXTENSIONS?
/// - Add new functionality to existing types
/// - Can extend classes, structs, enums, protocols
/// - Cannot add stored properties (only computed)
/// - Can add methods, initializers, subscripts
///
/// ✅ BENEFITS:
/// - Organize code by functionality
/// - Add features to types you don't own (UIView, String, etc.)
/// - Protocol conformance in separate files
/// - Namespace related functionality
///
/// ⚠️ INTERVIEW QUESTION:
/// "Extensions vs Inheritance?"
/// - Extensions: Add to ANY type, no inheritance needed
/// - Inheritance: Create subclass, limited to classes
/// - Extensions preferred for horizontal features
/// - Inheritance for vertical specialization
///

extension View {

    // MARK: - Conditional Modifiers

    /// 📚 CONDITIONAL MODIFIER
    ///
    /// ✅ PATTERN: Apply modifier based on condition
    /// Instead of: if condition { view.modifier() } else { view }
    /// Use: view.if(condition) { $0.modifier() }
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .if(isHighlighted) { view in
    ///         view.foregroundColor(.red)
    ///     }
    /// ```
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply modifier if optional value exists
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .ifLet(user) { view, user in
    ///         view.navigationTitle(user.name)
    ///     }
    /// ```
    @ViewBuilder
    func ifLet<T, Content: View>(
        _ value: T?,
        transform: (Self, T) -> Content
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    // MARK: - Loading Indicators

    /// 📚 CUSTOM MODIFIER
    ///
    /// ✅ OVERLAY PATTERN:
    /// Add loading indicator on top of view
    ///
    /// Usage:
    /// ```swift
    /// List { ... }
    ///     .loading(isLoading)
    /// ```
    func loading(_ isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }

    // MARK: - Error Handling

    /// Show error alert
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .errorAlert(error: $errorMessage)
    /// ```
    func errorAlert(error: Binding<String?>) -> some View {
        alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let errorMessage = error.wrappedValue {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Styling

    /// 📚 CARD STYLE
    ///
    /// ✅ REUSABLE STYLING:
    /// Encapsulate common styling patterns
    ///
    /// Usage:
    /// ```swift
    /// VStack { ... }
    ///     .cardStyle()
    /// ```
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: 2
            )
    }

    /// Border with rounded corners
    func borderedStyle(
        color: Color = .gray,
        width: CGFloat = 1,
        cornerRadius: CGFloat = 8
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }

    // MARK: - Navigation

    /// 📚 NAVIGATION HELPER
    ///
    /// ✅ NAVIGATION DESTINATION:
    /// Simplified navigation to another view
    ///
    /// Usage:
    /// ```swift
    /// Text("Tap me")
    ///     .navigable(to: DetailView())
    /// ```
    func navigable<Destination: View>(
        to destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            self
        }
    }

    // MARK: - Debug Helpers

    /// 📚 DEBUG PRINT
    ///
    /// ✅ DEBUGGING VIEWS:
    /// Print when view is created/updated
    /// Helps understand SwiftUI lifecycle
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .debugPrint("Text view updated")
    /// ```
    func debugPrint(_ message: String) -> some View {
        print("🐛 [Debug] \(message)")
        return self
    }

    /// Print view frame size
    func debugFrame() -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    print("🐛 [Frame] \(geometry.size)")
                }
            }
        )
    }

    // MARK: - Accessibility

    /// 📚 ACCESSIBILITY HELPERS
    ///
    /// ✅ VOICEOVER SUPPORT:
    /// Simplified accessibility configuration
    ///
    /// Usage:
    /// ```swift
    /// Button("Delete") { }
    ///     .accessible(
    ///         label: "Delete item",
    ///         hint: "Removes the item from your list"
    ///     )
    /// ```
    func accessible(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .accessibilityAddTraits(traits)
    }

    // MARK: - Performance

    /// 📚 EQUATABLE VIEW
    ///
    /// ✅ PERFORMANCE OPTIMIZATION:
    /// Prevents unnecessary re-renders
    /// SwiftUI only updates if view data changes
    ///
    /// Usage:
    /// ```swift
    /// struct ExpensiveView: View, Equatable {
    ///     let data: String
    ///
    ///     static func == (lhs: Self, rhs: Self) -> Bool {
    ///         lhs.data == rhs.data
    ///     }
    /// }
    ///
    /// ExpensiveView(data: "test")
    ///     .equatable()  // Only updates if data changes
    /// ```
    func equatable() -> some View where Self: Equatable {
        EquatableView(content: self)
    }
}

// MARK: - Equatable View Wrapper

/// 📚 EQUATABLE VIEW
/// Wrapper that only updates when content changes
struct EquatableView<Content: View & Equatable>: View {
    let content: Content

    var body: some View {
        content
    }

    /// 📌 EQUATABLE CONFORMANCE
    /// SwiftUI uses this to determine if view needs updating
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content
    }
}

// MARK: - UIColor Extensions

/// 📚 COLOR EXTENSIONS
/// Convenient color creation
extension Color {

    /// 📌 HEX INITIALIZER
    ///
    /// Create Color from hex string
    /// Example: Color(hex: "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Predefined app colors
    static let appPrimary = Color(hex: "007AFF")
    static let appSecondary = Color(hex: "5856D6")
    static let appSuccess = Color(hex: "34C759")
    static let appWarning = Color(hex: "FF9500")
    static let appError = Color(hex: "FF3B30")
}

// MARK: - String Extensions

/// 📚 STRING EXTENSIONS
/// Useful string utilities
extension String {

    /// Check if string is valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Truncate string to length
    func truncated(to length: Int, trailing: String = "...") -> String {
        guard self.count > length else { return self }
        return prefix(length) + trailing
    }
}

// MARK: - Interview Questions

/// 📚 EXTENSIONS INTERVIEW QUESTIONS:
///
/// Q: "What can you add with extensions?"
/// A: - Computed properties (not stored)
///    - Methods (instance and type)
///    - Initializers (convenience only for classes)
///    - Subscripts
///    - Nested types
///    - Protocol conformance
///
/// Q: "Extensions vs Inheritance?"
/// A: Extensions:
///    - Add to any type (even structs, enums)
///    - No need to subclass
///    - Can extend types you don't own
///    - Organize code by feature
///
///    Inheritance:
///    - Create new type with specialization
///    - Override methods
///    - Add stored properties
///    - Only for classes
///
/// Q: "Can you override extension methods?"
/// A: - Methods in extensions can't be overridden
///    - Unless the type is a class and method is marked @objc dynamic
///    - Generally, extensions are for adding, not overriding
///
/// Q: "Extension access control?"
/// A: - Can be public, internal, fileprivate, private
///    - Members inherit extension's access level
///    - Can't make more accessible than original type
///
/// Q: "Protocol extensions vs regular extensions?"
/// A: Protocol extensions:
///    - Add default implementations to protocol
///    - Apply to all conforming types
///    - Can use 'Self' to refer to conforming type
///
///    Regular extensions:
///    - Add to specific type
///    - Can access private members of that type
///
/// Q: "Performance implications?"
/// A: - Extensions compiled to regular methods
///    - No runtime overhead
///    - Static dispatch (unless protocol extensions with @objc)
///    - Same performance as methods in original type
