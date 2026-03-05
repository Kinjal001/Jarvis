import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/features/home/presentation/screens/home_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// All app routes defined in one place.
///
/// Uses go_router for:
/// - URL-based routing (works on web automatically)
/// - Deep linking (e.g., jarvis://project/123)
/// - Named routes (type-safe navigation)
///
/// Add new routes here as features are built. Never use Navigator.push
/// directly in the app — always go through go_router.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Shows route transitions in debug console
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // Routes will be added here as features are built:
      // Phase 1: /auth/login, /auth/signup, /goals, /projects/:id
      // Phase 2: /habits, /analytics
      // Phase 3: /ai-planner
    ],
  );
}
