# Phase 0 — Setup Checklist

Complete these tasks before we write a single line of Flutter code. Each item is linked to a specific reason.

---

## Step 1 — Install Flutter

Flutter includes Dart, so you only need to install Flutter.

1. Go to https://docs.flutter.dev/get-started/install/windows/mobile
2. Download the Flutter SDK bundle
3. Extract to `C:\flutter` (avoid paths with spaces)
4. Add `C:\flutter\bin` to your Windows PATH:
   - Search "Environment Variables" in Start menu
   - Edit "Path" under User Variables
   - Add `C:\flutter\bin`
5. Open a new terminal and run: `flutter doctor`
6. Fix any issues `flutter doctor` reports. Common ones:
   - Android Studio not found → install from https://developer.android.com/studio
   - Android SDK licenses not accepted → run `flutter doctor --android-licenses`
   - VS Code extension missing → install "Flutter" extension in VS Code (recommended editor)

**Done when:** `flutter doctor` shows all green checkmarks (except iOS — that needs a Mac)

---

## Step 2 — Set Up VS Code (Recommended Editor)

1. Download VS Code: https://code.visualstudio.com/
2. Install these extensions:
   - **Flutter** (by Dart Code) — syntax highlighting, debugging, hot reload
   - **Dart** (by Dart Code) — usually auto-installed with Flutter extension
   - **GitLens** — enhanced git history in editor
   - **Error Lens** — shows errors inline (saves scrolling to Problems tab)
   - **Pubspec Assist** — easy package adding

---

## Step 3 — Create GitHub Repository

1. Go to https://github.com and sign in (create account if needed)
2. Click "New repository"
3. Settings:
   - Name: `jarvis`
   - Visibility: **Private** (you can make it public later)
   - Do NOT initialize with README (we already have files)
   - Do NOT add .gitignore (we already have one)
4. After creating, copy the remote URL (looks like: `https://github.com/YOUR_USERNAME/jarvis.git`)
5. In your terminal at `E:\Projects\Jarvis`:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/jarvis.git
   git branch -M main
   git add .
   git commit -m "chore: initial project foundation and documentation"
   git push -u origin main
   ```
6. Go to GitHub → your repo → Settings → Branches
7. Add branch protection rule for `main` (see `docs/ci-cd.md` for exact settings)

---

## Step 4 — Create Supabase Account

1. Go to https://supabase.com and sign up (GitHub login recommended)
2. Create **3 projects** (free tier allows 2 active — create dev and staging now, add prod later):
   - `jarvis-dev`
   - `jarvis-staging`
3. For each project, go to Settings → API and note down:
   - Project URL (looks like `https://xxxx.supabase.co`)
   - Anon/Public key
4. Save these in a local `.env.dev` and `.env.staging` file (NOT committed to git — already in .gitignore)
5. Also save them as GitHub Secrets (Settings → Secrets → Actions)

---

## Step 5 — Create Sentry Account

1. Go to https://sentry.io and sign up (free tier: 5,000 errors/month)
2. Create a new **Flutter** project named `jarvis`
3. Sentry will give you a DSN (looks like `https://abc123@sentry.io/456`)
4. Save this DSN in your `.env` files and as GitHub Secret `SENTRY_DSN_DEV`

---

## Step 6 — Get Gemini API Key (For Phase 3, but grab it now)

1. Go to https://aistudio.google.com
2. Sign in with Google account
3. Click "Get API Key" → "Create API key"
4. Save it somewhere safe (password manager)
5. Do NOT add this to the Flutter app or any .env file yet — we'll add it to Supabase Edge Function config in Phase 3

---

## Step 7 — Android Device Setup (for testing)

1. On your Android phone: Settings → About Phone → tap "Build Number" 7 times → Developer Options enabled
2. Settings → Developer Options → Enable "USB Debugging"
3. Connect phone to laptop via USB
4. Run `flutter devices` — your phone should appear
5. Run `flutter run` (once Flutter project is created) — app should launch on your phone

---

## Checklist Summary

- [ ] Flutter installed, `flutter doctor` all green
- [ ] VS Code with Flutter extension installed
- [ ] GitHub repo created, initial commit pushed
- [ ] Branch protection on `main` configured
- [ ] Supabase dev + staging projects created, keys saved
- [ ] Sentry project created, DSN saved
- [ ] Gemini API key saved (for later)
- [ ] Android USB debugging enabled

**When all are checked → tell Claude Code you're ready for Phase 0 implementation.**

---

## What Happens Next (Phase 0 Implementation)

Once your setup is complete, Claude Code will:
1. Create the Flutter project with `flutter create`
2. Configure the 3 flavors (dev/staging/prod)
3. Set up the Clean Architecture folder structure
4. Initialize Drift, Supabase, and Sentry
5. Create the GitHub Actions CI pipeline files
6. Write the first passing test
7. Make sure the whole thing builds and CI goes green
