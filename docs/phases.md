# Jarvis — Build Phases

Each phase produces a shippable, usable product. Never start a phase until the previous one is stable and tested.

---

## Phase 0 — Foundation
**Goal:** Zero features, but the entire infrastructure is solid. Every line of feature code written after this runs on proven ground.

### Deliverables
- [x] Flutter project created with 3 flavors (dev/staging/prod)
- [x] Clean Architecture folder structure in place
- [x] Drift local database initialized (empty schema)
- [x] Supabase project created and connected
- [x] Sentry initialized in all flavors
- [x] go_router set up (placeholder home screen)
- [x] GitHub repo created, branch protection on `main`
- [x] GitHub Actions CI pipeline running (lint + test + build)
- [x] `.env.example` committed, actual `.env` files gitignored
- [x] Flutter flavor build scripts working
- [x] Basic widget test passing in CI

**STATUS: COMPLETE** — CI green, Android + Web builds passing, branch protection active.

---

## Phase 1 — Core Loop
**Goal:** Users can create and track goals, projects, tasks. The fundamental value proposition works.

### Deliverables
- [x] Auth (sign up, login, logout via Supabase Auth)
- [x] Goal creation and listing
- [x] Project creation under a goal (title, description, deadline, priority)
- [x] Subtask creation under a project
- [x] Task creation and status toggling (complete/pending)
- [x] Basic home screen (today's tasks + active goals)
- [x] Local-first Drift database (goals, projects, subtasks, tasks tables)
- [x] Sync service (local Drift ↔ Supabase, background push/pull)
- [x] Unit tests for all 21 use cases (38 tests)
- [x] Data layer unit tests (models, datasources, repository impls)
- [ ] Tags — deferred to Phase 2 (polymorphic junction table complexity)

### PR History
| PR | Branch | What |
|---|---|---|
| PR 1 | feature/phase-1-domain | Entities, repo interfaces, 21 use cases, 38 tests |
| PR 2 | feature/phase-1-data | Drift tables, data models, datasources, repo impls, auth |
| PR 3 | feature/phase-1-ui | Screens, Riverpod providers, go_router with auth guard |
| PR 4 | feature/phase-1-sync | SyncService — local ↔ Supabase background sync |

**STATUS: COMPLETE** — 4 PRs merged, CI green, tested on Android device.

---

## Phase 1.5 — UI Overhaul
**Goal:** The app looks and feels like something worth using daily. Behavioral design drives consistency.

### Why a separate phase?
Phase 1 shipped a functional but bare-bones UI (white theme, no nav bar). Real-device testing showed the UI discourages daily use. Before adding more features, the presentation layer needed to be rebuilt with intent.

### Design Principles
- **Dark navy-purple theme** — reduces eye strain, feels premium
- **Colorful accent system** — each entity type has a distinct color (not monochrome)
- **Behavioral psychology** — progress bars (goal gradient), completion rings (variable reward), Today-first layout (implementation intention), incomplete-first sorting (Zeigarnik effect)
- **Bottom navigation** — no nesting, everything reachable in 1 tap
- **Habitica-inspired energy** — colorful, alive, rewarding to interact with

### Color Palette
- Background: `#0D0D1A` | Surface: `#1A1A2E` | Card: `#252540`
- Primary (violet): `#7C3AED` | Primary light: `#A855F7`
- Indigo: `#6366F1` | Blue: `#3B82F6` | Cyan: `#06B6D4`
- Amber/Gold: `#F59E0B` | Pink: `#EC4899` | Emerald: `#10B981`

### Navigation Structure
```
Bottom Nav: [ Today ] [ Goals ] [ ◆ Add ] [ Tasks ] [ Profile ]
```
Diamond FAB in center (rotated square, violet). Detail routes pushed outside shell (back button, no bottom nav on detail screens).

### Deliverables
- [x] `lib/core/theme/app_colors.dart` — full color constants
- [x] `lib/core/theme/app_theme.dart` — Material 3 dark theme with full ColorScheme
- [x] `lib/core/widgets/bottom_nav_shell.dart` — ShellRoute scaffold with bottom nav + diamond FAB
- [x] Router updated — ShellRoute wrapping Today/Goals/Tasks/Profile; detail routes outside shell
- [x] **Today screen** — greeting, circular completion ring, active goals scroll, today's tasks
- [x] **Goals screen** — goal cards with gradient left accent bar, status pills
- [x] **Goal detail screen** — gradient border intention header, project cards
- [x] **Project detail screen** — progress header (X/Y + %), Zeigarnik-sorted subtask list
- [x] **Tasks screen** — Pending | Completed tab split, task cards with cyan/emerald accent
- [x] **Profile screen** (new) — gradient avatar, streak placeholder, sign out
- [x] Auth screens (login/signup) — gradient J logo, dark inputs
- [x] All strings in `core/config/strings.dart` (no hardcoded UI text)
- [x] Bug fix: back button crash + TextEditingController dispose crash

### PR History
| PR | Branch | What |
|---|---|---|
| Fix | fix/navigation-and-controller-crash | Back button + TextEditingController dispose crash |
| PR 5 | feature/phase-1-5-theme | AppTheme, AppColors, BottomNavShell, ProfileScreen, router |
| PR 6 | feature/phase-1-5-screens | All 7 screens redesigned with behavioral design patterns |

**STATUS: COMPLETE** — All PRs merged, CI green, AGP 8.9.1 + Kotlin 2.1.0 confirmed working.

---

## Phase 2 — Intelligence
**Goal:** The app feels alive. Users are motivated to return daily. Data gives insight into patterns.

### Core Idea
Phase 1 + 1.5 gives the skeleton and skin. Phase 2 gives the heartbeat — habits, streaks, and analytics that make opening the app every day feel purposeful and rewarding.

### Deliverables

**Habits system**
- [x] `Habit` entity: title, frequency (daily/weekly), target count per period, colorHex, active status
- [x] `HabitCompletion` entity: habitId, completedAt, optional note
- [x] Drift tables: `habits`, `habit_completions` (schema v3)
- [ ] Supabase tables: same schema (add manually in Supabase dashboard)
- [x] Use cases: CreateHabit, UpdateHabit, GetHabits, LogHabitCompletion, GetHabitCompletions, ArchiveHabit, DeleteHabitCompletion
- [ ] Habits section on Today screen — daily check-in
- [x] Streak calculation: `StreakCalculator` — currentStreak, longestStreak, isCompletedToday

**Streak system**
- [ ] Real streak counter on Profile screen (currently placeholder)
- [x] Streak calculation: `currentStreak`, `longestStreak` derived from HabitCompletion data
- [ ] Loss aversion trigger: show streak count prominently, warn when about to break

**Analytics**
- [ ] Weekly summary screen: "You completed X tasks, Y habits, Z% of subtasks this week"
- [ ] Completion trend: simple bar chart (7-day, 30-day)
- [ ] Goal progress: % of subtasks done per active goal
- [ ] Profile screen upgraded with real data (was all placeholders)

**Tags (deferred from Phase 1)**
- [ ] `Tag` entity: id, userId, label, color
- [ ] Junction table: `entity_tags` (entityId, entityType, tagId) — polymorphic
- [ ] Attach/detach tags on goals, projects, tasks
- [ ] Filter by tag on Goals and Tasks screens

**Recurring tasks**
- [ ] RRULE-based recurrence on Task entity (field already in data model)
- [ ] Auto-generate next occurrence on completion
- [ ] Show recurring indicator on task cards

**Local notifications**
- [ ] `flutter_local_notifications` package
- [ ] Daily reminder: "You have X tasks due today" (morning push)
- [ ] Streak reminder: "Don't break your streak!" (evening push if no habit logged)
- [ ] Permission request flow

### PR Plan (4 PRs)
| PR | Branch | Status | What |
|---|---|---|---|
| PR 7 | feature/phase-2-habits-domain | **MERGED** | Habit + HabitCompletion entities, interfaces, use cases, StreakCalculator (31 tests) |
| PR 8 | feature/phase-2-habits-data | **IN REVIEW** | Drift schema v3, models, datasources, HabitRepositoryImpl (37 tests) |
| PR 9 | feature/phase-2-habits-ui | pending | Habits section on Today, streaks on Profile, analytics cards |
| PR 10 | feature/phase-2-tags | pending | Tags entity, junction table, attach UI, filter chips |

*Recurring tasks and notifications may be bundled into PR 9 or split further depending on scope.*

### PR 7 — Habits Domain (MERGED)
- `HabitFrequency` enum: `daily`, `weekly`
- `Habit` Freezed entity: id, userId, title, description, frequency, targetDaysOfWeek, targetCount, colorHex, isActive, createdAt, updatedAt
- `HabitCompletion` Freezed entity: id, habitId, userId, completedAt, note
- `IHabitRepository` interface: 7 methods (getHabits, createHabit, updateHabit, archiveHabit, logCompletion, getCompletions, deleteCompletion)
- 7 use cases in `habit_usecases.dart` (all following standard constructor/call pattern)
- `StreakCalculator` — pure static class: `currentStreak`, `longestStreak`, `isCompletedToday`
  - "Today rule": if not completed today, streak still alive if yesterday was completed
- 31 tests (14 use case + 17 streak calculator)

### PR 8 — Habits Data Layer (IN REVIEW)
- `HabitsTable` + `HabitCompletionsTable` — Drift tables with `syncStatus` column
- `AppDatabase` bumped to schemaVersion 3 with additive v2→v3 migration
- `targetDaysOfWeek` stored as CSV string in SQLite (e.g. `"1,3,5"`) — no TypeConverter needed
- `HabitModel` + `HabitCompletionModel` — fromRow/toCompanion/toRemoteMap/fromRemoteMap
- `HabitLocalDatasource` — full CRUD + archive + markSynced; completions ordered newest-first
- `HabitRemoteDatasource` — Supabase upsert for habits + completions, delete for completions
- `HabitRepositoryImpl` — local-first, fire-and-forget remote sync (same pattern as tasks)
- 37 tests (model mapping, CSV round-trip via DB, datasource CRUD, repo success/failure)

**Done when:** User has a reason to open the app every day — habits to check off, streak to protect, weekly progress visible.

---

## Phase 3 — AI Planner
**Goal:** The differentiator. Users can describe a vague goal and get a structured plan.

### Deliverables
- [ ] Supabase Edge Function: `ai-plan-project`
- [ ] Gemini API integration (server-side only — key never in app binary)
- [ ] AI Planner screen: user describes goal, gets structured project + subtasks
- [ ] User can accept/edit AI-generated plan before saving
- [ ] AI chat for task guidance ("What should I do today?")
- [ ] AISession history stored and viewable
- [ ] Resource suggestions (AI recommends learning resources for learning goals)

**Done when:** A user can type "Learn basics of ML in 15 days for an exam" and get a day-by-day plan with resources, which they can save as a project.

---

## Phase 4 — Power Features
**Goal:** Power users have everything they need. App becomes the single source of truth.

### Deliverables
- [ ] Time blocking (drag tasks onto a day/time view)
- [ ] Calendar view (week and month views of time blocks)
- [ ] Obsidian integration (open Obsidian vault path from project)
- [ ] Dependency tracking (Task B blocked until Task A done)
- [ ] Focus mode (hide everything except today's items)
- [ ] Energy/context tags ("needs focus", "15 min task", "anywhere")
- [ ] Export data (JSON, CSV)

**Done when:** A power user can manage their entire work + personal life from Jarvis.

---

## Phase 5 — Polish
**Goal:** App is ready for others to use. Feels premium, not like a side project.

### Deliverables
- [ ] Full gamification (XP, levels, achievements — current streak/XP is placeholder)
- [ ] Themes (light, dark, AMOLED, custom accent colors)
- [ ] Checkbox animations (color burst on completion — currently instant)
- [ ] Home screen widgets (Android + iOS)
- [ ] Onboarding flow for new users
- [ ] App Store / Play Store submission
- [ ] PostHog analytics events for key actions
- [ ] Performance audit (< 2s load time, 60fps animations)
- [ ] Accessibility (screen reader support, contrast ratios)
- [ ] i18n setup (strings ready for translation)

**Done when:** Someone who doesn't know you built it would pay for it.

---

## Future (Post-Phase 5)
Ideas to revisit when scaling:
- Team/shared projects
- Calendar integrations (Google Calendar, Outlook)
- Desktop native menus (macOS menu bar widget)
- Web clipper browser extension
- Custom AI model (fine-tuned on productivity patterns)
- API for third-party integrations
