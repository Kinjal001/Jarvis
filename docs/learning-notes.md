# Jarvis — Developer Learning Notes

This file is your running journal. Every major concept we use, every decision we make,
and every gotcha we hit gets explained here. It grows as the project grows.

---

## Table of Contents
1. [The Big Picture — What Are We Building and Why](#1-the-big-picture)
2. [How Real Software Projects Are Structured](#2-how-real-software-projects-are-structured)
3. [The Tools We Use and Why](#3-the-tools-we-use-and-why)
4. [Clean Architecture — The Core Pattern](#4-clean-architecture)
5. [Phase 0 — What We Built and Why](#5-phase-0-what-we-built-and-why)
6. [Phase 1 PR 1 — The Domain Layer](#6-phase-1-pr-1-the-domain-layer)
7. [Gotchas and Hard-Won Lessons](#7-gotchas-and-hard-won-lessons)
8. [What to Study Next](#8-what-to-study-next)

---

## 1. The Big Picture

**What is Jarvis?**
A personal productivity OS — one app that replaces Notion (notes/projects), Todoist (tasks),
Habitica (habits), and Obsidian (knowledge). Everything in one place, with AI assistance.

**Why build it this way?**
Most productivity apps are built for a general audience. Jarvis is built for *you*, shaped
exactly to how your brain works. It's also a vehicle for learning real-world software
development — every decision here is how professional teams actually build things.

**Why Flutter?**
One codebase that runs on Android, iOS, Web, macOS, and Windows. You write code once and
it works everywhere. This matters for a solo developer — you can't maintain 4 separate apps.

**The philosophy: production-grade from day one**
It would be faster to hack something together in a weekend. But then you'd hit a wall when
you want to add features, onboard other users, or run it reliably. We build it right the
first time so we never have to rewrite it.

---

## 2. How Real Software Projects Are Structured

### Git and version control
Every change to code is saved as a "commit" with a message explaining what changed and why.
This creates a history you can always go back to. We use **Conventional Commits** — a naming
standard where commits start with `feat:`, `fix:`, `chore:`, `test:`, etc. This makes the
history readable and enables automated changelogs later.

### Branches
Instead of everyone (or every feature) directly changing the main codebase, you create a
**branch** — a parallel copy where you make your changes safely. When done, you merge the
branch back. Our `main` branch is always deployable — it's the "production truth".

### Pull Requests (PRs)
A PR is a formal request to merge your branch into main. It triggers CI (automated checks),
lets others review code, and creates a record of why changes were made. Even solo, PRs are
good practice because the CI check catches bugs before they reach users.

### CI/CD (Continuous Integration / Continuous Deployment)
CI = automated checks that run on every PR: lint (code style), tests, and build verification.
CD = automated deployment to staging/production on merge. Our CI uses **GitHub Actions** —
YAML files in `.github/workflows/` that define what runs when.

**Why this matters:** Without CI, bugs only get caught when users hit them. With CI, bugs
are caught before they ever leave your laptop.

### Environments (dev / staging / prod)
- **dev** — your local development environment. Verbose logs, dev database, can be messy.
- **staging** — a "production-like" environment used for testing before real users see it.
  CI builds and deploys here on every merge to main.
- **prod** — what real users see. Only gets updates from deliberate release tags.

We use Flutter **flavors** to switch between these — separate entry points (`main_dev.dart`,
`main_staging.dart`, `main_prod.dart`) that each load different config.

### Resources
- [Conventional Commits spec](https://www.conventionalcommits.org/en/v1.0.0/)
- [GitHub Actions docs](https://docs.github.com/en/actions)
- [Git branching explained (Atlassian)](https://www.atlassian.com/git/tutorials/using-branches)
- [Flutter flavors (official)](https://docs.flutter.dev/deployment/flavors)

---

## 3. The Tools We Use and Why

### Flutter
A UI framework made by Google. You write in **Dart** (a language similar to JavaScript/Java
but cleaner), and Flutter compiles it to native code for each platform.

**Why Flutter over React Native / other options?**
Flutter compiles to native — it doesn't use a JavaScript bridge, so it's faster and more
consistent. It also has excellent support for all platforms including desktop, which React
Native lacks.

- [Flutter official docs](https://docs.flutter.dev/)
- [Dart language tour](https://dart.dev/language)

### Riverpod (state management)
"State" is the data your UI displays — user's task list, loading status, error messages.
Managing state means deciding: where does data live? How does the UI know when it changes?

**Riverpod** is a state management library that stores state in "providers" — objects that:
- Hold data (a list of tasks, a user object, etc.)
- Notify widgets when data changes so they re-render
- Are testable and have no global singletons

Think of providers as smart containers that your widgets subscribe to. When the container
updates, only the widgets that care about it rebuild.

- [Riverpod docs](https://riverpod.dev/)
- [Why Riverpod? (Remi Rousselet's explanation)](https://riverpod.dev/docs/introduction/why_riverpod)

### Drift (local database)
A type-safe SQLite database library for Flutter/Dart. Think of it as a spreadsheet that
lives on the user's phone — fast, works offline, structured.

**Why local-first?**
The app works even when offline. This is critical for a productivity app — users need their
tasks at 6am when their internet is slow. Data is stored locally first, then synced to the
cloud when online.

**Why not just Hive or SharedPreferences?**
SQLite is a real relational database — you can query it, join tables, filter, sort. Hive
(key-value store) can't express "give me all tasks due today sorted by priority". Drift
gives you SQL power with Dart type safety.

- [Drift docs](https://drift.simonbinder.eu/)
- [SQLite tutorial (for understanding the underlying DB)](https://www.sqlitetutorial.net/)

### Supabase (cloud backend)
Firebase's open-source alternative. It gives you:
- **Auth** — email/password sign up and login (handles tokens, sessions, etc.)
- **Postgres database** — a real SQL database in the cloud
- **Realtime** — subscribe to database changes (for future sync features)
- **Edge Functions** — run server-side code (we'll use this for AI in Phase 3)

**Why Supabase over Firebase?**
Supabase uses PostgreSQL (industry-standard SQL). Firebase uses NoSQL (Firestore) which is
harder to query in complex ways. Supabase is also open-source and more predictable pricing.

- [Supabase docs](https://supabase.com/docs)

### Freezed (immutable data models)
A code generator that creates immutable data classes. "Immutable" means once created, an
object can't be changed — you create a new one with the updated value instead.

**Why immutable?**
Bugs from accidentally mutating shared state are extremely hard to debug. Immutable objects
can't be accidentally changed somewhere else in the code. Freezed also generates:
- `copyWith()` — create a modified copy: `task.copyWith(status: TaskStatus.completed)`
- `==` and `hashCode` — so `task1 == task2` works correctly
- Pattern matching (`when`, `map`) for sealed classes (like `Failure`)

- [Freezed docs](https://pub.dev/packages/freezed)

### fpdart (functional programming)
Gives us the **Either** type. `Either<Failure, Task>` is a value that is either a `Failure`
(something went wrong) OR a `Task` (success). This forces you to handle errors explicitly
— you can't ignore them like you can with try/catch.

```dart
// Without Either — easy to forget error handling:
Task task = await repo.getTask();

// With Either — you MUST handle both cases:
Either<Failure, Task> result = await repo.getTask();
result.fold(
  (failure) => showError(failure.message),  // left = failure
  (task) => showTask(task),                  // right = success
);
```

- [fpdart docs](https://pub.dev/packages/fpdart)
- [What is Either? (simple explanation)](https://medium.com/@yauhen.belski/either-in-dart-with-fpdart-6b0d7e0a9fac)

### go_router (navigation)
Handles navigation between screens. URL-based routing means the app has real URLs
(`/goals/123/projects`) which enables deep links, web support, and browser back button.

- [go_router docs](https://pub.dev/packages/go_router)

### Sentry (error monitoring)
When the app crashes or throws an error in the real world, Sentry captures it, sends you
an alert, and shows you the full stack trace, device info, and breadcrumbs (what the user
was doing before the crash). Without this, you're flying blind in production.

- [Sentry Flutter docs](https://docs.sentry.io/platforms/flutter/)

### mocktail (testing)
When testing a use case, you don't want to actually hit the database or network. You create
a **mock** — a fake version of the repository that returns whatever you tell it to. Mocktail
makes creating mocks easy in Dart.

- [mocktail docs](https://pub.dev/packages/mocktail)

---

## 4. Clean Architecture

This is the most important concept to understand. All our code follows it.

### The problem Clean Architecture solves
Imagine you write your database code directly in your UI. Now you want to:
- Switch from SQLite to a different database → rewrite all your UI code
- Test your business logic → you need a real database running
- Add a web version → UI is completely different but business logic is the same

Clean Architecture separates these concerns into **layers** that only depend inward:

```
Presentation (UI)
    ↓ calls
Domain (business logic) ← pure Dart, no dependencies
    ↑ implements
Data (database/network)
```

### The three layers explained

**Domain layer** (the core — pure Dart)
- **Entities**: The data objects your app cares about (`Task`, `Goal`, `Project`)
- **Repository interfaces**: Abstract contracts that say *what* operations are available,
  but not *how* they work (`ITaskRepository.getTasks()`)
- **Use cases**: One class per user action. `CreateTask`, `GetTasks`, `UpdateTaskStatus`.
  Each use case takes a repository interface and calls one method on it.

The domain layer has NO knowledge of Flutter, Drift, or Supabase. It's pure Dart logic.
This means you can test it without any of those things running.

**Data layer** (the *how*)
- **Repository implementations**: The actual code that calls Drift (local DB) or Supabase
  (remote API). Implements the domain interfaces.
- **Datasources**: Lower-level classes — `LocalTaskDatasource` (Drift queries),
  `RemoteTaskDatasource` (Supabase calls)
- **Models**: Convert between Drift table rows and domain entities

**Presentation layer** (the *what it looks like*)
- **Screens** and **widgets**: Flutter UI code. Never contains business logic.
- **Providers** (Riverpod): Connect domain use cases to the UI. Holds state.

### Why this separation matters
- You can test domain logic without a database or network
- You can swap Supabase for Firebase without touching domain or presentation code
- You can add a web UI without changing any business logic
- Clear rules about where code goes → easier to navigate as the project grows

### Feature-first structure
Instead of grouping all repositories together, all use cases together, etc., we group by
*feature*. Everything about Tasks lives in `lib/features/tasks/`. This makes it easy to
find everything related to one feature.

```
lib/features/tasks/
├── data/
│   ├── datasources/   ← Drift queries + Supabase calls
│   ├── models/        ← Drift row ↔ Task entity conversion
│   └── repositories/  ← TaskRepositoryImpl
├── domain/
│   ├── entities/      ← Task, TaskStatus
│   ├── repositories/  ← ITaskRepository (interface)
│   └── usecases/      ← CreateTask, GetTasks, etc.
└── presentation/
    ├── providers/     ← Riverpod providers
    └── screens/       ← TaskListScreen, etc.
```

### Resources
- [Clean Architecture (Robert C. Martin's original article)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Clean Architecture in Flutter (Reso Coder — highly recommended)](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Very Good Architecture (VGV talk)](https://verygood.ventures/blog/very-good-flutter-architecture)

---

## 5. Phase 0 — What We Built and Why

Phase 0 is pure infrastructure — zero features, but the skeleton of a professional app.

### What we built

**Project structure**
The full `lib/` folder structure following Clean Architecture. Empty folders with `.gitkeep`
files hold the places where future code will go.

**Flutter flavors**
Three entry points: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`. Each calls
`bootstrap(AppFlavor.dev/staging/prod)` which loads different `.env` files.

**Environment config** (`lib/core/config/env.dart`)
Reads Supabase URL, Supabase anon key, Sentry DSN from `.env` files. Never hardcoded.
`.env` files are gitignored — `.env.example` shows what keys are needed without values.

**Drift database** (`lib/core/database/app_database.dart`)
An empty database (schema v1, no tables yet). Phase 1 adds the tables. The empty setup
proves the database layer compiles and connects correctly.

**Supabase initialization** (`lib/bootstrap.dart`)
`Supabase.initialize()` runs before the app starts. Makes the Supabase client available.

**Sentry initialization** (`lib/bootstrap.dart`)
`SentryFlutter.init()` wraps the whole app. Any uncaught exception automatically goes to
Sentry. We also have `SentryService.captureException()` for manually captured errors.

**go_router** (`lib/core/router/app_router.dart`)
One route (`/`) pointing to a placeholder `HomeScreen`. Actual routes added in Phase 1 PR 3.

**GitHub Actions CI** (`.github/workflows/pr.yml` and `main.yml`)
- `pr.yml`: On every PR — pub get → build_runner → create .env → dart format check →
  flutter analyze → flutter test → coverage check → Android build → Web build
- `main.yml`: On merge to main — same + staging deploy

**Branch protection**
`main` is protected. No direct pushes. PRs must pass CI. This forces the workflow:
feature branch → PR → CI green → merge.

### The gotchas we hit in Phase 0 (and what we learned)

1. **CI Flutter version mismatch**: CI was set to Flutter 3.27.0 but pubspec required
   Dart 3.11.0 (only available in Flutter 3.41.2). Lesson: always match CI Flutter version
   to your local version.

2. **`.env` files missing on CI**: The analyzer checks that assets declared in pubspec.yaml
   exist on disk. `.env` files are gitignored so they don't exist in CI. Fix: create fake
   `.env` files from GitHub Secrets BEFORE running the analyze step.

3. **`dart format` differences**: Windows and Linux format Dart code slightly differently.
   The CI (Linux) detected formatting that didn't match what Windows wrote. Fix: always run
   `dart format .` locally before committing.

4. **Flutter web doesn't support `--flavor`**: `flutter build web --flavor dev` fails.
   Web builds use the `-t` (target) flag to pick the entry point instead.

5. **Deprecated Sentry API**: `scope.setExtra()` was replaced by `scope.setContexts()`.
   Lesson: always check for deprecation warnings in analyze output.

---

## 6. Phase 1 PR 1 — The Domain Layer

### What we built

**5 entities** (the core data objects)

| Entity | File | What it represents |
|---|---|---|
| `Goal` | `features/goals/domain/entities/goal.dart` | A high-level ambition (e.g. "Learn ML") |
| `Project` | `features/projects/domain/entities/project.dart` | A structured effort under a goal |
| `Subtask` | `features/projects/domain/entities/subtask.dart` | A step within a project |
| `Task` | `features/tasks/domain/entities/task.dart` | A standalone action item |
| `AppUser` | `features/auth/domain/entities/app_user.dart` | The signed-in user |

All entities use **Freezed** — they're immutable and have `copyWith()`.

**5 repository interfaces** (contracts — *what* can be done, not *how*)

| Interface | Operations |
|---|---|
| `IGoalRepository` | getGoals, createGoal, updateGoal, archiveGoal |
| `IProjectRepository` | getProjects, getProjectsByGoal, createProject, updateProject, archiveProject |
| `ISubtaskRepository` | getSubtasksByProject, createSubtask, updateSubtask, updateSubtaskStatus |
| `ITaskRepository` | getTasks, getTasksDueToday, createTask, updateTaskStatus |
| `IAuthRepository` | signIn, signUp, signOut, getCurrentUser, authStateChanges (Stream) |

**21 use cases** (one class per user action)

Every use case follows the exact same pattern:
```dart
class CreateGoal {
  final IGoalRepository _repository;
  const CreateGoal(this._repository);          // takes the interface, not the implementation

  Future<Either<Failure, Goal>> call(Goal goal) =>
      _repository.createGoal(goal);            // delegates to repository, returns Either
}
```

Why one class per use case instead of one class per feature?
- Each class has a single responsibility (Single Responsibility Principle)
- Easy to test in isolation — just test `CreateGoal`, not a giant `GoalService`
- Easy to see what the app can do — every use case file is one action

**38 unit tests** — every use case is tested against a mock repository.

### Why Goals get their own feature folder
Goals are NOT inside `features/projects/`. They're at `features/goals/`.

This is because Goals are an **aggregate root** — an independent concept that projects can
optionally belong to. In Phase 3, the AI Planner will create Goals directly without any
Projects. If Goals were nested inside Projects, that wouldn't make sense. Architecture
decisions like this prevent painful rewrites later.

### The fpdart `Task` name collision
The `fpdart` package exports a type called `Task` (a functional programming concept —
a lazy async computation). Our entity is also called `Task`. When both are imported,
Dart doesn't know which one you mean → error.

Fix: `import 'package:fpdart/fpdart.dart' hide Task;`

This tells Dart: "import everything from fpdart EXCEPT Task". Applied to every file in
the tasks feature that uses both fpdart and the Task entity.

### The mocktail `registerFallbackValue` requirement
When a test uses `any()` as an argument matcher (e.g., "match any Task"), mocktail needs
to know what type `any()` is matching so it can create a typed placeholder. For built-in
types (String, int), mocktail handles this automatically. For custom types (Goal, Task,
SubtaskStatus), you must register a fallback value first:

```dart
setUpAll(() {
  registerFallbackValue(_makeTask());         // for Task
  registerFallbackValue(TaskStatus.pending);  // for TaskStatus enum
});
```

`setUpAll` runs once before all tests in the file. `setUp` runs before each individual test.

---

## 7. Gotchas and Hard-Won Lessons

These are things that aren't obvious from tutorials but will trip you up.

| Gotcha | The Fix | Why It Happens |
|---|---|---|
| Freezed `class Foo with _$Foo` fails | Use `abstract class Foo with _$Foo` | Freezed 3.x changed the API |
| `Task` ambiguous import | `hide Task` on fpdart import | fpdart exports its own `Task` monad |
| `any()` on custom type fails | `setUpAll(() => registerFallbackValue(...))` | mocktail needs type info for custom types |
| CI analyze fails on missing .env | Create .env before analyze in CI | Analyzer checks assets exist on disk |
| `flutter build web --flavor dev` fails | Remove `--flavor`, use `-t lib/main_dev.dart` | Web doesn't support Flutter flavors |
| Formatting check fails on CI | `dart format .` before every commit | Windows/Linux format code differently |
| Push to main rejected (GH006) | Create a PR branch, push there, open PR | Branch protection prevents direct pushes |
| Generated files cause errors | `dart run build_runner build` | `*.g.dart` and `*.freezed.dart` are gitignored |

---

## 8. What to Study Next

As we go through each phase, here are the concepts you'll encounter. Study these before
or while we implement them.

### For Phase 1 PR 2 (Data Layer — coming next)
- **SQLite basics** — what tables, columns, primary keys, and foreign keys are
  - [SQLite tutorial](https://www.sqlitetutorial.net/) — do the first 5 lessons
- **Drift tables in Dart** — how to define tables as Dart classes
  - [Drift getting started](https://drift.simonbinder.eu/docs/getting-started/)
- **Database migrations** — what happens when you change the schema after users have data
  - [Drift migrations](https://drift.simonbinder.eu/docs/advanced-features/migrations/)
- **Repository pattern** — why we wrap the database behind an interface
  - [Repository pattern explained](https://medium.com/@pererikbergman/repository-design-pattern-e28c0f3e4a30)

### For Phase 1 PR 3 (Presentation Layer)
- **Riverpod AsyncNotifier** — the state management pattern we use for data lists
  - [Riverpod AsyncNotifier tutorial](https://riverpod.dev/docs/essentials/side_effects)
- **go_router auth redirect** — how to redirect unauthenticated users to login
  - [go_router redirect docs](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
- **Flutter form handling** — TextEditingController, validation, submit
  - [Flutter forms cookbook](https://docs.flutter.dev/cookbook/forms)

### For Phase 1 PR 4 (Sync Service)
- **Supabase upsert** — insert or update if exists (for conflict-safe sync)
  - [Supabase upsert docs](https://supabase.com/docs/reference/dart/upsert)
- **Background services in Flutter** — running sync without blocking the UI
  - [Dart async/await explained](https://dart.dev/codelabs/async-await)

### General concepts worth understanding deeply
- **Dart async/await** — how Future and Stream work in Dart
  - [Dart async docs](https://dart.dev/codelabs/async-await)
- **Functional programming basics** — what Either, Option, and pure functions are
  - [FP for the confused (readable intro)](https://dev.to/shakib609/functional-programming-basics-in-dart-4bh4)
- **Dependency injection** — how providers pass dependencies without global variables
  - [DI explained simply](https://medium.com/@yauhen.belski/dependency-injection-in-flutter-with-riverpod-e4c5b0a7e5d8)

---

*This file is updated at the end of every phase/PR. Last updated: Phase 1 PR 1 merged.*
