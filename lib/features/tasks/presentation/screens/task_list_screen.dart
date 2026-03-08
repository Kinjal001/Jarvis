import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/presentation/providers/task_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.newTask),
        content: TextField(
          key: const Key('task_title_field'),
          controller: titleController,
          decoration: const InputDecoration(labelText: AppStrings.taskTitle),
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
              ref.read(taskListProvider.notifier).create(title: title);
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
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tasks)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_task_fab'),
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text(AppStrings.error)),
        data: (tasks) => tasks.isEmpty
            ? const Center(child: Text(AppStrings.noTasksYet))
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) => _TaskTile(task: tasks[i]),
              ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.completed;

    return CheckboxListTile(
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
        ref.read(taskListProvider.notifier).updateStatus(task.id, newStatus);
      },
    );
  }
}
