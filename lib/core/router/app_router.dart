import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jarvis/core/widgets/bottom_nav_shell.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/auth/presentation/screens/login_screen.dart';
import 'package:jarvis/features/auth/presentation/screens/signup_screen.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_list_screen.dart';
import 'package:jarvis/features/home/presentation/screens/home_screen.dart';
import 'package:jarvis/features/profile/presentation/screens/profile_screen.dart';
import 'package:jarvis/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:jarvis/features/tasks/presentation/screens/task_list_screen.dart';

part 'app_router.g.dart';

/// Provides the single [GoRouter] instance.
///
/// Route structure:
///   /login, /signup       — auth screens (no bottom nav)
///   /goals/:id            — goal detail (no bottom nav — pushed on top)
///   /projects/:id         — project detail (no bottom nav — pushed on top)
///   ShellRoute            — bottom nav shell wrapping the 4 main tabs:
///     /today              — Today screen (default tab)
///     /goals              — Goals list
///     /tasks              — Tasks list
///     /profile            — Profile
///
/// Detail routes are defined OUTSIDE the ShellRoute so when you push to them
/// (via context.push), go_router renders them on the root navigator — the
/// bottom nav disappears and the back button returns to the previous tab.
///
/// `keepAlive: true` — never recreate the router while the app is running
/// or the navigation stack would be lost.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Seed with whatever auth state we already have (may be loading → null).
  final authState = ValueNotifier<bool>(
    ref.read(authStateChangesProvider).valueOrNull != null,
  );
  ref.onDispose(authState.dispose);

  // Keep the notifier updated whenever auth state changes.
  ref.listen(authStateChangesProvider, (_, next) {
    authState.value = next.valueOrNull != null;
  });

  return GoRouter(
    initialLocation: '/today',
    debugLogDiagnostics: !kReleaseMode,
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuth = authState.value;
      final loc = state.matchedLocation;
      final isOnAuth = loc == '/login' || loc == '/signup';

      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/today';
      return null;
    },
    routes: [
      // ── Auth (no bottom nav) ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ── Detail screens (no bottom nav) ────────────────────────────────────
      // These are outside the ShellRoute so pushing to them from a tab hides
      // the bottom nav and gives a clean full-screen detail view.
      GoRoute(
        path: '/goals/:id',
        name: 'goal-detail',
        builder: (context, state) =>
            GoalDetailScreen(goalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/projects/:id',
        name: 'project-detail',
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),

      // ── Main shell (bottom nav) ───────────────────────────────────────────
      ShellRoute(
        // Pass the current matched location so BottomNavShell can highlight
        // the correct tab without needing a BuildContext lookup.
        builder: (context, state, child) =>
            BottomNavShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/today',
            name: 'today',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/goals',
            name: 'goals',
            builder: (context, state) => const GoalListScreen(),
          ),
          GoRoute(
            path: '/tasks',
            name: 'tasks',
            builder: (context, state) => const TaskListScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
