//
//  ContentView.swift
//  learner
//
//  Root Content View - Tab Navigation
//
//  📚 LEARNING TOPICS:
//  • TabView - Tab-based navigation
//  • @Environment - Accessing injected dependencies
//  • View Composition - Building complex UIs from simple parts
//

import SwiftUI
import SwiftData

/// 🎯 ROOT CONTENT VIEW
///
/// ✅ RESPONSIBILITIES:
/// - Main navigation structure
/// - Route to different sections
/// - Manage global UI state
///
/// ✅ COMMON NAVIGATION PATTERNS:
/// - TabView (used here) - Bottom tabs
/// - NavigationStack - Hierarchical navigation
/// - NavigationSplitView - Multi-column (iPad)
///
struct ContentView: View {

    // MARK: - Environment

    /// 📌 SWIFTDATA CONTEXT
    /// For database operations
    /// Injected via .modelContainer() modifier
    @Environment(\.modelContext) private var modelContext

    /// 📚 @QUERY - SwiftData Querying
    ///
    /// ✅ WHAT IS @QUERY?
    /// - SwiftData's property wrapper for fetching
    /// - Automatically updates when data changes
    /// - Supports predicates and sorting
    /// - Similar to @FetchRequest in Core Data
    ///
    /// ✅ USAGE EXAMPLES:
    /// ```swift
    /// // All articles
    /// @Query var articles: [ArticleEntity]
    ///
    /// // With predicate
    /// @Query(filter: #Predicate<ArticleEntity> { $0.isFavorite })
    /// var favorites: [ArticleEntity]
    ///
    /// // With sort
    /// @Query(sort: \ArticleEntity.publishedDate, order: .reverse)
    /// var articles: [ArticleEntity]
    /// ```
    @Query(
        filter: #Predicate<ArticleEntity> { $0.isFavorite == true },
        sort: \ArticleEntity.favoritedDate,
        order: .reverse
    )
    private var favoriteArticles: [ArticleEntity]

    /// 📌 TAB SELECTION
    /// Tracks which tab is currently selected
    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        /// 📚 TABVIEW
        ///
        /// ✅ TAB NAVIGATION:
        /// - iOS standard bottom tabs
        /// - Each tab is a separate navigation stack
        /// - Preserves state when switching tabs
        ///
        /// ✅ CUSTOMIZATION:
        /// - .tabItem: Icon and label
        /// - .badge: Notification count
        /// - .tag: Identifies tab for selection
        TabView(selection: $selectedTab) {

            // Tab 1: Home (Article Feed)
            HomeView(
                viewModel: HomeViewModel(
                    fetchArticlesUseCase: DIContainer.shared.makeFetchArticlesUseCase()
                )
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Tab 2: Favorites
            FavoritesView()
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .badge(favoriteArticles.count)
            .tag(1)

            // Tab 3: Profile/Settings
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        /// 📚 ACCENT COLOR
        /// Sets the tint color for selected tab icons
        .tint(.blue)
    }
}

// MARK: - Favorites View (Placeholder)

/// 📚 FAVORITES VIEW
/// Demonstrates SwiftData @Query usage
struct FavoritesView: View {

    /// 📌 @QUERY WITH PREDICATE
    /// Automatically fetches and updates favorite articles
    @Query(
        filter: #Predicate<ArticleEntity> { $0.isFavorite == true },
        sort: \ArticleEntity.favoritedDate,
        order: .reverse
    )
    private var favorites: [ArticleEntity]

    var body: some View {
        NavigationStack {
            if favorites.isEmpty {
                emptyState
            } else {
                List(favorites) { article in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)

                        Text(article.articleDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        HStack {
                            Label(article.category, systemImage: "tag")
                                .font(.caption)

                            Spacer()

                            if let date = article.favoritedDate {
                                Text(date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Save articles to read later")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Settings View (Placeholder)

/// 📚 SETTINGS VIEW
/// Demonstrates @AppStorage for UserDefaults
struct SettingsView: View {

    /// 📌 @APPSTORAGE PROPERTY WRAPPER
    ///
    /// ✅ WHAT IS @APPSTORAGE?
    /// - Built-in SwiftUI property wrapper for UserDefaults
    /// - Automatically saves/loads values
    /// - Creates Binding automatically
    /// - Triggers view updates on changes
    ///
    /// ✅ SIMILAR TO OUR CUSTOM @USERDEFAULT:
    /// We created a custom @UserDefault wrapper (see UserDefault.swift)
    /// But @AppStorage is the built-in SwiftUI version
    ///
    /// 💡 FOR LEARNING:
    /// - Study our custom UserDefault.swift to understand how it works
    /// - Use @AppStorage in production SwiftUI code
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                /// 📚 FORM
                /// Grouped settings UI
                /// Adapts to platform (iOS/macOS)

                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)

                    /// 📌 BINDING
                    /// $isDarkMode creates a Binding<Bool>
                    /// Two-way connection: view ↔ source of truth
                    /// Changes automatically saved to UserDefaults
                }

                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "100")
                }

                Section("Learning Resources") {
                    Link("Swift Documentation", destination: URL(string: "https://swift.org/documentation")!)
                    Link("SwiftUI Tutorials", destination: URL(string: "https://developer.apple.com/tutorials/swiftui")!)
                    Link("WWDC Videos", destination: URL(string: "https://developer.apple.com/videos")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview

#Preview("Content View") {
    ContentView()
        .modelContainer(DIContainer.shared.modelContainer)
}

#Preview("Favorites View") {
    FavoritesView()
        .modelContainer(DIContainer.shared.modelContainer)
}

#Preview("Settings View") {
    SettingsView()
}

// MARK: - Interview Questions

/// 📚 NAVIGATION INTERVIEW QUESTIONS:
///
/// Q: "TabView vs NavigationStack?"
/// A: - TabView: Parallel sections, bottom tabs, independent navigation
///    - NavigationStack: Hierarchical flow, drill-down pattern
///    - Can combine: Each tab has its own NavigationStack
///
/// Q: "How to handle deep linking?"
/// A: - Use NavigationPath for programmatic navigation
///    - Handle URL schemes in .onOpenURL
///    - Parse URL and navigate to specific view
/// ```swift
/// @State private var path = NavigationPath()
///
/// NavigationStack(path: $path) {
///     // Views
/// }
/// .onOpenURL { url in
///     // Parse URL and update path
/// }
/// ```
///
/// Q: "State preservation in tabs?"
/// A: - TabView automatically preserves state
///    - Each tab maintains its own navigation stack
///    - Use .tag() to identify tabs
///    - Bind to @State for programmatic control
///
/// Q: "@Query vs manual fetch?"
/// A: - @Query: Automatic updates, SwiftUI integration, declarative
///    - Manual: More control, async operations, complex queries
///    - Use @Query in views for reactive UI
///    - Use manual fetch in ViewModels/UseCases for business logic
