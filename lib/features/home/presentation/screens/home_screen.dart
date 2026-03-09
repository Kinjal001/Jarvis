import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/theme/app_colors.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/presentation/providers/task_providers.dart';

/// Today screen — the first tab of the bottom nav.
///
/// Behavioral psychology built in:
///   - Completion ring: "goal gradient" effect — watching the ring fill is
///     intrinsically motivating (the closer to 100%, the stronger the pull)
///   - Greeting + date: anchors the user in today, not a vague backlog
///   - Active goals scroll: "Zeigarnik effect" — incomplete goals stay visible
///   - Tasks first: "implementation intention" — shows exactly what to do now
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  String _formattedDate() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(tasksDueTodayProvider);
    final goalsAsync = ref.watch(goalListProvider);
    final userAsync = ref.watch(authStateChangesProvider);

    final tasks = todayAsync.valueOrNull ?? [];
    final done = tasks.where((t) => t.status == TaskStatus.completed).length;
    final total = tasks.length;
    final progress = total > 0 ? done / total : 0.0;

    final activeGoals = (goalsAsync.valueOrNull ?? [])
        .where((g) => g.status == GoalStatus.active)
        .toList();

    final userEmail = userAsync.valueOrNull?.email ?? '';
    final displayName = userEmail.isNotEmpty
        ? userEmail.split('@').first
        : 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()}, $displayName ✨',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formattedDate(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Completion ring ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    // Ring
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 7,
                              backgroundColor: AppColors.cardElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? AppColors.emerald
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            total == 0 ? '–' : '$done/$total',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress >= 1.0 && total > 0
                                ? AppStrings.allDoneToday
                                : '$done ${AppStrings.tasksDoneToday}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: progress >= 1.0 && total > 0
                                      ? AppColors.emerald
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (total > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: AppColors.cardElevated,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0
                                      ? AppColors.emerald
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Active goals horizontal scroll ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.activeGoals,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go('/goals'),
                    child: const Text(AppStrings.viewAll),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: activeGoals.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Text(
                          AppStrings.noGoalsActiveYet,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      itemCount: activeGoals.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) =>
                          _GoalCard(goal: activeGoals[i]),
                    ),
            ),
          ),

          // ── Today's tasks ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text(
                AppStrings.dueToday,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          if (todayAsync.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tasks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.nothingScheduledToday,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _TodayTaskTile(task: tasks[i]),
              ),
            ),

          // Bottom padding — accounts for bottom nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Goal card (horizontal scroll) ────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/goals/${goal.id}'),
      child: Container(
        width: 160,
        // Gradient border trick: outer gradient container + inner solid container
        decoration: BoxDecoration(
          gradient: AppColors.goalBorderGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.5),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.pink, size: 18),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                goal.intention,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today task tile ───────────────────────────────────────────────────────────

class _TodayTaskTile extends ConsumerWidget {
  const _TodayTaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppColors.emerald.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: CheckboxListTile(
        value: isDone,
        onChanged: (_) {
          final next = isDone ? TaskStatus.pending : TaskStatus.completed;
          ref.read(tasksDueTodayProvider.notifier).updateStatus(task.id, next);
        },
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? AppColors.textDisabled : AppColors.textPrimary,
          ),
        ),
        secondary: Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? AppColors.emerald : AppColors.cyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        activeColor: AppColors.emerald,
        checkColor: Colors.white,
        side: const BorderSide(color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
