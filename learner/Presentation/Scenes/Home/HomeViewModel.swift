//
//  HomeViewModel.swift
//  learner
//
//  ViewModel - MVVM Pattern
//
//  📚 LEARNING TOPICS:
//  • MVVM Architecture - Model-View-ViewModel
//  • ObservableObject - SwiftUI state management
//  • @Published - Reactive properties
//  • Combine Framework - Publishers, operators, subscriptions
//  • Async/Await - Asynchronous operations
//  • Memory Management - Weak self, retain cycles
//  • Task Management - Structured concurrency
//  • MainActor - Main thread execution
//

import Foundation
import Combine
import SwiftUI

/// 🎯 MVVM (Model-View-ViewModel)
///
/// ✅ RESPONSIBILITIES:
/// - View: UI presentation (SwiftUI views)
/// - ViewModel: Presentation logic, state management
/// - Model: Business logic (Use Cases, Repositories)
///
/// ✅ BENEFITS:
/// - Separation of concerns
/// - Testable (test ViewModel without UI)
/// - Reusable logic
/// - Reactive UI updates
///
/// ⚠️ INTERVIEW QUESTION:
/// "MVVM vs MVC vs VIPER?"
/// - MVC: View-Controller-Model (Apple's default, massive ViewControllers)
/// - MVVM: Better separation, testable ViewModels, reactive
/// - VIPER: More layers, complex, enterprise apps
/// - SwiftUI naturally fits MVVM
///

/// 📚 @MAINACTOR
///
/// ✅ WHAT IS IT?
/// - Global actor for main thread
/// - Ensures class/methods run on main thread
/// - Required for UI updates
///
/// ✅ WHY USE IT?
/// - SwiftUI requires main thread updates
/// - Prevents threading bugs
/// - Compiler-enforced safety
///
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 📚 @PUBLISHED
    ///
    /// ✅ WHAT IT DOES:
    /// - Creates a Combine Publisher
    /// - Notifies SwiftUI when value changes
    /// - Triggers view updates automatically
    ///
    /// ✅ HOW IT WORKS:
    /// - Property wrapper with projectedValue
    /// - $ prefix gives you the Publisher
    /// - ObservableObject's objectWillChange fires before change
    ///
    /// Example:
    /// ```swift
    /// @Published var articles: [Article] = []
    ///
    /// // Under the hood:
    /// var $articles: Published<[Article]>.Publisher
    /// ```

    /// Current list of articles
    @Published var articles: [Article] = []

    /// Loading state
    @Published var isLoading: Bool = false

    /// Error message (if any)
    @Published var errorMessage: String?

    /// Selected category filter
    @Published var selectedCategory: Article.Category?

    /// Current page for pagination
    @Published var currentPage: Int = 1

    /// Has more pages to load
    @Published var hasMorePages: Bool = true

    /// Search query
    @Published var searchQuery: String = ""

    // MARK: - Dependencies

    /// 📌 USE CASE INJECTION
    /// ViewModel depends on use cases, not repositories
    /// Follows Clean Architecture principle
    private let fetchArticlesUseCase: FetchArticlesUseCase

    /// 📌 COMBINE CANCELLABLES
    ///
    /// ✅ WHAT ARE CANCELLABLES?
    /// - Represents a subscription to a publisher
    /// - Must be stored or subscription cancels immediately
    /// - Automatically cancelled when object deallocates
    ///
    /// ✅ MEMORY MANAGEMENT:
    /// - Store in Set for automatic management
    /// - When ViewModel deallocates, all subscriptions cancel
    /// - Prevents memory leaks
    private var cancellables = Set<AnyCancellable>()

    /// 📌 TASK MANAGEMENT
    /// Stores active tasks for cancellation
    /// Demonstrates structured concurrency
    private var currentTask: Task<Void, Never>?

    // MARK: - Initialization

    init(fetchArticlesUseCase: FetchArticlesUseCase) {
        self.fetchArticlesUseCase = fetchArticlesUseCase

        print("✅ [ViewModel] HomeViewModel initialized")

        // Setup reactive subscriptions
        setupSubscriptions()
    }

    // MARK: - Public Methods

    /// 📚 ASYNC METHOD
    /// Fetches articles using async/await
    func loadArticles() async {
        // 📌 TASK CANCELLATION
        // Cancel any existing fetch operation
        currentTask?.cancel()

        // Prevent multiple simultaneous loads
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        // Create new task and store reference
        currentTask = Task { @MainActor in
            do {
                // 📌 ASYNC/AWAIT CALL
                // 'await' suspends function until result ready
                // Can only call async functions from async context
                let newArticles = try await fetchArticlesUseCase.execute(
                    category: selectedCategory,
                    page: currentPage,
                    forceRefresh: currentPage == 1
                )

                // 📌 TASK CANCELLATION CHECK
                // If task was cancelled, don't update UI
                if Task.isCancelled { return }

                // Update UI state
                if currentPage == 1 {
                    articles = newArticles
                } else {
                    articles.append(contentsOf: newArticles)
                }

                // Update pagination state
                hasMorePages = !newArticles.isEmpty
                currentPage += 1

                print("✅ [ViewModel] Loaded \(newArticles.count) articles")

            } catch {
                // 📌 ERROR HANDLING
                // Transform error into user-friendly message
                errorMessage = handleError(error)
                print("❌ [ViewModel] Load failed: \(error)")
            }

            isLoading = false
        }
    }

    /// Refresh articles (pull-to-refresh)
    func refresh() async {
        currentPage = 1
        await fetchArticlesUseCase.clearCache()
        await loadArticles()
    }

    /// Load next page (pagination)
    func loadMore() async {
        guard hasMorePages && !isLoading else { return }
        await loadArticles()
    }

    /// Filter by category
    func filterByCategory(_ category: Article.Category?) {
        selectedCategory = category
        currentPage = 1
        Task {
            await loadArticles()
        }
    }

    // MARK: - Combine Subscriptions

    /// 📚 SETUP REACTIVE SUBSCRIPTIONS
    ///
    /// ✅ COMBINE OPERATORS DEMONSTRATED:
    /// - debounce: Wait before emitting (avoid too many API calls)
    /// - removeDuplicates: Only emit when value changes
    /// - sink: Subscribe and handle values
    ///
    private func setupSubscriptions() {

        // 📌 SEARCH DEBOUNCE
        //
        // Problem: User types "Swift" - makes 5 API calls (S, Sw, Swi, Swif, Swift)
        // Solution: Wait 0.5s after typing stops
        //
        // ✅ COMBINE OPERATORS CHAIN:
        $searchQuery
            // 1. debounce: Wait 0.5s after last change
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)

            // 2. removeDuplicates: Only if query actually changed
            .removeDuplicates()

            // 3. map: Transform the value
            .map { query in query.trimmingCharacters(in: .whitespaces) }

            // 4. filter: Only non-empty queries
            .filter { !$0.isEmpty }

            // 5. sink: Execute side effect
            .sink { [weak self] query in
                // 📌 WEAK SELF
                //
                // ✅ WHY [weak self]?
                // - Prevents retain cycle
                // - Closure captures self strongly by default
                // - ViewModel owns cancellables, cancellables own closure
                // - Without weak, memory leak!
                //
                // ⚠️ INTERVIEW QUESTION:
                // "When to use weak vs unowned?"
                // - weak: Reference can become nil (safe, use guard let)
                // - unowned: Reference never nil (crash if wrong, use sparingly)
                // - weak is safer, use unowned only when guaranteed lifetime
                //
                guard let self = self else { return }

                print("🔍 [ViewModel] Searching for: \(query)")

                // Trigger search
                Task {
                    await self.searchArticles(query: query)
                }
            }
            // 6. store: Keep subscription alive
            .store(in: &cancellables)

        // 📌 CATEGORY FILTER
        //
        // React to category changes
        // Note: In a real app, you might trigger actions here
        // For this learning project, filtering is handled by filterByCategory method
        // This subscription demonstrates Combine observation patterns
    }

    // MARK: - Private Methods

    /// Search articles by query
    private func searchArticles(query: String) async {
        isLoading = true
        errorMessage = nil

        // Note: In real app, this would call search use case
        // For demo, we filter local articles
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Filter articles
            articles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(query) ||
                article.description.localizedCaseInsensitiveContains(query)
            }

        } catch {
            errorMessage = "Search failed"
        }

        isLoading = false
    }

    /// Convert error to user-friendly message
    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.localizedDescription
        }
        return "An unexpected error occurred"
    }

    // MARK: - Deinitialization

    deinit {
        // 📌 CLEANUP
        //
        // Cancellables automatically cancelled
        // Tasks automatically cancelled if stored weakly
        // Good practice to explicitly cancel long-running tasks
        currentTask?.cancel()

        print("🗑️ [ViewModel] HomeViewModel deinitialized")
    }
}

// MARK: - View State (Helper)

/// 📚 ENUM FOR VIEW STATE
///
/// ✅ PATTERN: Finite State Machine
/// - View can only be in ONE state at a time
/// - Makes UI logic clearer
/// - Prevents impossible states
///
extension HomeViewModel {

    /// Current view state
    var viewState: ViewState {
        if isLoading && articles.isEmpty {
            return .loading
        } else if let error = errorMessage {
            return .error(error)
        } else if articles.isEmpty {
            return .empty
        } else {
            return .loaded
        }
    }

    enum ViewState: Equatable {
        case loading
        case loaded
        case empty
        case error(String)

        /// Equatable conformance for String associated value
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading),
                 (.loaded, .loaded),
                 (.empty, .empty):
                return true
            case let (.error(lhsMsg), .error(rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }
}

// MARK: - Interview Questions

/// 📚 VIEWMODEL INTERVIEW QUESTIONS:
///
/// Q: "Why ObservableObject?"
/// A: - SwiftUI's way of observing changes
///    - Publishes objectWillChange before @Published properties change
///    - Views automatically update when published properties change
///    - Alternative: @Observable (iOS 17+, newer approach)
///
/// Q: "When to use @StateObject vs @ObservedObject?"
/// A: - @StateObject: View owns the ViewModel (creates and manages lifecycle)
///    - @ObservedObject: ViewModel passed from parent (doesn't own it)
///    - Rule: Use @StateObject at creation point, @ObservedObject when passed down
///
/// Q: "How to avoid retain cycles?"
/// A: 1. Use [weak self] in closures that outlive the object
///    2. Combine subscriptions: Always [weak self] in sink
///    3. Tasks: Usually don't need weak (auto-cancelled)
///    4. Delegates: weak var delegate
///
/// Q: "Combine vs Async/Await?"
/// A: - Combine: Reactive streams, multiple values over time, operators
///    - Async/Await: One-shot async operations, sequential flow
///    - Use both: Combine for reactive UI, async/await for network calls
///
/// Q: "How to test ViewModels?"
/// A: ```swift
///    func testLoadArticles() async {
///        let mockUseCase = MockFetchArticlesUseCase()
///        let viewModel = HomeViewModel(fetchArticlesUseCase: mockUseCase)
///
///        await viewModel.loadArticles()
///
///        XCTAssertFalse(viewModel.isLoading)
///        XCTAssertEqual(viewModel.articles.count, 3)
///    }
///    ```
///
/// Q: "@MainActor benefits?"
/// A: - Ensures all methods run on main thread
///    - SwiftUI requires main thread for updates
///    - Prevents data races on UI properties
///    - Compile-time checking (safer than DispatchQueue.main)
///
/// Q: "Memory leak indicators?"
/// A: - Deinit not called
///    - Instruments shows growing memory
///    - Retain cycles in closures ([weak self] missing)
///    - Delegates not marked weak
///    - Cancellables not stored properly
