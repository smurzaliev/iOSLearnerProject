//
//  HomeView.swift
//  learner
//
//  SwiftUI View - Modern Declarative UI
//
//  📚 LEARNING TOPICS:
//  • SwiftUI - Declarative UI framework
//  • State Management - @StateObject, @State, @Environment
//  • List & LazyVStack - Performance optimization
//  • Async/Await in SwiftUI - Task modifier
//  • Pull to Refresh - refreshable modifier
//  • Accessibility - VoiceOver support
//  • ViewModifiers - Reusable view modifications
//  • Navigation - NavigationStack (iOS 16+)
//

import SwiftUI

/// 🎯 SWIFTUI VIEW
///
/// ✅ DECLARATIVE vs IMPERATIVE:
/// - Declarative: Describe WHAT you want (SwiftUI)
/// - Imperative: Describe HOW to do it (UIKit)
///
/// ✅ VIEW PROTOCOL:
/// - Lightweight struct (value type)
/// - No lifecycle methods (no viewDidLoad)
/// - Immutable by default
/// - Efficient diffing and rendering
///
/// ⚠️ INTERVIEW QUESTION:
/// "SwiftUI vs UIKit?"
/// - SwiftUI: Declarative, less code, cross-platform, future
/// - UIKit: Imperative, more control, mature, backwards compatible
/// - Use SwiftUI for new projects, UIKit for legacy or fine control
///

struct HomeView: View {

    // MARK: - Properties

    /// 📚 @STATEOBJECT
    ///
    /// ✅ WHAT IT DOES:
    /// - Creates and owns the ViewModel
    /// - Persists across view updates
    /// - Only initialized once
    ///
    /// ✅ WHEN TO USE:
    /// - View creates the observable object
    /// - Source of truth for this view
    ///
    /// 💡 ALTERNATIVE: @ObservedObject
    /// Use when ViewModel is passed from parent
    @StateObject private var viewModel: HomeViewModel

    /// 📚 @STATE
    ///
    /// ✅ WHAT IT DOES:
    /// - Source of truth for view-local state
    /// - SwiftUI manages storage
    /// - Triggers view update when changed
    ///
    /// ✅ VALUE vs REFERENCE:
    /// - @State for value types (Int, String, Bool, struct)
    /// - @StateObject for reference types (class)
    @State private var showCategoryPicker = false
    @State private var selectedArticle: Article?

    // MARK: - Initialization

    /// 📌 CUSTOM INITIALIZER
    /// Required to inject dependencies into @StateObject
    ///
    /// ✅ NOTE:
    /// - Don't use _ prefix for @StateObject in init
    /// - Use wrappedValue parameter
    init(viewModel: HomeViewModel) {
        // Create ViewModel with injected dependencies
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    /// 📚 SOME VIEW
    ///
    /// ✅ OPAQUE RETURN TYPE:
    /// - 'some View' means "returns a specific View type"
    /// - Compiler knows exact type, we don't need to specify
    /// - Enables better performance and type inference
    ///
    /// ✅ WHY NOT EXPLICIT TYPE?
    /// - SwiftUI views have complex generic types
    /// - Example: ModifiedContent<VStack<TupleView<(Text, Button)>>, Padding>
    /// - 'some View' is much cleaner
    ///
    var body: some View {
        NavigationStack {
            ZStack {
                // 📌 ZSTACK
                // Stacks views on top of each other (Z-axis)
                // Common for overlaying loading indicators

                // Main content
                contentView

                // Loading overlay
                if viewModel.isLoading && viewModel.articles.isEmpty {
                    LoadingView()
                        /// 📚 TRANSITION
                        /// Animates view appearance/disappearance
                        .transition(.opacity)
                }
            }
            .navigationTitle("Tech News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showCategoryPicker) {
                categoryPickerSheet
            }
        }
        /// 📚 TASK MODIFIER
        ///
        /// ✅ WHAT IT DOES:
        /// - Runs async work when view appears
        /// - Automatically cancels when view disappears
        /// - Replacement for onAppear with async/await
        ///
        /// ✅ LIFECYCLE:
        /// - Called when view appears
        /// - Task cancelled when view disappears
        /// - Perfect for loading data
        .task {
            // Load initial data
            if viewModel.articles.isEmpty {
                await viewModel.loadArticles()
            }
        }
    }

    // MARK: - View Builders

    /// 📚 @VIEWBUILDER
    ///
    /// ✅ RESULT BUILDER:
    /// - Allows multiple views in body
    /// - Implicit @ViewBuilder on 'body' property
    /// - Can use on custom computed properties
    ///
    /// ✅ ENABLES:
    /// - Multiple views without container
    /// - if-else statements
    /// - for loops (limited)
    ///
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            // Already handled by ZStack overlay
            Color.clear

        case .loaded:
            articleList

        case .empty:
            emptyStateView

        case .error(let message):
            errorView(message: message)
        }
    }

    private var articleList: some View {
        /// 📚 LIST vs LAZYVSTACK
        ///
        /// ✅ LIST:
        /// - UITableView wrapper
        /// - Built-in styles and separators
        /// - Pull-to-refresh, swipe actions
        /// - Better for standard lists
        ///
        /// ✅ LAZYVSTACK:
        /// - Custom layouts
        /// - More control over appearance
        /// - Lazy loading (creates views on-demand)
        /// - Better for custom designs
        ///
        List {
            /// 📌 FOREACH
            /// Loops over identifiable collection
            /// Requires Identifiable or id parameter
            ForEach(viewModel.articles) { article in
                ArticleRow(article: article)
                    .onTapGesture {
                        selectedArticle = article
                    }
                    /// 📚 ACCESSIBILITY
                    ///
                    /// ✅ WHY ACCESSIBILITY MATTERS:
                    /// - 15% of users need assistive tech
                    /// - Legal requirement in many countries
                    /// - Better UX for everyone
                    ///
                    /// ✅ VOICEOVER SUPPORT:
                    /// - Reads UI aloud for visually impaired
                    /// - accessibilityLabel: What is it
                    /// - accessibilityHint: What happens when tapped
                    /// - accessibilityValue: Current value/state
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(article.category.rawValue) article: \(article.title)")
                    .accessibilityHint("Tap to read full article")

                    /// 📚 LIST OPTIMIZATION
                    ///
                    /// ✅ ONAPPEAR:
                    /// - Called when row appears
                    /// - Use for pagination (load more)
                    /// - Be careful: called multiple times
                    .onAppear {
                        // Load more when near bottom
                        if article == viewModel.articles.last {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
            }
            /// 📌 SWIPE ACTIONS
            .onDelete { indexSet in
                // Handle deletion
                // In real app, remove from favorites
            }

            // Loading indicator at bottom
            if viewModel.isLoading && !viewModel.articles.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        /// 📚 REFRESHABLE MODIFIER
        ///
        /// ✅ PULL-TO-REFRESH:
        /// - Native iOS gesture
        /// - Async/await integration
        /// - Automatic loading indicator
        .refreshable {
            await viewModel.refresh()
        }
        .searchable(
            text: $viewModel.searchQuery,
            prompt: "Search articles..."
        )
    }

    private var emptyStateView: some View {
        /// 📚 VSTACK, HSTACK, ZSTACK
        ///
        /// ✅ STACK TYPES:
        /// - VStack: Vertical (Y-axis)
        /// - HStack: Horizontal (X-axis)
        /// - ZStack: Overlapping (Z-axis)
        ///
        /// ✅ SPACING & ALIGNMENT:
        /// - spacing: Distance between children
        /// - alignment: How children align
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Articles")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Pull to refresh or change category")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Refresh") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        /// 📚 ACCESSIBILITY - Dynamic Type
        ///
        /// ✅ DYNAMIC TYPE:
        /// - User-controlled text size
        /// - Use .font() instead of fixed sizes
        /// - Test with large text sizes
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text("Error")
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadArticles()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        /// 📚 TOOLBAR
        ///
        /// ✅ PLACEMENT:
        /// - .navigationBarTrailing (right side)
        /// - .navigationBarLeading (left side)
        /// - .bottomBar (bottom)
        /// - .principal (center)

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showCategoryPicker.toggle()
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
            .accessibilityLabel("Filter by category")
        }
    }

    private var categoryPickerSheet: some View {
        /// 📚 SHEET (Modal Presentation)
        ///
        /// ✅ PRESENTATION STYLES:
        /// - .sheet: Modal from bottom
        /// - .fullScreenCover: Full screen
        /// - .popover: iPad popover
        NavigationStack {
            List {
                Section("Categories") {
                    Button("All Articles") {
                        viewModel.filterByCategory(nil)
                        showCategoryPicker = false
                    }

                    ForEach(Article.Category.allCases, id: \.self) { category in
                        Button {
                            viewModel.filterByCategory(category)
                            showCategoryPicker = false
                        } label: {
                            HStack {
                                Label(category.rawValue, systemImage: category.icon)
                                Spacer()
                                if viewModel.selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showCategoryPicker = false
                    }
                }
            }
        }
        /// 📚 PRESENTATION DETENTS
        ///
        /// ✅ iOS 16+ FEATURE:
        /// - Control sheet height
        /// - .medium: Half screen
        /// - .large: Full screen
        /// - Custom: .height(300)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Article Row Component

/// 📚 EXTRACT SUBVIEWS
///
/// ✅ BENEFITS:
/// - Better organization
/// - Reusability
/// - Performance (smaller view trees)
/// - Easier testing
///
/// ✅ WHEN TO EXTRACT:
/// - Logic is complex
/// - Used multiple times
/// - Body getting too long
///
struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Article image
            if let imageURL = article.imageURL {
                /// 📚 ASYNCIMAGE
                ///
                /// ✅ MODERN IMAGE LOADING:
                /// - Async loading from URL
                /// - Built-in caching
                /// - Placeholder support
                /// - Error handling
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)

                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)

                    case .failure:
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Article info
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(article.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    Label(article.category.rawValue, systemImage: article.category.icon)
                        .font(.caption)
                        .foregroundStyle(.blue)

                    Spacer()

                    Text("\(article.readingTime) min read")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Loading View Component

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            /// 📚 PROGRESSVIEW
            ///
            /// ✅ STYLES:
            /// - .circular (default)
            /// - .linear
            /// - Custom with ProgressViewStyle
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)

            Text("Loading articles...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

/// 📚 SWIFTUI PREVIEWS
///
/// ✅ BENEFITS:
/// - Live preview in Xcode
/// - Fast iteration
/// - Test different states
/// - Multiple device previews
///
/// ✅ PREVIEW MACRO (iOS 17+):
/// - Cleaner syntax
/// - Better performance
///
#Preview("Home View - Loaded") {
    let container = DIContainer.shared
    let viewModel = HomeViewModel(
        fetchArticlesUseCase: container.makeFetchArticlesUseCase()
    )
    return HomeView(viewModel: viewModel)
}

#Preview("Home View - Loading") {
    let container = DIContainer.shared
    let viewModel = HomeViewModel(
        fetchArticlesUseCase: container.makeFetchArticlesUseCase()
    )
    return HomeView(viewModel: viewModel)
}

// MARK: - Interview Questions

/// 📚 SWIFTUI INTERVIEW QUESTIONS:
///
/// Q: "How does SwiftUI update views?"
/// A: - View is a struct (value type)
///    - When @State/@Published changes, SwiftUI diffs the view tree
///    - Only changed views are re-rendered
///    - Very efficient with structural identity
///
/// Q: "@State vs @StateObject vs @ObservedObject?"
/// A: - @State: Value types, view-local, owned by view
///    - @StateObject: Reference types, owned by view, persists across updates
///    - @ObservedObject: Reference types, NOT owned, passed from parent
///
/// Q: "When to use ForEach vs forEach?"
/// A: - ForEach: SwiftUI view builder, creates views
///    - forEach: Collection method, functional iteration
///    - Use ForEach in view body
///
/// Q: "How to optimize List performance?"
/// A: 1. Use LazyVStack for custom layouts
///    2. Limit onAppear usage
///    3. Use .id() sparingly
///    4. Avoid heavy computations in body
///    5. Extract complex rows to separate views
///
/// Q: "Navigation in SwiftUI?"
/// A: - NavigationStack (iOS 16+): Modern, path-based
///    - NavigationView (legacy): Deprecated
///    - .sheet: Modal presentation
///    - .fullScreenCover: Full screen modal
///
/// Q: "View lifecycle in SwiftUI?"
/// A: - .onAppear: View appeared
///    - .onDisappear: View disappeared
///    - .task: Async work, auto-cancels
///    - No viewDidLoad (use .task instead)
///
/// Q: "How to prevent view recreation?"
/// A: - Use @StateObject (not @ObservedObject) for owned objects
///    - Use .equatable() modifier
///    - Implement Equatable on custom views
///    - Use stable IDs for ForEach
