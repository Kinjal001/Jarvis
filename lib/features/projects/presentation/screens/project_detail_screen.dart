import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/presentation/providers/project_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  Future<void> _showCreateSubtaskDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.newSubtask),
        content: TextField(
          key: const Key('subtask_title_field'),
          controller: titleController,
          decoration: const InputDecoration(labelText: AppStrings.subtaskTitle),
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
                  .read(subtaskListProvider(projectId).notifier)
                  .create(title: title, projectId: projectId);
              Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );

    titleController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtaskListProvider(projectId));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subtasks)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_subtask_fab'),
        onPressed: () => _showCreateSubtaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: subtasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text(AppStrings.error)),
        data: (subtasks) => subtasks.isEmpty
            ? const Center(child: Text(AppStrings.noSubtasksYet))
            : ListView.builder(
                itemCount: subtasks.length,
                itemBuilder: (context, i) =>
                    _SubtaskTile(subtask: subtasks[i], projectId: projectId),
              ),
      ),
    );
  }
}

class _SubtaskTile extends ConsumerWidget {
  const _SubtaskTile({required this.subtask, required this.projectId});

  final Subtask subtask;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = subtask.status == SubtaskStatus.completed;

    return CheckboxListTile(
      title: Text(
        subtask.title,
        style: isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).colorScheme.outline,
              )
            : null,
      ),
      value: isDone,
      onChanged: (_) {
        final newStatus = isDone
            ? SubtaskStatus.pending
            : SubtaskStatus.completed;
        ref
            .read(subtaskListProvider(projectId).notifier)
            .updateStatus(subtask.id, newStatus);
      },
    );
  }
}
