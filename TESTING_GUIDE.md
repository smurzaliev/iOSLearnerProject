# iOS Testing Guide - Interview Preparation

## 📚 Testing Concepts for Senior iOS Interviews

This guide covers essential testing topics for iOS development interviews.

---

## 🎯 Types of Tests

### 1. Unit Tests
**What:** Test individual components in isolation

**Example:**
```swift
import XCTest
@testable import learner

final class FetchArticlesUseCaseTests: XCTestCase {

    var sut: FetchArticlesUseCase!
    var mockRepository: MockArticleRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockArticleRepository()
        sut = FetchArticlesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testFetchArticles_Success() async throws {
        // Arrange
        let expectedArticles = [Article.preview]
        mockRepository.articlesToReturn = expectedArticles

        // Act
        let articles = try await sut.execute()

        // Assert
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles.first?.title, expectedArticles.first?.title)
    }

    func testFetchArticles_NetworkError() async {
        // Arrange
        mockRepository.shouldThrowError = true

        // Act & Assert
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
```

### 2. Integration Tests
**What:** Test multiple components working together

**Example:**
```swift
func testArticleRepository_FetchAndSave() async throws {
    // Test network + persistence integration
    let networkService = NetworkService()
    let modelContext = /* test context */
    let repository = ArticleRepositoryImpl(
        networkService: networkService,
        modelContext: modelContext
    )

    let articles = try await repository.fetchArticles(category: .technology, page: 1)
    try await repository.saveArticle(articles.first!)

    let favorites = try await repository.fetchFavoriteArticles()
    XCTAssertEqual(favorites.count, 1)
}
```

### 3. UI Tests
**What:** Test user interface and user flows

**Example:**
```swift
final class HomeViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testArticleListDisplaysCorrectly() {
        // Wait for articles to load
        let articleList = app.tables.firstMatch
        XCTAssertTrue(articleList.waitForExistence(timeout: 5))

        // Verify articles are displayed
        XCTAssertTrue(articleList.cells.count > 0)
    }

    func testTapArticleNavigatesToDetail() {
        let firstArticle = app.tables.cells.firstMatch
        firstArticle.tap()

        // Verify navigation occurred
        XCTAssertTrue(app.navigationBars["Article Detail"].exists)
    }
}
```

---

## 🧪 Testing Best Practices

### AAA Pattern (Arrange-Act-Assert)

```swift
func testViewModel_LoadArticles() async {
    // Arrange - Set up test conditions
    let mockUseCase = MockFetchArticlesUseCase()
    let viewModel = HomeViewModel(fetchArticlesUseCase: mockUseCase)

    // Act - Perform the action
    await viewModel.loadArticles()

    // Assert - Verify the results
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertEqual(viewModel.articles.count, 3)
}
```

### FIRST Principles

- **F**ast - Tests should run quickly
- **I**solated - No dependencies between tests
- **R**epeatable - Same results every time
- **S**elf-validating - Pass or fail, no manual verification
- **T**imely - Written alongside code

---

## 🎭 Mocking & Test Doubles

### Mock Repository Example

```swift
class MockArticleRepository: ArticleRepositoryProtocol {

    // Control test behavior
    var articlesToReturn: [Article] = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.unknown

    // Track method calls
    var fetchArticlesCalled = false
    var saveArticleCalled = false

    func fetchArticles(category: Article.Category?, page: Int) async throws -> [Article] {
        fetchArticlesCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return articlesToReturn
    }

    func saveArticle(_ article: Article) async throws {
        saveArticleCalled = true
    }

    // ... implement other protocol requirements
}
```

### Types of Test Doubles

1. **Dummy** - Passed but never used
2. **Stub** - Returns predefined data
3. **Spy** - Records how it was called
4. **Mock** - Pre-programmed with expectations
5. **Fake** - Working implementation (simplified)

---

## ⏱️ Testing Async/Await

```swift
func testAsyncOperation() async throws {
    // Use async test function
    let result = try await networkService.fetch(endpoint: .articles())
    XCTAssertNotNil(result)
}

func testAsyncOperationWithTimeout() async {
    // Test with timeout
    let expectation = XCTestExpectation(description: "Fetch completes")

    Task {
        _ = try await networkService.fetch(endpoint: .articles())
        expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 5)
}
```

---

## 🔄 Testing Combine

```swift
func testPublisher() {
    var cancellables = Set<AnyCancellable>()
    let expectation = XCTestExpectation(description: "Publisher emits value")

    viewModel.favoritesPublisher
        .sink { articles in
            XCTAssertEqual(articles.count, 5)
            expectation.fulfill()
        }
        .store(in: &cancellables)

    // Trigger publisher
    viewModel.loadFavorites()

    wait(for: [expectation], timeout: 2)
}
```

---

## 💾 Testing SwiftData

```swift
func testSwiftDataModel() throws {
    // Create in-memory container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: ArticleEntity.self,
        configurations: config
    )
    let context = ModelContext(container)

    // Create and save entity
    let article = ArticleEntity(from: Article.preview)
    context.insert(article)
    try context.save()

    // Fetch and verify
    let descriptor = FetchDescriptor<ArticleEntity>()
    let articles = try context.fetch(descriptor)

    XCTAssertEqual(articles.count, 1)
    XCTAssertEqual(articles.first?.title, Article.preview.title)
}
```

---

## 📊 Code Coverage

### What is Code Coverage?
- Measures percentage of code executed by tests
- Higher coverage ≠ better tests, but helps find gaps
- Target: 70-80% for most projects

### How to Check Coverage in Xcode
1. Edit Scheme → Test → Options
2. Enable "Code Coverage"
3. Run tests (Cmd+U)
4. View coverage in Report Navigator

### What to Test
✅ Business logic (use cases)
✅ View models
✅ Data transformations
✅ Error handling
✅ Edge cases

❌ SwiftUI views (brittle, test behavior instead)
❌ Third-party libraries
❌ Generated code

---

## 🎯 Common Interview Questions

### Q: "What's the difference between XCTest and XCUITest?"
**A:**
- **XCTest:** Unit and integration tests, tests code directly
- **XCUITest:** UI tests, tests from user's perspective
- XCTest is faster, XCUITest is more end-to-end

### Q: "How do you test ViewModels?"
**A:**
```swift
@MainActor
func testViewModel() async {
    let mockUseCase = MockFetchArticlesUseCase()
    let viewModel = HomeViewModel(fetchArticlesUseCase: mockUseCase)

    await viewModel.loadArticles()

    XCTAssertFalse(viewModel.isLoading)
    XCTAssertEqual(viewModel.articles.count, mockUseCase.articlesToReturn.count)
}
```

### Q: "How do you test async code?"
**A:**
- Use `async` test functions (Swift 5.5+)
- Use `XCTestExpectation` for older code
- Use `await` for async operations
- Test cancellation with `Task.isCancelled`

### Q: "What is TDD (Test-Driven Development)?"
**A:**
1. Write failing test (Red)
2. Write minimal code to pass (Green)
3. Refactor (Refactor)
4. Repeat

Benefits: Better design, fewer bugs, documentation

### Q: "How do you mock dependencies?"
**A:**
- Create protocol for dependency
- Create mock implementation
- Inject mock in tests
- Control behavior and verify calls

---

## 🏗️ Testable Architecture

### Dependency Injection Enables Testing

```swift
// ❌ Hard to test (hidden dependency)
class BadViewModel {
    let repository = ArticleRepositoryImpl()  // Hardcoded!
}

// ✅ Easy to test (dependency injection)
class GoodViewModel {
    let repository: ArticleRepositoryProtocol  // Protocol!

    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }
}

// Test
let mockRepo = MockArticleRepository()
let viewModel = GoodViewModel(repository: mockRepo)
```

---

## 🚀 Advanced Testing Topics

### Snapshot Testing
Compare UI screenshots to detect visual regressions

### Performance Testing
```swift
func testPerformance() {
    measure {
        // Code to benchmark
        _ = viewModel.processData()
    }
}
```

### Flaky Tests
- Tests that sometimes pass, sometimes fail
- Often due to timing issues or shared state
- Fix by isolating tests and using proper async handling

---

## 📝 Key Takeaways

1. **Write tests for business logic first** (highest ROI)
2. **Use dependency injection** for testability
3. **Mock external dependencies** (network, database)
4. **Test behavior, not implementation** (avoid brittle tests)
5. **Keep tests fast and isolated** (FIRST principles)
6. **Use meaningful test names** (`test_whenCondition_thenExpectedBehavior`)
7. **Test edge cases and error paths**
8. **Don't aim for 100% coverage** (diminishing returns)

---

## 🎓 Interview Pro Tips

- Explain your testing strategy for a feature
- Discuss trade-offs (unit vs integration vs UI tests)
- Mention TDD if you practice it
- Show examples of mocking complex dependencies
- Discuss continuous integration (CI) and test automation
- Understand when NOT to write tests (simple getters/setters)

**Remember:** Good tests give confidence to refactor and add features!
