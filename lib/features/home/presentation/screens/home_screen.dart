import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/presentation/providers/task_providers.dart';

/// Phase 1 real home screen.
///
/// Shows two sections:
/// - Due today: tasks whose dueDate is today and status is pending.
/// - Active goals: quick overview with a tap-through to the goal list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(tasksDueTodayProvider);
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.today),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: AppStrings.tasks,
            onPressed: () => context.go('/tasks'),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: AppStrings.goals,
            onPressed: () => context.go('/goals'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Due today ──────────────────────────────────────────────
          Text(
            AppStrings.dueToday,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          todayAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text(AppStrings.error),
            data: (tasks) => tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AppStrings.noTasksDueToday,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                : Column(
                    children: tasks
                        .map((t) => _TodayTaskTile(task: t))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // ── Active goals ───────────────────────────────────────────
          Row(
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
          const SizedBox(height: 8),
          goalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text(AppStrings.error),
            data: (goals) {
              final active = goals
                  .where((g) => g.status.name == 'active')
                  .toList();
              if (active.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.noActiveGoals,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                );
              }
              return Column(
                children: active
                    .take(5)
                    .map(
                      (g) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(g.title),
                        subtitle: Text(g.intention),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/goals/${g.id}'),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayTaskTile extends ConsumerWidget {
  const _TodayTaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.completed;
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        task.title,
        style: isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).colorScheme.outline,
              )
            : null,
      ),
      value: isDone,
      onChanged: (_) {
        final newStatus = isDone ? TaskStatus.pending : TaskStatus.completed;
        ref
            .read(tasksDueTodayProvider.notifier)
            .updateStatus(task.id, newStatus);
      },
    );
  }
}
