# 📑 Complete File Index

Quick reference guide to all files in the project.

---

## 📚 Documentation Files (5)

| File | Description | Read Time |
|------|-------------|-----------|
| `README.md` | Project overview and complete guide | 20 min |
| `LEARNING_GUIDE.md` | Detailed topic explanations | 30 min |
| `TESTING_GUIDE.md` | Testing strategies and examples | 15 min |
| `QUICK_START.md` | Get started in minutes | 10 min |
| `PROJECT_SUMMARY.md` | What we built and why | 10 min |
| `FILE_INDEX.md` | This file - quick reference | 5 min |

---

## 🏗️ App Structure Files (2)

### learnerApp.swift
**Path:** `/learner/learnerApp.swift`
**Topics:** App lifecycle, @main, WindowGroup, Environment injection
**Interview Focus:** SwiftUI app architecture, dependency injection setup
**Read Time:** 10 minutes

### ContentView.swift
**Path:** `/learner/ContentView.swift`
**Topics:** TabView, Navigation, @Query, @Environment
**Interview Focus:** Navigation patterns, SwiftUI composition
**Read Time:** 15 minutes

---

## 🎯 Core Layer (3 files)

### DIContainer.swift
**Path:** `/learner/Core/DI/DIContainer.swift`
**Topics:** Dependency Injection, Service Locator, Singleton, Factory Pattern
**Interview Focus:**
- SOLID principles (especially D - Dependency Inversion)
- DI benefits for testability
- When to use singletons
**Key Concepts:**
- Constructor injection
- Protocol-based dependencies
- Factory methods
**Read Time:** 15 minutes

### UserDefault.swift
**Path:** `/learner/Core/PropertyWrappers/UserDefault.swift`
**Topics:** Property Wrappers, Generics, Where clauses, Combine integration
**Interview Focus:**
- How property wrappers work
- wrappedValue vs projectedValue
- Generic constraints
**Key Concepts:**
- Custom @propertyWrapper
- Combine publishers
- Type constraints with where
**Read Time:** 12 minutes

### View+Extensions.swift
**Path:** `/learner/Core/Extensions/View+Extensions.swift`
**Topics:** Extensions, ViewModifiers, Reusable components
**Interview Focus:**
- Extensions vs Inheritance
- Method chaining
- ViewBuilder pattern
**Key Concepts:**
- Conditional modifiers
- Custom view helpers
- Color extensions
**Read Time:** 10 minutes

---

## 💼 Domain Layer (4 files)

### Article.swift
**Path:** `/learner/Domain/Entities/Article.swift`
**Topics:** Domain models, Identifiable, Codable, Sendable, Enums
**Interview Focus:**
- Domain-Driven Design
- Value types vs reference types
- Protocol conformance
**Key Concepts:**
- Structs for immutability
- Nested enums
- CodingKeys customization
- Sendable for concurrency
**Read Time:** 15 minutes

### NetworkError.swift
**Path:** `/learner/Domain/Entities/NetworkError.swift`
**Topics:** Custom errors, Error handling, LocalizedError, Associated values
**Interview Focus:**
- Error handling strategies
- Custom error types
- User-friendly error messages
**Key Concepts:**
- Enum with associated values
- LocalizedError protocol
- Error factory methods
**Read Time:** 12 minutes

### ArticleRepositoryProtocol.swift
**Path:** `/learner/Domain/Interfaces/ArticleRepositoryProtocol.swift`
**Topics:** Protocols, Repository pattern, Async/await, Combine publishers
**Interview Focus:**
- Protocol-oriented programming
- Repository pattern benefits
- Async vs Combine
**Key Concepts:**
- Protocol as abstraction
- Protocol extensions (default implementations)
- AnyPublisher type erasure
**Read Time:** 15 minutes

### FetchArticlesUseCase.swift
**Path:** `/learner/Domain/UseCases/FetchArticlesUseCase.swift`
**Topics:** Use Case pattern, Actors, Business logic, Caching
**Interview Focus:**
- Separation of concerns
- Actor isolation
- Business rules
**Key Concepts:**
- Actor for thread safety
- Caching strategy
- Business logic separation
**Read Time:** 15 minutes

---

## 💾 Data Layer (3 files)

### NetworkService.swift
**Path:** `/learner/Data/Network/NetworkService.swift`
**Topics:** Async/await, URLSession, Generics, Error handling
**Interview Focus:**
- Modern networking
- Generic functions
- Error transformation
**Key Concepts:**
- Actor-isolated networking
- Generic fetch method
- Custom error mapping
- URLRequest building
**Read Time:** 20 minutes

### ArticleEntity.swift
**Path:** `/learner/Data/Persistence/Models/ArticleEntity.swift`
**Topics:** SwiftData, @Model, Relationships, @Attribute, Cascade deletes
**Interview Focus:**
- SwiftData vs Core Data
- Relationships
- Migrations
**Key Concepts:**
- @Model macro
- @Relationship configurations
- Entity to domain mapping
- One-to-many relationships
**Read Time:** 15 minutes

### ArticleRepositoryImpl.swift
**Path:** `/learner/Data/Persistence/Repositories/ArticleRepositoryImpl.swift`
**Topics:** Repository implementation, Combine, SwiftData queries, Caching
**Interview Focus:**
- Repository pattern implementation
- Cache strategies
- Data layer responsibilities
**Key Concepts:**
- Protocol implementation
- CurrentValueSubject
- FetchDescriptor and Predicates
- DTO to domain conversion
**Read Time:** 20 minutes

---

## 🎨 Presentation Layer (2 files)

### HomeViewModel.swift
**Path:** `/learner/Presentation/Scenes/Home/HomeViewModel.swift`
**Topics:** MVVM, ObservableObject, @Published, Combine, Async/await, Memory management
**Interview Focus:**
- MVVM architecture
- State management
- Memory leaks prevention
**Key Concepts:**
- @MainActor for UI updates
- Combine operators (debounce)
- [weak self] in closures
- Task cancellation
- Publisher subscriptions
**Read Time:** 25 minutes
**⭐ MOST IMPORTANT FILE FOR INTERVIEWS**

### HomeView.swift
**Path:** `/learner/Presentation/Scenes/Home/HomeView.swift`
**Topics:** SwiftUI, State management, Lists, Navigation, Accessibility
**Interview Focus:**
- SwiftUI view lifecycle
- Property wrappers
- Performance optimization
**Key Concepts:**
- @StateObject vs @ObservedObject
- @ViewBuilder
- .task modifier
- List optimization
- Accessibility
**Read Time:** 25 minutes
**⭐ MOST IMPORTANT FILE FOR INTERVIEWS**

---

## 📊 Reading Order by Priority

### 🔴 Critical (Read First)
1. `README.md` - Understand the project
2. `LEARNING_GUIDE.md` - Topic overview
3. `learnerApp.swift` - Entry point
4. `HomeViewModel.swift` - MVVM example ⭐
5. `HomeView.swift` - SwiftUI example ⭐

### 🟡 Important (Read Second)
6. `DIContainer.swift` - DI pattern
7. `Article.swift` - Domain model
8. `ArticleRepositoryProtocol.swift` - Repository pattern
9. `NetworkService.swift` - Networking
10. `ArticleEntity.swift` - SwiftData

### 🟢 Advanced (Read Third)
11. `FetchArticlesUseCase.swift` - Use cases
12. `ArticleRepositoryImpl.swift` - Implementation
13. `NetworkError.swift` - Error handling
14. `UserDefault.swift` - Property wrappers
15. `View+Extensions.swift` - Extensions

### ⚪ Reference (As Needed)
16. `TESTING_GUIDE.md` - Testing
17. `QUICK_START.md` - Getting started
18. `PROJECT_SUMMARY.md` - Overview
19. `ContentView.swift` - Navigation

---

## 🎯 Interview Preparation by File

### Architecture Questions → Read These
- `DIContainer.swift` - Dependency Injection
- `FetchArticlesUseCase.swift` - Use Cases
- `ArticleRepositoryProtocol.swift` - Repository Pattern
- Overall project structure

### SwiftUI Questions → Read These
- `HomeView.swift` - All SwiftUI concepts ⭐
- `ContentView.swift` - Navigation
- `View+Extensions.swift` - Custom modifiers

### Data/Networking → Read These
- `NetworkService.swift` - Async networking
- `ArticleEntity.swift` - SwiftData
- `ArticleRepositoryImpl.swift` - Data layer

### MVVM/State → Read These
- `HomeViewModel.swift` - Complete MVVM ⭐
- `HomeView.swift` - View binding

### Advanced Swift → Read These
- `UserDefault.swift` - Property wrappers
- `NetworkService.swift` - Generics
- `NetworkError.swift` - Error handling
- `Article.swift` - Protocols

---

## 📈 Topics by File

### Concurrency (Async/Await, Actors)
- `NetworkService.swift` - async/await networking
- `FetchArticlesUseCase.swift` - Actor example
- `HomeViewModel.swift` - @MainActor
- `ArticleRepositoryImpl.swift` - Actor repository

### Combine Framework
- `HomeViewModel.swift` - Publishers, operators ⭐
- `ArticleRepositoryProtocol.swift` - AnyPublisher
- `ArticleRepositoryImpl.swift` - CurrentValueSubject
- `UserDefault.swift` - Publisher integration

### SwiftData
- `ArticleEntity.swift` - Complete SwiftData example ⭐
- `ArticleRepositoryImpl.swift` - Queries
- `ContentView.swift` - @Query usage

### Memory Management
- `HomeViewModel.swift` - [weak self] examples ⭐
- All files - ARC principles

### Protocols & Generics
- `ArticleRepositoryProtocol.swift` - Protocol definition
- `NetworkService.swift` - Generic networking
- `UserDefault.swift` - Generic property wrapper

---

## ⏱️ Time Estimates

### Quick Review (2 hours)
Read starred files (⭐) and README

### Comprehensive Study (8 hours)
Read all files in priority order

### Mastery (20+ hours)
- Read all files multiple times
- Modify code and experiment
- Add new features
- Practice mock interviews

---

## 🔍 Search by Topic

Need to understand a specific topic? Here's where to look:

| Topic | Primary File | Secondary Files |
|-------|--------------|-----------------|
| @State, @StateObject | HomeView.swift | ContentView.swift |
| @Published | HomeViewModel.swift | ArticleRepositoryImpl.swift |
| @Model (SwiftData) | ArticleEntity.swift | - |
| @Query | ContentView.swift | - |
| Async/Await | NetworkService.swift | HomeViewModel.swift |
| Actors | FetchArticlesUseCase.swift | NetworkService.swift |
| Combine | HomeViewModel.swift | ArticleRepositoryImpl.swift |
| MVVM | HomeViewModel.swift + HomeView.swift | - |
| Clean Architecture | Entire project structure | - |
| Repository Pattern | ArticleRepositoryProtocol.swift | ArticleRepositoryImpl.swift |
| Dependency Injection | DIContainer.swift | All ViewModels |
| Property Wrappers | UserDefault.swift | - |
| Extensions | View+Extensions.swift | - |
| Error Handling | NetworkError.swift | NetworkService.swift |
| Generics | NetworkService.swift | UserDefault.swift |
| Protocols | ArticleRepositoryProtocol.swift | All protocols |
| Codable | Article.swift | ArticleEntity.swift |
| Navigation | ContentView.swift | HomeView.swift |
| Accessibility | HomeView.swift | View+Extensions.swift |

---

## 📱 How to Navigate the Project

### In Xcode
1. Use **⌘⇧O** (Open Quickly) to jump to files
2. Use **⌃6** to see file outline
3. Use **⌘⌥←/→** to navigate back/forward
4. Use **⌘⌃↑** to switch between .swift files

### Recommended Path
```
Start: README.md
  ↓
learnerApp.swift (entry point)
  ↓
DIContainer.swift (DI setup)
  ↓
Article.swift (domain model)
  ↓
NetworkService.swift (networking)
  ↓
ArticleEntity.swift (persistence)
  ↓
ArticleRepositoryProtocol.swift (interface)
  ↓
ArticleRepositoryImpl.swift (implementation)
  ↓
FetchArticlesUseCase.swift (business logic)
  ↓
HomeViewModel.swift (presentation logic) ⭐
  ↓
HomeView.swift (UI) ⭐
  ↓
ContentView.swift (navigation)
```

---

## ✅ Completion Checklist

### Basic Understanding
- [ ] Read README.md
- [ ] Understand project structure
- [ ] Know what each layer does
- [ ] Can explain MVVM

### Intermediate Knowledge
- [ ] Read all Domain files
- [ ] Read all Data files
- [ ] Read all Presentation files
- [ ] Understand data flow

### Advanced Mastery
- [ ] Can explain every file
- [ ] Understand all design decisions
- [ ] Can answer interview questions
- [ ] Can modify/extend code

---

## 🎓 Study Sessions

### Session 1: Foundation (1 hour)
- README.md
- learnerApp.swift
- DIContainer.swift
- Article.swift

### Session 2: Data Layer (1 hour)
- NetworkService.swift
- ArticleEntity.swift
- ArticleRepositoryImpl.swift

### Session 3: Presentation (1 hour)
- HomeViewModel.swift ⭐
- HomeView.swift ⭐
- ContentView.swift

### Session 4: Advanced (1 hour)
- FetchArticlesUseCase.swift
- UserDefault.swift
- NetworkError.swift
- View+Extensions.swift

---

## 💡 Pro Tips

1. **Don't read linearly** - Jump based on interest
2. **Follow the comments** - They guide you through concepts
3. **Use the index** - Find topics quickly
4. **Experiment** - Modify code to learn
5. **Review regularly** - Spaced repetition helps

---

**This index is your map. Use it to navigate efficiently!** 🗺️
