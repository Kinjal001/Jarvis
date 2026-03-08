import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';

class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final intentionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.newGoal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('goal_title_field'),
              controller: titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.goalTitle,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('goal_intention_field'),
              controller: intentionController,
              decoration: const InputDecoration(
                labelText: AppStrings.goalIntention,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              final intention = intentionController.text.trim();
              if (title.isEmpty || intention.isEmpty) return;
              ref
                  .read(goalListProvider.notifier)
                  .create(title: title, intention: intention);
              Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.goals),
        actions: [
          IconButton(
            key: const Key('sign_out_button'),
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.signOut,
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_goal_fab'),
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            AppStrings.error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (goals) => goals.isEmpty
            ? const Center(child: Text(AppStrings.noGoalsYet))
            : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, i) => _GoalTile(goal: goals[i]),
              ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(goal.title),
      subtitle: Text(goal.intention),
      trailing: _StatusChip(status: goal.status),
      onTap: () => context.push('/goals/${goal.id}'),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GoalStatus.active => Colors.green,
      GoalStatus.completed => Colors.blue,
      GoalStatus.paused => Colors.orange,
      GoalStatus.archived => Colors.grey,
    };
    return Chip(
      label: Text(status.name),
      backgroundColor: color.withAlpha(30),
      labelStyle: TextStyle(color: color, fontSize: 12),
      padding: EdgeInsets.zero,
    );
  }
}
