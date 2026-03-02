# Jarvis — CI/CD Pipeline

## Overview

All automation runs on **GitHub Actions** (free tier: 2,000 minutes/month for private repos, unlimited for public).

## Pipeline Triggers

| Trigger | Pipeline | Purpose |
|---|---|---|
| Pull Request opened/updated | `pr.yml` | Quality gate — must pass before merge |
| Merge to `main` | `main.yml` | Staging build + distribution |
| Git tag `v*.*.*` | `release.yml` | Production build + store upload |

## PR Pipeline (`pr.yml`)

Runs on every PR. All steps must pass for merge to be allowed.

```
1. Setup Flutter
2. flutter pub get
3. dart format --check .          (format check — fails if unformatted)
4. flutter analyze                (lint — fails on warnings)
5. flutter test --coverage        (all tests)
6. Check coverage >= 70%          (lcov coverage report)
7. flutter build apk --debug      (Android build check)
8. flutter build web              (Web build check)
```

## Main Branch Pipeline (`main.yml`)

Runs after every merge to `main`.

```
1-8. Everything from PR pipeline, plus:
9.  flutter build apk --flavor staging
10. flutter build web --flavor staging
11. Upload Android APK to Firebase App Distribution (beta testers)
12. Deploy web (staging) to Vercel preview URL
13. Upload Dart source maps to Sentry (for readable stack traces)
```

## Release Pipeline (`release.yml`)

Triggered when a tag like `v1.2.0` is pushed.

```
1.  flutter build appbundle --flavor prod  (Android)
2.  flutter build ipa --flavor prod        (iOS — requires macOS runner)
3.  flutter build web --flavor prod
4.  Upload Android to Play Store internal track (Fastlane)
5.  Upload iOS to App Store TestFlight (Fastlane)
6.  Deploy web to production (Vercel/Netlify)
7.  Create GitHub Release with changelog
8.  Notify Sentry of new release version
```

Note: iOS release requires a macOS GitHub Actions runner and Apple certificates stored as GitHub Secrets.

## GitHub Secrets Required

Set in: GitHub repo → Settings → Secrets and Variables → Actions

| Secret | Used By | What It Is |
|---|---|---|
| `SUPABASE_URL_DEV` | All pipelines | Dev Supabase project URL |
| `SUPABASE_ANON_KEY_DEV` | All pipelines | Dev Supabase anon key |
| `SUPABASE_URL_STAGING` | main.yml | Staging project URL |
| `SUPABASE_ANON_KEY_STAGING` | main.yml | Staging anon key |
| `SUPABASE_URL_PROD` | release.yml | Prod project URL |
| `SUPABASE_ANON_KEY_PROD` | release.yml | Prod anon key |
| `SENTRY_DSN_DEV` | All pipelines | Sentry DSN for dev |
| `SENTRY_DSN_PROD` | release.yml | Sentry DSN for prod |
| `SENTRY_AUTH_TOKEN` | main.yml, release.yml | For source map uploads |
| `FIREBASE_APP_ID` | main.yml | Firebase App Distribution |
| `FIREBASE_TOKEN` | main.yml | Firebase CLI auth |

Secrets for iOS/release (add in Phase 5):
- `APPLE_CERTIFICATES_P12`
- `APPLE_PROVISIONING_PROFILE`
- `APPLE_API_KEY`
- `GOOGLE_PLAY_JSON_KEY`

## Branch Protection Rules (Set on GitHub)

Repository → Settings → Branches → Add rule for `main`:
- [x] Require a pull request before merging
- [x] Require status checks to pass before merging
  - Required checks: `PR Quality Gate`
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

## Versioning

Follow **Semantic Versioning** (`MAJOR.MINOR.PATCH`):
- `PATCH` (1.0.1): Bug fixes, no new features
- `MINOR` (1.1.0): New features, backwards compatible
- `MAJOR` (2.0.0): Breaking changes

Tag format: `v1.2.3`
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Local Pre-commit Checks (Optional but Recommended)

Install `pre-commit` to catch issues before they reach CI:
```bash
# .pre-commit-config.yaml (add to repo root)
repos:
  - repo: local
    hooks:
      - id: flutter-format
        name: Flutter Format
        entry: dart format --set-exit-if-changed .
        language: system
      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
```
