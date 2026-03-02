# Jarvis — Claude Code Project Context

## Project Overview

**Jarvis** is a cross-platform personal productivity OS — a unified app for managing projects, goals, habits, tasks, and daily life. It replaces the need for multiple apps (Notion, Todoist, Habitica, Obsidian) with one cohesive experience, enhanced by AI-powered planning.

**Target platforms:** Android, iOS, macOS, Windows, iPadOS, Web (browser)
**Developer:** Engineering student, learning software development alongside building this project.
**Philosophy:** Production-grade from day one. Flexible architecture. Never rewrite, always extend.

---

## Current Phase

**Phase 0 — Foundation** (in progress)
See `docs/phases.md` for the full roadmap.

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| UI Framework | Flutter 3.x | One codebase for all platforms |
| State Management | Riverpod 2.x | Type-safe, testable, async-first |
| Navigation | go_router | URL-based routing, deep links |
| Local Database | Drift | SQL-based, reactive, all platforms |
| Remote Backend | Supabase | Auth, Postgres, Realtime, Storage, Edge Functions |
| HTTP Client | Dio | Interceptors, retry logic |
| Data Models | Freezed + json_serializable | Immutable, pattern matching |
| Error Monitoring | Sentry | Crashes, performance, breadcrumbs |
| Analytics | PostHog | Usage funnels, GDPR-friendly, free |
| CI/CD | GitHub Actions | Lint, test, build, deploy |
| Environment Config | flutter_dotenv + flavors | dev / staging / prod |

---

## Architecture

**Pattern:** Clean Architecture — Domain / Data / Presentation
**Structure:** Feature-first (one folder per feature, each with its own 3 layers)
**Principle:** Local-first, cloud-synced. App works fully offline via Drift. Supabase syncs when online.

```
lib/
├── core/           # App-wide infrastructure (DB, network, router, error, config)
├── features/       # One folder per feature
│   ├── auth/
│   ├── projects/
│   ├── tasks/
│   ├── habits/
│   ├── analytics/
│   ├── ai_planner/
│   └── settings/
└── main.dart
```

Each feature follows:
```
feature/
├── data/           # Datasources (local Drift + remote Supabase), repository impl
├── domain/         # Entities, repository interfaces, use cases (pure Dart)
└── presentation/   # Screens, widgets, Riverpod providers
```

Full details: `docs/architecture.md`
Data model: `docs/data-model.md`

---

## Environments

Three Flutter flavors:
- `dev` — local development, verbose logging, dev Supabase project
- `staging` — CI testing builds, staging Supabase project
- `prod` — App Store / Play Store builds

Run with: `flutter run --flavor dev -t lib/main_dev.dart`

Config files: `.env.dev`, `.env.staging`, `.env.prod` — **never committed to git**
Example template: `.env.example`

---

## Git Workflow

**Branch strategy:** Trunk-based development
- `main` — always deployable, protected (CI must pass, no direct push)
- `feature/<name>` — new features
- `fix/<name>` — bug fixes
- `chore/<name>` — maintenance, dependency updates

**Commit convention:** Conventional Commits
```
feat: add habit streak tracker
fix: correct timezone handling in reminders
chore: upgrade flutter to 3.27
test: add unit tests for recurrence rule engine
docs: update data model for subtasks
```

**PR rules:**
- CI must pass before merge
- Description must explain what and why
- Link to relevant issue if one exists

---

## Coding Conventions

- **No business logic in widgets.** Widgets call providers, providers call use cases.
- **No raw Supabase calls in features.** Always go through a repository.
- **No hardcoded strings** in UI — all user-facing text goes in `core/config/strings.dart` (prep for i18n later).
- **Error handling:** Every async use case returns `Either<Failure, T>` (using `fpdart` package). Never throw raw exceptions into UI.
- **Immutable models:** Always use `Freezed`. Never mutate state directly.
- **Test coverage target:** 70% minimum, enforced in CI.
- **Sentry:** Every caught exception calls `Sentry.captureException()` with context.

---

## Testing Strategy

| Type | Tool | Location | What |
|---|---|---|---|
| Unit | `flutter_test` | `test/unit/` | Use cases, domain logic, parsers |
| Widget | `flutter_test` | `test/widget/` | Individual widget rendering |
| Integration | `integration_test` | `test/integration/` | Full user flows |
| Mocking | `mocktail` | All test layers | Mock repositories and datasources |

Run all tests: `flutter test --coverage`

---

## CI/CD Pipeline

Defined in `.github/workflows/`. See `docs/ci-cd.md` for details.

- **On PR:** lint → test → coverage check → build check
- **On merge to main:** above + staging build + Firebase App Distribution upload + Sentry source map upload
- **On release tag:** prod build → Play Store (Fastlane) → App Store (Fastlane) → Web deploy

---

## Key External Services

| Service | Purpose | Free Tier |
|---|---|---|
| Supabase | Backend (DB, auth, realtime, storage) | 500MB DB, 2 projects |
| Sentry | Error monitoring | 5K errors/month |
| PostHog | Product analytics | 1M events/month |
| Firebase App Distribution | Beta builds | Free |
| GitHub Actions | CI/CD | 2000 min/month free |
| Gemini API | AI project planner | Free tier available |

---

## Important Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — project context for Claude Code |
| `docs/architecture.md` | Detailed architecture decisions |
| `docs/data-model.md` | Entity definitions and DB schema |
| `docs/phases.md` | Build phases and feature roadmap |
| `docs/phase-0-checklist.md` | User setup checklist (accounts, tools) |
| `docs/ci-cd.md` | CI/CD pipeline documentation |
| `.env.example` | Environment variable template |
| `.github/workflows/` | GitHub Actions pipeline definitions |

---

## AI Integration Notes

- AI API keys are **never in the Flutter app binary**. All AI calls go through Supabase Edge Functions.
- Phase 3 feature. Use Gemini API (free tier) initially. Swap to Claude API later if needed.
- AI responses for project planning are stored in `AISession` table for re-use and history.

---

## User Context

- Windows laptop + Android phone (primary development targets initially)
- Engineering student — learning while building
- Wants to understand every decision, not just copy-paste
- Prefers to be advised when a workflow/practice upgrade is needed
- Zero budget currently — all free tiers only
- Plans to scale later — architecture must support it without rewrites

---

## How to Work With Claude Code

When starting a new session, Claude will read this file automatically for context. Always:
1. Check `docs/phases.md` to confirm current phase before suggesting work
2. Follow the conventions above — never deviate without discussing first
3. Explain decisions as you make them — the developer is learning
4. Flag any security issues, anti-patterns, or tech debt immediately
5. Keep this file updated as major decisions are made
