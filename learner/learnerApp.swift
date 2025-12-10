//
//  learnerApp.swift
//  learner
//
//  App Entry Point
//
//  📚 LEARNING TOPICS:
//  • @main - App entry point
//  • App Protocol - SwiftUI application lifecycle
//  • WindowGroup - Scene management
//  • Dependency Injection - Setup and injection
//  • Environment - Passing dependencies to views
//

import SwiftUI
import SwiftData

/// 🎯 APP ENTRY POINT
///
/// ✅ @MAIN ATTRIBUTE:
/// - Marks this as the app's entry point
/// - Replaces UIApplicationDelegate in UIKit
/// - Calls static main() method automatically
///
/// ✅ APP PROTOCOL:
/// - Defines app structure and behavior
/// - body: some Scene - defines UI scenes
/// - Lifecycle methods available (onAppear, etc.)
///
/// ⚠️ INTERVIEW QUESTION:
/// "SwiftUI App lifecycle vs UIKit AppDelegate?"
/// - SwiftUI: Declarative, @main struct, Scene-based
/// - UIKit: AppDelegate class, imperative lifecycle
/// - Can use both with AppDelegate adapter for UIKit integration
///
@main
struct learnerApp: App {

    // MARK: - Properties

    /// 📌 DEPENDENCY INJECTION CONTAINER
    /// Centralized dependency management
    /// All dependencies created and configured here
    let container = DIContainer.shared

    // MARK: - Scene

    /// 📚 WINDOWGROUP
    ///
    /// ✅ WHAT IS A SCENE?
    /// - Represents a part of the app's UI
    /// - WindowGroup: Standard window on iOS
    /// - DocumentGroup: Document-based apps
    /// - Settings: Settings scene (macOS)
    ///
    /// ✅ MULTIPLE WINDOWS:
    /// - iPadOS supports multiple windows
    /// - Each WindowGroup can have multiple instances
    /// - State preservation automatic
    var body: some Scene {
        WindowGroup {
            /// 📚 ROOT VIEW
            /// Entry point of the view hierarchy
            ContentView()
                /// 📌 SWIFTDATA CONTAINER
                /// Inject ModelContainer for SwiftData
                /// Makes @Query work in all child views
                .modelContainer(container.modelContainer)

                /// 📚 APPEARANCE CUSTOMIZATION
                /// Can customize app-wide appearance here
                .onAppear {
                    setupAppearance()
                }
        }
    }

    // MARK: - Setup

    /// Configure app-wide appearance
    private func setupAppearance() {
        /// 📚 UIKIT APPEARANCE API
        /// Still needed for some customizations
        /// SwiftUI doesn't expose everything yet

        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        print("🎨 [App] Appearance configured")
    }
}

// MARK: - Interview Questions

/// 📚 APP LIFECYCLE INTERVIEW QUESTIONS:
///
/// Q: "SwiftUI app lifecycle methods?"
/// A: - .onAppear: Scene/View appears
///    - .onDisappear: Scene/View disappears
///    - .task: Async work with automatic cancellation
///    - .onChange: React to value changes
///    - ScenePhase: .active, .inactive, .background
///
/// Example:
/// ```swift
/// @Environment(\.scenePhase) var scenePhase
///
/// .onChange(of: scenePhase) { oldPhase, newPhase in
///     switch newPhase {
///     case .active: print("App active")
///     case .inactive: print("App inactive")
///     case .background: print("App in background")
///     }
/// }
/// ```
///
/// Q: "How to integrate UIKit AppDelegate?"
/// A: Use @UIApplicationDelegateAdaptor:
/// ```swift
/// @main
/// struct MyApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
/// }
///
/// class AppDelegate: NSObject, UIApplicationDelegate {
///     func application(...) -> Bool { true }
/// }
/// ```
///
/// Q: "Multiple windows support?"
/// A: - WindowGroup automatically supports multiple windows
///    - Use .handlesExternalEvents for custom window identifiers
///    - State restoration automatic
///    - Each window has independent state
///
/// Q: "App initialization order?"
/// A: 1. @main struct created
///    2. Properties initialized (DI container)
///    3. body computed (Scene created)
///    4. Root view created
///    5. .onAppear called
///    6. Child views rendered
