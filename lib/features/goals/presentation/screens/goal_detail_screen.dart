import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/goals/presentation/providers/goal_providers.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/presentation/providers/project_providers.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  Future<void> _showCreateProjectDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.newProject),
        content: TextField(
          key: const Key('project_title_field'),
          controller: titleController,
          decoration: const InputDecoration(labelText: AppStrings.projectTitle),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              ref
                  .read(projectListProvider(goalId).notifier)
                  .create(title: title, goalId: goalId);
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
    final projectsAsync = ref.watch(projectListProvider(goalId));

    final goal = goalsAsync.valueOrNull
        ?.where((g) => g.id == goalId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(goal?.title ?? AppStrings.goals)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_project_fab'),
        onPressed: () => _showCreateProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (goal != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.intention,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.priority(goal.priority),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppStrings.projects,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text(AppStrings.error)),
              data: (projects) => projects.isEmpty
                  ? const Center(child: Text(AppStrings.noProjectsYet))
                  : ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (ctx, i) =>
                          _ProjectTile(project: projects[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(project.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/projects/${project.id}'),
    );
  }
}
