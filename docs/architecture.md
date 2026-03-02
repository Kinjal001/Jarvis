# Jarvis — Architecture

## Overview

Jarvis uses **Clean Architecture** with a **feature-first** folder structure. The guiding principle: features are isolated from each other. Adding a new feature means creating a new folder and implementing its three layers — nothing in existing features needs to change.

**Data flow:**
```
UI Widget
  → Riverpod Provider (reads/writes state)
    → Use Case (domain logic, no framework deps)
      → Repository Interface (domain contract)
        → Repository Implementation (data layer)
          ├── Local Datasource (Drift — SQLite)
          └── Remote Datasource (Supabase)
```

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── env.dart              # Reads .env file, exposes typed config
│   │   ├── strings.dart          # All user-facing strings (i18n-ready)
│   │   └── theme.dart            # App theme, colors, typography
│   ├── database/
│   │   ├── app_database.dart     # Drift DB definition
│   │   └── migrations/           # DB migration files
│   ├── error/
│   │   ├── failures.dart         # Typed failure classes
│   │   └── sentry_service.dart   # Sentry wrapper
│   ├── network/
│   │   ├── dio_client.dart       # Dio setup with interceptors
│   │   └── network_info.dart     # Connectivity check
│   ├── router/
│   │   └── app_router.dart       # go_router config, all routes
│   ├── supabase/
│   │   └── supabase_client.dart  # Supabase init
│   └── utils/
│       ├── date_utils.dart
│       └── extensions.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in.dart
│   │   │       ├── sign_out.dart
│   │   │       └── get_current_user.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       ├── widgets/
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── projects/       # Same structure as auth
│   ├── tasks/
│   ├── habits/
│   ├── analytics/
│   ├── ai_planner/
│   └── settings/
│
├── main.dart           # Shared bootstrap (init Sentry, Supabase, Riverpod)
├── main_dev.dart       # Dev flavor entry point
├── main_staging.dart   # Staging flavor entry point
└── main_prod.dart      # Prod flavor entry point

test/
├── unit/
│   └── features/       # Mirrors lib/features structure
├── widget/
│   └── features/
└── integration/
    └── flows/          # Full user journey tests
```

## Layer Responsibilities

### Domain Layer (Pure Dart — no imports from Flutter or packages)
- **Entities:** Plain Dart classes with Freezed. The truth of what a Project, Task, etc. IS.
- **Repository interfaces:** Abstract classes defining what data operations are possible (e.g., `getProjects()`, `createProject()`). No implementation here.
- **Use cases:** Single-responsibility classes. One use case per action. Takes a repository, returns `Either<Failure, T>`.

### Data Layer
- **Models:** Extend domain entities with JSON serialization (from Supabase) and table definitions (for Drift). Never used in domain/presentation directly.
- **Datasources:** Local (Drift queries) and Remote (Supabase calls). Throw exceptions that get caught by the repository.
- **Repository implementations:** Implements the domain interface. Decides whether to use local or remote. Catches datasource exceptions and converts to typed Failures.

### Presentation Layer
- **Providers:** Riverpod AsyncNotifiers/Notifiers. Call use cases, expose state to UI.
- **Screens:** Full-page widgets. Minimal logic — read from providers, dispatch actions.
- **Widgets:** Reusable UI components. Stateless when possible.

## State Management Pattern

```dart
// Provider
@riverpod
class ProjectList extends _$ProjectList {
  @override
  Future<List<Project>> build() async {
    return ref.watch(getProjectsUseCaseProvider).call();
  }

  Future<void> createProject(CreateProjectParams params) async {
    final result = await ref.read(createProjectUseCaseProvider).call(params);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => ref.invalidateSelf(), // triggers rebuild
    );
  }
}
```

## Offline Sync Strategy

1. All writes go to Drift first (immediate, offline-safe)
2. A sync service runs in background when online
3. Sync uploads local changes to Supabase using `updated_at` comparison
4. Conflict resolution: last-write-wins (v1). All entities have `updated_at`.
5. Supabase Realtime pushes remote changes to local Drift

## Error Handling

```dart
// Use case returns Either
Future<Either<Failure, Project>> call(CreateProjectParams params) async {
  try {
    final project = await repository.createProject(params);
    return Right(project);
  } on NetworkFailure catch (e, st) {
    Sentry.captureException(e, stackTrace: st);
    return Left(NetworkFailure(e.message));
  } on DatabaseFailure catch (e, st) {
    Sentry.captureException(e, stackTrace: st);
    return Left(DatabaseFailure(e.message));
  }
}
```

## Navigation

go_router with named routes. All routes defined in `core/router/app_router.dart`.
Supports deep links (e.g., `jarvis://project/123` opens a project directly).
Web URL routing works automatically with go_router.
