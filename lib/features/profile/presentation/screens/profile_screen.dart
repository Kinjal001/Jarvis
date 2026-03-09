import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/theme/app_colors.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';

/// User profile screen.
///
/// Phase 1.5: shows avatar, email, streak placeholder, sign-out.
/// Phase 2 will add real streak data, weekly summary chart, and XP/level.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text(AppStrings.error)),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Avatar ─────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (user != null && user.email.isNotEmpty)
                        ? user.email[0].toUpperCase()
                        : 'J',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (user != null)
              Center(
                child: Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

            const SizedBox(height: 32),

            // ── Streak placeholder ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0 day streak',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.streakComingInPhase2,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Weekly summary placeholder ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.indigo.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.thisWeek,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.analyticsComingInPhase2,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Sign out ───────────────────────────────────────────────────
            FilledButton(
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).signOut(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cardElevated,
                foregroundColor: AppColors.error,
              ),
              child: const Text(AppStrings.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
