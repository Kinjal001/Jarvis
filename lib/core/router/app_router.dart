import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/auth/presentation/screens/login_screen.dart';
import 'package:jarvis/features/auth/presentation/screens/signup_screen.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:jarvis/features/goals/presentation/screens/goal_list_screen.dart';
import 'package:jarvis/features/home/presentation/screens/home_screen.dart';
import 'package:jarvis/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:jarvis/features/tasks/presentation/screens/task_list_screen.dart';

part 'app_router.g.dart';

/// Provides the single [GoRouter] instance.
///
/// `keepAlive: true` — never recreate the router while the app is running
/// or the navigation stack would be lost.
///
/// Auth changes are communicated via a [ValueNotifier<bool>] that acts as
/// go_router's [GoRouter.refreshListenable].  Whenever the notifier fires,
/// the router re-evaluates the [redirect] callback without rebuilding itself.
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
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuth = authState.value;
      final loc = state.matchedLocation;
      final isOnAuth = loc == '/login' || loc == '/signup';

      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/';
      return null;
    },
    routes: [
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
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (context, state) => const GoalListScreen(),
      ),
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
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
    ],
  );
}
