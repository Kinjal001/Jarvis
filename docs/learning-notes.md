# Jarvis — Developer Learning Notes

This file is your running journal. Every major concept we use, every decision we make,
and every gotcha we hit gets explained here. It grows as the project grows.

---

## Table of Contents
1. [The Big Picture — What Are We Building and Why](#1-the-big-picture)
2. [How Real Software Projects Are Structured](#2-how-real-software-projects-are-structured)
3. [The Tools We Use and Why](#3-the-tools-we-use-and-why)
4. [Clean Architecture — The Core Pattern](#4-clean-architecture)
5. [Phase 0 — Foundation](#5-phase-0-what-we-built-and-why)
6. [Phase 1 PR 1 — Domain Layer](#6-phase-1-pr-1-the-domain-layer)
7. [Phase 1 PR 2 — Data Layer](#7-phase-1-pr-2-the-data-layer)
8. [Phase 1 PR 3 — Presentation Layer](#8-phase-1-pr-3-the-presentation-layer)
9. [Phase 1 PR 4 — Sync Service](#9-phase-1-pr-4-sync-service)
10. [Phase 1.5 — UI Overhaul](#10-phase-15-ui-overhaul)
11. [Phase 2 PR 7 — Habits Domain Layer](#11-phase-2-pr-7-habits-domain-layer)
12. [Phase 2 PR 8 — Habits Data Layer](#12-phase-2-pr-8-habits-data-layer)
13. [Drift on the Web — SQLite WASM](#13-drift-on-the-web-sqlite-wasm)
14. [Gotchas and Hard-Won Lessons](#14-gotchas-and-hard-won-lessons)
15. [What to Study Next (Phase 2 UI)](#15-what-to-study-next-phase-2-ui)

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

We use `@riverpod` code generation — you write the logic, Riverpod generates the boilerplate.
`AsyncNotifier` is the main pattern: a provider that manages async data (like a list from DB).

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

### go_router (navigation)
Handles navigation between screens. URL-based routing means the app has real URLs
(`/goals/123`) which enables deep links, web support, and browser back button.

Key concepts used:
- **GoRoute** — a single route (screen)
- **ShellRoute** — a wrapper route that persists UI (our bottom nav bar) across child routes
- **redirect callback** — runs on every navigation, lets you redirect unauthenticated users

- [go_router docs](https://pub.dev/packages/go_router)

### Sentry (error monitoring)
When the app crashes or throws an error in the real world, Sentry captures it, sends you
an alert, and shows you the full stack trace, device info, and breadcrumbs (what the user
was doing before the crash).

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

---

## 5. Phase 0 — What We Built and Why

Phase 0 is pure infrastructure — zero features, but the skeleton of a professional app.

### What we built

**Flutter flavors**: Three entry points: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`.

**Environment config** (`lib/core/config/env.dart`): Reads Supabase URL, Supabase anon key,
Sentry DSN from `.env` files. Never hardcoded. `.env` files are gitignored.

**Drift database** (`lib/core/database/app_database.dart`): Empty database (schema v1, no tables).
Phase 1 adds the tables.

**GitHub Actions CI** (`.github/workflows/pr.yml`): On every PR — pub get → build_runner →
create .env → dart format check → flutter analyze → flutter test → coverage check →
Android build → Web build.

**Branch protection**: `main` is protected. No direct pushes. PRs must pass CI.

### The gotchas we hit in Phase 0
1. **CI Flutter version mismatch** — Always match CI Flutter version to your local version.
2. **`.env` files missing on CI** — Create fake `.env` files from GitHub Secrets BEFORE running the analyze step.
3. **`dart format` differences** — Windows and Linux format Dart code slightly differently. Run `dart format .` locally before committing.
4. **Flutter web doesn't support `--flavor`** — Use `-t lib/main_dev.dart` instead.
5. **Deprecated Sentry API** — `scope.setExtra()` was replaced by `scope.setContexts()`.

---

## 6. Phase 1 PR 1 — The Domain Layer

### What we built

**5 entities** (Freezed, immutable, pure Dart):

| Entity | What it represents |
|---|---|
| `Goal` | A high-level ambition ("Learn ML") with status, intention, deadline |
| `Project` | A structured effort under a goal with priority and status |
| `Subtask` | A step within a project with sort order and recurrence fields |
| `Task` | A standalone action item with dueDate and recurring support |
| `AppUser` | The signed-in user (id + email) |

**5 repository interfaces** — contracts saying *what* is possible, not *how*.

**21 use cases** — one class per user action, all following the same pattern:
```dart
class CreateGoal {
  final IGoalRepository _repository;
  const CreateGoal(this._repository);

  Future<Either<Failure, Goal>> call(Goal goal) => _repository.createGoal(goal);
}
```

**38 unit tests** — every use case tested against a mocktail mock repository.

### Key lessons
- **Goals are an aggregate root** — they live at `features/goals/`, NOT inside `features/projects/`. Phase 3's AI Planner will create Goals without Projects. Architecture decisions like this prevent painful rewrites.
- **fpdart `Task` name collision** — `hide Task` on the fpdart import in all task files.
- **mocktail `registerFallbackValue`** — needed for every custom type used with `any()`.

---

## 7. Phase 1 PR 2 — The Data Layer

### What we built

**Drift tables** (schema version 2 — upgraded from Phase 0's empty v1):

Every table has these standard columns:
- `id TEXT` — UUID primary key (Drift doesn't have a native UUID type, so TEXT it is)
- `syncStatus TEXT` — `'synced'` or `'pendingUpload'` — this is how the sync service knows what to push
- `createdAt`, `updatedAt` — DateTime columns for last-write-wins conflict resolution

```dart
class TasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  // ...
  TextColumn get syncStatus => text().withDefault(const Constant('pendingUpload'))();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Database migrations**: When you change the database schema (add a table, add a column),
you must tell Drift how to upgrade existing databases. Schema version went from 1 → 2,
and `MigrationStrategy.onUpgrade` creates all new tables for users upgrading from v1.

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.createTable(goalsTable);
      // ... all tables
    }
  },
);
```

**Why migrations matter**: Real users have data in their phone's SQLite database. If you
add a table without a migration, their app will crash when it tries to use a table that
doesn't exist. Migrations run automatically when the app starts after an update.

**Data models** (`GoalModel`, `TaskModel`, etc.): Each model has three conversion methods:
- `fromRow(row)` — converts a Drift database row into a domain entity
- `toCompanion(entity)` — converts a domain entity into what Drift needs to write to DB
- `toRemoteMap(entity)` / `fromRemoteMap(map)` — converts to/from Supabase JSON format

**Local datasources** (e.g., `GoalLocalDatasource`): Wrap Drift queries. The datasource
handles SQL; the repository handles business logic. This separation means you can test
each in isolation.

**Repository implementations** (e.g., `GoalRepositoryImpl`): Write to local Drift first
(instant, offline-safe), then attempt Supabase in the background. Catches exceptions and
converts them to typed `Failure` objects that the domain layer can understand.

**Auth datasource** (Supabase only — no local table needed): Supabase handles session
persistence automatically — no need to store tokens yourself.

### Key lessons
- **Write local first, sync later** — this is what makes the app offline-capable. If Supabase is down or there's no internet, the user never notices.
- **syncStatus column** — the bridge between local and remote. Every write sets it to `'pendingUpload'`. The sync service reads this to know what to push.
- **Testing datasources with a real in-memory DB** — Drift's `NativeDatabase.memory()` lets you run actual SQL in tests without touching files. This is more reliable than mocks for DB tests.

---

## 8. Phase 1 PR 3 — The Presentation Layer

### What we built

**go_router auth guard** — A `redirect` callback that runs before every navigation:
```dart
redirect: (context, state) {
  final isAuth = authState.valueOrNull != null;
  final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
  if (!isAuth && !isOnAuth) return '/login';  // redirect to login if not signed in
  if (isAuth && isOnAuth) return '/today';    // redirect to home if already signed in
  return null;  // no redirect needed
},
```

**Riverpod `AsyncNotifier` pattern** — the standard pattern for managing async lists:
```dart
@riverpod
class GoalList extends _$GoalList {
  @override
  Future<List<Goal>> build() => ref.watch(getGoalsProvider).call();

  Future<void> create({required String title, required String intention}) async {
    final result = await ref.read(createGoalProvider).call(/* ... */);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),  // refresh the list
    );
  }
}
```

When `invalidateSelf()` is called, `build()` re-runs and all widgets watching this provider
get the updated list. Clean and automatic.

**ConsumerWidget vs ConsumerStatefulWidget**:
- Use `ConsumerWidget` (simpler) when there's no local state (most screens)
- Use `ConsumerStatefulWidget` when you need `TextEditingController`, `FocusNode`, or `AnimationController` — anything that needs `initState()` / `dispose()`

**TextEditingController lifecycle** (a common crash source):
```dart
// WRONG — creates controller in build(), leaks memory:
Widget build(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController(); // new controller every rebuild!

  // RIGHT — use dialog-scoped controller:
  Future<void> _showDialog() async {
    final controller = TextEditingController();
    await showDialog(builder: (ctx) => AlertDialog(/* uses controller */));
    controller.dispose(); // clean up after dialog closes
  }
}
```

**ShellRoute** — a go_router concept where a wrapper widget persists while child routes
change. Our bottom nav bar is implemented this way. The key insight: detail routes (like
`/goals/:id`) are defined OUTSIDE the ShellRoute so the bottom nav disappears on them.

### Key lessons
- **Never create controllers in `build()`** — use `ConsumerStatefulWidget` with `dispose()`, or dialog-scoped controllers disposed after the dialog closes.
- **`ref.invalidateSelf()`** is the go-to for "I changed data, refresh the list".
- **Detail routes outside the shell** — prevents bottom nav showing on detail screens.

---

## 9. Phase 1 PR 4 — Sync Service

### What we built

`lib/core/sync/sync_service.dart` — a class that syncs local Drift data with Supabase.

**Push (local → remote)**:
1. Query Drift for all rows where `syncStatus = 'pendingUpload'`
2. Upsert them to Supabase (insert if new, update if exists — conflict-safe)
3. If upsert succeeds: mark those rows as `syncStatus = 'synced'`
4. If upsert fails: leave them as `pendingUpload` (they'll retry next sync)

**Pull (remote → local)**:
1. Find the latest `updatedAt` timestamp in local Drift
2. Ask Supabase for all rows newer than that timestamp
3. Upsert them into local Drift, marking them `synced`

**Conflict resolution: last-write-wins**
If a row exists both locally and remotely with different data, the one with the newer
`updatedAt` timestamp wins. This is the simplest correct strategy. It's not perfect
(if you edit the same task on two devices offline simultaneously, you'll lose one edit),
but it handles 99% of real-world cases well.

**Triggered by**: app startup, sign-in. In Phase 4+, also triggered by app resume (using
`WidgetsBindingObserver`).

**Error handling**: Sync errors are swallowed (not shown to the user). Sync is best-effort
— the app works fully without it. Errors are logged to Sentry.

### Why sync is hard (and why we kept it simple)
Real-time sync with offline support is one of the hardest problems in software. We avoid
complexity by:
- Never deleting rows (we archive/status-change them)
- Last-write-wins for conflicts
- Single-user (no multi-user concurrency yet)
- Pull on startup, not real-time

### Key lesson
- **`syncStatus` column** — this column is what makes the whole sync strategy work. Without it, you'd have to compare every row against every remote row on every sync (O(n²) nightmare). With it, you only push what changed.

---

## 10. Phase 1.5 — UI Overhaul

### Why this phase existed
Phase 1 was functional but visually bare — white theme, no bottom nav, deep screen nesting.
Testing on an Android device showed the UI actively discourages daily use. The fix wasn't
"make it prettier" — it was "redesign with behavioral psychology in mind."

### Behavioral psychology applied to UI design

**Goal gradient effect**: People work harder as they get closer to a goal. A progress bar
that goes from 0% → 10% → 50% → 100% is more motivating than a number count. We added
progress bars everywhere: subtasks in project detail, today's tasks in the circular ring.

**Zeigarnik effect**: Incomplete tasks stay in your working memory until done. We sort lists
pending-first, completed-last. This makes incomplete items visible and creates mild mental
tension that drives completion.

**Variable reward**: Unpredictable rewards are more addictive than predictable ones (slot
machines use this). The completion ring turns emerald AND changes text at 100%. The color
change is a small surprise that rewards the behavior.

**Implementation intention**: People who plan *exactly* what they'll do are far more likely
to do it. The Today screen shows "here's what you're doing today" rather than a generic
backlog — it removes the decision of what to work on.

**Loss aversion**: Losing something hurts more than gaining something equivalent feels good.
The streak counter (placeholder now, real in Phase 2) will make users afraid to break their
streak — more powerful than showing "days completed".

### Key Flutter patterns used

**Material 3 custom ColorScheme** (not `ColorScheme.fromSeed`):
`fromSeed` generates colors algorithmically from one seed color. We want exact hex values
for each color, so we use `const ColorScheme(...)` with every field explicitly set.

**`withValues(alpha: 0.12)`** instead of `withOpacity(0.12)`:
Flutter deprecated `withOpacity()` — it doesn't properly handle different color spaces.
`withValues(alpha:)` is the correct modern API.

**ShellRoute + detail routes outside shell**:
The bottom nav is in a `ShellRoute`. When you tap a goal card, `context.push('/goals/id')`
navigates to a route defined OUTSIDE the shell — so the bottom nav disappears automatically,
and the back button appears. This is how navigation should work on mobile: full-screen detail
views, bottom nav only on main tabs.

**Diamond FAB** (`Transform.rotate(angle: pi/4)`):
A square container rotated 45° looks like a diamond visually. Flutter's layout engine still
treats it as a square (no layout impact). The icon inside is counter-rotated -45° to stay
upright. `FloatingActionButtonLocation.centerDocked` with `extendBody: true` lets content
scroll under the nav bar.

**Gradient border trick**:
Flutter has no direct gradient border property. The trick: outer `Container` with gradient
`BoxDecoration` + `padding: 1.5` + inner `Container` with solid background. The visible
"border" is actually the gradient peeking through the padding gap.

### Key lessons from Phase 1.5 CI failures

**Android Gradle Plugin (AGP) versions**:
Android Studio will sometimes auto-upgrade your AGP in `settings.gradle.kts` when you sync
or accept upgrade prompts. The new version may not yet be on Google Maven (the server where
Gradle downloads plugins from). When CI runs `flutter build apk`, it downloads AGP fresh
from Google Maven — if that version doesn't exist there, the build fails.

Rule: after any Android Studio Gradle sync, check `android/settings.gradle.kts`. If it
bumped AGP to a version > 8.10.x, revert it until you've verified it's on Maven.

**AGP ↔ dependency compatibility**:
Each AGP version sets a minimum for the `androidx.*` dependencies it can process.
`androidx.core:1.17.0` requires AGP ≥ 8.9.1. Going too low also breaks things.

**Flutter's Kotlin minimum**:
Flutter 3.41.2 requires Kotlin ≥ 2.1.0. The warning appears at build time and will become
an error in a future Flutter version. Keep Kotlin at 2.1.x.

**Widget tests must match the actual UI**:
When we redesigned the screens, some widget tests referenced strings or widget keys that
no longer existed (e.g., a sign-out button that moved from Goals to Profile, "Today" title
that became a greeting). The lesson: widget tests are specifications — when you intentionally
change UI behavior, update the tests to match the new spec.

---

## 11. Phase 2 PR 7 — Habits Domain Layer

### What makes habits architecturally different from tasks?

A task is a one-time event. A habit is a recurring pattern tracked over time. This requires
two entities instead of one:

```
Habit            ← the definition (what, how often, goal count)
HabitCompletion  ← each individual log (when it was done)
```

The habit itself rarely changes. The completions accumulate every day. This one-to-many
relationship is fundamental — you query "all completions for habit X" to compute streaks.

### HabitFrequency enum

```dart
enum HabitFrequency { daily, weekly }
```

Why a separate file? Enums that are used across entities (habit.dart references it, so does
streak_calculator.dart, so will the UI layer) should live in their own file. This avoids
circular imports and makes the dependency graph clean.

### targetDaysOfWeek — why List<int>?

For weekly habits, you need to know which days of the week to track (e.g., Mon/Wed/Fri).
ISO 8601 defines weekdays as integers: 1=Monday, 2=Tuesday, ..., 7=Sunday.

Storing `[1, 3, 5]` means "Monday, Wednesday, Friday". The list is empty for daily habits
(every day is a target, so specifying days would be redundant).

### StreakCalculator — pure domain logic

This is the most interesting class in the domain layer. It's a pure function: no database
calls, no network, no randomness. Given a list of completions and a frequency, it computes
the streak. This makes it trivially testable.

**The "today rule":**
If the user hasn't logged a habit today but did yesterday, the streak is *still alive*. The
day isn't over yet. Only if both today AND yesterday are missing does the streak break.

```dart
DateTime cursor = anchor; // anchor = today
if (!dateSet.contains(cursor)) {
  cursor = anchor.subtract(const Duration(days: 1));  // try yesterday
  if (!dateSet.contains(cursor)) return 0;  // streak broken
}
// walk backwards counting consecutive days
```

**Why `abstract final class`?**
`abstract` prevents instantiation (you can't do `StreakCalculator()`). `final` prevents
subclassing (nothing should extend a utility class). Together they signal: "this is a
namespace for pure functions, not a class to be used as an object."

### 17 streak calculator tests

The test suite covers every edge case:
- Empty list → 0
- Single completion 2 days ago → 0 (streak broken)
- Only today → 1
- Only yesterday → 1 (today rule)
- Consecutive 3 days ending today → 3
- Gap in distant history doesn't affect current streak
- Duplicate dates on same day count as one
- Longest streak finds the longest run, not the current run

This is exactly what unit tests are for: edge cases that would be painful to test manually
but take milliseconds to verify programmatically.

---

## 12. Phase 2 PR 8 — Habits Data Layer

### Schema migration — why additive only?

When you already have users with data in their Drift databases (schema v2), you can't
just recreate the database — that would delete their data. Drift's `MigrationStrategy`
handles this with version checks:

```dart
onUpgrade: (m, from, to) async {
  if (from < 2) { /* create v2 tables */ }
  if (from < 3) { /* create v3 tables */ }
}
```

A new install runs both blocks (from=1, to=3). An existing v2 user runs only the second
block. Their existing goals/tasks data is untouched. This is called an **additive migration**.

Rule: **never drop a column or table in production code**. Add columns with a default value
instead. Removing data structures breaks existing users.

### Storing List<int> in SQLite

SQLite has no array type. `targetDaysOfWeek: [1, 3, 5]` needs to be stored as something
SQLite understands. Two common approaches:

1. **JSON string**: `"[1,3,5]"` — requires a JSON parser
2. **CSV string**: `"1,3,5"` — simpler, easier to read in the database

We chose CSV. The encode/decode is just two lines:
```dart
static String _encodeDays(List<int> days) => days.join(',');
static List<int> _decodeDays(String encoded) =>
    encoded.isEmpty ? [] : encoded.split(',').map(int.parse).toList();
```

The empty-string check handles daily habits where `targetDaysOfWeek` is `[]`.

### The four model methods — why each one exists

Every `XModel` class has four static methods:

| Method | Direction | Used by |
|---|---|---|
| `fromRow` | DB row → domain entity | Repository reading from local DB |
| `toCompanion` | Domain entity → DB insert | Repository writing to local DB |
| `toRemoteMap` | Domain entity → JSON map | Remote datasource (Supabase upsert) |
| `fromRemoteMap` | JSON map → domain entity | Sync service pulling from Supabase |

The domain entity is always the "center". Everything converts to/from it. The entity itself
has no knowledge of databases or JSON — it's pure Dart.

### Round-trip test — testing the CSV encoding end-to-end

The model test has a special "round-trip via DB" test:
```dart
await db.into(db.habitsTable).insertOnConflictUpdate(HabitModel.toCompanion(habit));
final rows = await db.select(db.habitsTable).get();
final recovered = HabitModel.fromRow(rows.first);
expect(recovered.targetDaysOfWeek, [3, 6]);
```

This proves the CSV encode → SQLite → CSV decode pipeline works correctly, not just the
encode and decode functions in isolation. It uses `NativeDatabase.memory()` — a real SQLite
database that lives in RAM, not on disk. Fast, isolated, no cleanup needed.

### getCompletionsByHabitId — ordering matters

```dart
..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
```

Completions are returned newest-first. This matters for StreakCalculator which starts from
the most recent completion and walks backwards. It also matters for displaying "recent activity"
in the UI — you always want the latest completion at the top.

### Fire-and-forget remote sync

The repository writes to the local database first and returns immediately. The Supabase sync
happens in the background:

```dart
await _local.upsert(HabitModel.toCompanion(habit));  // await — must succeed
unawaited(_pushHabitToRemote(habit));                 // fire-and-forget
return Right(habit);                                  // return without waiting
```

If the remote sync fails (no internet), the row stays with `syncStatus='pendingUpload'`. The
background SyncService picks it up later. The user never sees a spinner waiting for the cloud.

---

## 13. Drift on the Web — SQLite WASM

### Why web is different

On Android and iOS, Flutter can call native SQLite because it's built into the OS. In a
browser, you're running in a JavaScript sandbox — there is no native SQLite. Drift solves
this with two pieces:

1. **sqlite3.wasm** — SQLite compiled to WebAssembly (WASM). WASM is a binary format that
   browsers can run at near-native speed. This is literally the SQLite C code, cross-compiled
   to run in a browser tab.

2. **drift_worker.js** — A JavaScript Web Worker that runs the database operations in a
   background thread. Web Workers are like background threads in the browser. Running SQLite
   on the main thread would freeze the UI.

### How we set it up

**`web/drift_worker.dart`** — A tiny Dart file:
```dart
import 'package:drift/wasm.dart';
void main() {
  WasmDatabase.workerMainForOpen();
}
```
This is compiled to JavaScript at build time: `dart compile js -O2 -o web/drift_worker.js web/drift_worker.dart`

**`app_database.dart`** — `kIsWeb` branch:
```dart
if (kIsWeb) {
  return driftDatabase(
    name: 'jarvis_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
```

**CI workflow** — download and compile at build time (not committed to git):
```yaml
- name: Prepare drift web assets
  run: |
    curl -L -o web/sqlite3.wasm \
      https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm
    dart compile js -O2 -o web/drift_worker.js web/drift_worker.dart
```

### Why not commit sqlite3.wasm?

It's a ~2MB binary file. Binary files don't compress well in git and make the repo slow to
clone. It's also a dependency that should be pinned to a specific version and downloaded
reproducibly, like any other build artifact.

### The gotcha: WasmDatabase.workerMainForOpen()

The correct method is `WasmDatabase.workerMainForOpen()`. NOT `WasmDatabaseWorker.workerMainForOpen()`
(that class doesn't exist). When this was wrong, the `dart compile js` step failed silently
and the browser threw `ArgumentError` when trying to open the database, causing the "something
went wrong" error across all screens.

---

## 14. Gotchas and Hard-Won Lessons

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
| `withOpacity()` deprecation warning | Use `.withValues(alpha: 0.5)` instead | Flutter updated Color API for color space correctness |
| `CardTheme` type error in Flutter 3.x | Use `CardThemeData`, `DialogThemeData`, `BottomAppBarThemeData`, `TabBarThemeData` | Flutter renamed these types to match Material 3 conventions |
| `(_, __)` lint warning | Use `(_, _)` — Dart 3.x wildcard pattern | `unnecessary_underscores` lint flags `__` as redundant |
| AGP version not found on CI | Keep AGP at 8.9.1–8.10.x; do NOT blindly accept Android Studio upgrades | New AGP versions appear on Maven days-weeks after Studio suggests them |
| Kotlin deprecated warning becomes error | Keep Kotlin at ≥ 2.1.0 | Flutter drops support for old Kotlin versions |
| TextEditingController leak/crash | Dispose after dialog closes; use `ConsumerStatefulWidget` for screen-level controllers | Controllers created in `build()` are never disposed |
| Drift web: "something went wrong" on all screens | Add `kIsWeb` branch with `DriftWebOptions` in `_openConnection()`; create `web/drift_worker.dart`; compile to JS at build time | Browser sandbox has no native SQLite; needs WASM + Web Worker |
| `WasmDatabaseWorker` undefined | Use `WasmDatabase.workerMainForOpen()` — the method is on `WasmDatabase`, not a non-existent `WasmDatabaseWorker` class | Drift API: worker entry point is a static method on the database class |
| `dart run drift_flutter:copy_worker` fails | Command doesn't exist in drift_flutter 0.2.x; manually create `web/drift_worker.dart` and compile with `dart compile js` | drift_flutter removed the setup helper commands in 0.2.x |
| `always_use_package_imports` lint in lib/ | All imports inside `lib/` must use `package:jarvis/...` not relative `../` paths | Project has `always_use_package_imports` lint rule enabled |

---

## 15. What to Study Next (Phase 2 UI)

Phase 2 introduces Habits — the most behaviorally complex feature so far. Here's what to
understand before we build it.

### Habits and recurring data patterns

**What makes habits different from tasks?**
A task is completed once and done. A habit is completed repeatedly — daily, weekly, etc.
The data model needs to track both the habit definition (title, frequency) and the completion
history (which days it was done). These are two separate tables with a one-to-many relationship.

```
habits table:
  id, title, frequency('daily'/'weekly'), targetCount, color, userId

habit_completions table:
  id, habitId, date, count
```

**Study**: [One-to-many relationships in SQL](https://www.sqlitetutorial.net/sqlite-foreign-key/)

### Streak calculations

A streak is the number of consecutive days/periods where a habit was completed.
Calculating this from a list of completion records requires:
1. Sort completions by date (newest first)
2. Walk backwards — count consecutive days until you find a gap
3. Handle "today" vs "yesterday" (a habit not yet done today doesn't break the streak)

This is **business logic** — it goes in the domain layer (a use case or entity method),
not in the UI or database layer.

**Study**: Work through how you'd write this algorithm in plain Dart before we build it.

### RRULE (Recurrence Rule)

Our `Task` entity already has a `recurrenceRule` field (a string). In Phase 2 we'll actually
use it. RRULE is an industry standard from the iCalendar spec:

```
RRULE:FREQ=DAILY              → every day
RRULE:FREQ=WEEKLY;BYDAY=MO,WE → every Monday and Wednesday
RRULE:FREQ=MONTHLY;BYMONTHDAY=1 → first of every month
```

We won't parse RRULE ourselves — there are packages like `rrule` for Dart that handle it.

**Study**: [RRULE spec overview](https://icalendar.org/iCalendar-RFC-5545/3-8-5-3-recurrence-rule.html) (just skim to understand the format)

### Local notifications in Flutter

`flutter_local_notifications` package lets you schedule notifications that appear even when
the app is closed. Key concepts:
- **Scheduling**: "Show at 8am every day"
- **Permission requests**: Must ask user to allow notifications (especially on iOS)
- **Notification payload**: Data attached to a notification so tapping it can navigate to the right screen

**Study**: [flutter_local_notifications docs](https://pub.dev/packages/flutter_local_notifications)

### Riverpod `family` modifier

Some providers need a parameter — e.g., "get habit completions for habitId X".
Riverpod's `family` modifier handles this:

```dart
@riverpod
Future<List<HabitCompletion>> habitCompletions(Ref ref, String habitId) async {
  return ref.watch(getHabitCompletionsProvider(habitId)).call();
}
```

We already use this pattern for `projectListProvider(goalId)` and `subtaskListProvider(projectId)`.

**Study**: [Riverpod family modifier](https://riverpod.dev/docs/concepts/modifiers/family)

### Tags and polymorphic junction tables

Tags can be attached to goals, projects, AND tasks — three different entity types. The
cleanest data model is a polymorphic junction table:

```sql
entity_tags:
  entity_id    TEXT  -- the id of the goal/project/task
  entity_type  TEXT  -- 'goal', 'project', or 'task'
  tag_id       TEXT
```

This is more flexible than having separate `goal_tags`, `project_tags`, `task_tags` tables,
but requires careful querying. We'll build this in Phase 2 PR 10.

**Study**: [Polymorphic associations explained](https://medium.com/@veereshbadiger/polymorphic-associations-in-sql-7e43a94b06e1)

---

*This file is updated at the end of every phase/PR. Last updated: Phase 2 PRs 7 + 8 complete (domain + data layers), starting Phase 2 PR 9 (UI).*
