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

**Done when:** CI is green, app builds on Android and Web (dev flavor), and Sentry receives a test event.

**STATUS: COMPLETE** — CI green, Android + Web builds passing, branch protection active.

---

## Phase 1 — Core Loop
**Goal:** Users can create and track projects. The fundamental value proposition works.

### Deliverables
- [x] Auth (sign up, login, logout via Supabase Auth)
- [x] Goal creation and listing
- [x] Project creation under a goal (title, description, deadline, priority)
- [x] Subtask creation under a project
- [x] Task marking (complete/skip/pending)
- [x] Basic home screen (today's tasks + active projects)
- [x] Sync (local Drift ↔ Supabase)
- [ ] Tags (deferred to Phase 2 — polymorphic junction table complexity)
- [x] Unit tests for all use cases
- [ ] Widget tests for key screens (partial — basic tests pass, deeper coverage in Phase 1.5)

**Done when:** A user can sign up, create a goal with projects and subtasks, mark progress, and see it synced on two devices.

**STATUS: COMPLETE** — 4 PRs merged, CI green, tested on Android device.

---

## Phase 1.5 — UI Overhaul
**Goal:** The app looks and feels like something worth using daily. Behavioral design drives consistency.

### Why a separate phase?
Phase 1 shipped a functional but bare-bones UI (white theme, no nav bar, deep nesting). Real-device testing showed the UI discourages daily use. Before adding more features, the presentation layer needs to be rebuilt with intent.

### Design Principles
- **Dark navy-purple theme** — reduces eye strain, feels premium
- **Colorful accent system** — each entity type has a distinct color (not monochrome)
- **Behavioral psychology** — progress bars (goal gradient), streaks (loss aversion), completion rings (variable reward), Today-first layout (implementation intention)
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
Diamond FAB in center (rotated square, violet, elevated above bar).

### Deliverables
- [ ] `lib/core/theme/app_colors.dart` — full color constants
- [ ] `lib/core/theme/app_theme.dart` — Material 3 theme with color scheme
- [ ] `lib/core/widgets/bottom_nav_shell.dart` — ShellRoute scaffold with bottom nav + diamond FAB
- [ ] Router updated — ShellRoute wrapping Today/Goals/Tasks/Profile
- [ ] **Today screen** — greeting, circular completion ring, active goals scroll, today's tasks
- [ ] **Goals screen** — goal cards with gradient border, progress bar per goal
- [ ] **Goal detail / Project screen** — redesigned subtask list
- [ ] **Tasks screen** — tab bar (Pending | Completed), colored card items
- [ ] **Profile screen** (new) — streak counter placeholder, weekly summary placeholder, sign out
- [ ] Auth screens (login/signup) — apply new theme
- [ ] All strings updated in `core/config/strings.dart`
- [ ] Bug fixes merged: back button + TextEditingController crash

### Behavioral Psychology Built In (Phase 1.5 data only)
| Principle | Implementation |
|---|---|
| Goal gradient | Progress bar fills as subtasks complete |
| Variable reward | Checkbox animates + color burst on completion |
| Implementation intention | Today screen: "Here's what you're doing today" |
| Loss aversion | Streak counter visible (placeholder, real in Phase 2) |
| Zeigarnik effect | Incomplete items shown first |
| Progress visibility | Circular ring shows X/Y tasks done today |

**Done when:** App looks colorful and motivating, all screens reachable via bottom nav, no deep nesting, tested on Android device.

---

## Phase 2 — Intelligence
**Goal:** The app feels alive. Users are motivated to return daily.

### Deliverables
- [ ] Tags (create and attach to goals/projects/tasks — deferred from Phase 1)
- [ ] Habits (create, log daily, streak tracking)
- [ ] Dailies (pinned daily must-dos)
- [ ] Recurring tasks (RRULE-based)
- [ ] Analytics dashboard (completion rate, streaks, daily check-in)
- [ ] Progress indicators (% complete on projects)
- [ ] Reminders (local push notifications)
- [ ] Gamification basics (real streak counter, completion badges, XP)
- [ ] Weekly review screen ("You completed 23 tasks this week")

**Done when:** User has a reason to open the app every day, not just when creating tasks.

---

## Phase 3 — AI Planner
**Goal:** The differentiator. Users can describe a vague goal and get a structured plan.

### Deliverables
- [ ] Supabase Edge Function: `ai-plan-project`
- [ ] Gemini API integration (server-side only)
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
- [ ] Full gamification (XP, levels, achievements)
- [ ] Themes (light, dark, AMOLED, custom accent colors)
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
