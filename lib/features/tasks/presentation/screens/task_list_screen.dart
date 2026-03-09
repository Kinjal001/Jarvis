import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/theme/app_colors.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.tasks),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.pending),
              Tab(text: AppStrings.completed),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key('add_task_fab'),
          onPressed: () => _showCreateDialog(context, ref),
          child: const Icon(Icons.add),
        ),
        body: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text(AppStrings.error)),
          data: (tasks) {
            final pending = tasks
                .where((t) => t.status != TaskStatus.completed)
                .toList();
            final done = tasks
                .where((t) => t.status == TaskStatus.completed)
                .toList();

            return TabBarView(
              children: [
                _TaskTab(
                  tasks: pending,
                  emptyMessage: AppStrings.noTasksYet,
                  onAdd: () => _showCreateDialog(context, ref),
                ),
                _TaskTab(tasks: done, emptyMessage: 'No completed tasks yet.'),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Task tab ──────────────────────────────────────────────────────────────────

class _TaskTab extends StatelessWidget {
  const _TaskTab({required this.tasks, required this.emptyMessage, this.onAdd});

  final List<Task> tasks;
  final String emptyMessage;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.cyan,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onAdd != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(AppStrings.newTask),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TaskTile(task: tasks[i]),
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

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
              ? AppColors.emerald.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Cyan left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDone ? AppColors.emerald : AppColors.cyan,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                value: isDone,
                onChanged: (_) {
                  final next = isDone
                      ? TaskStatus.pending
                      : TaskStatus.completed;
                  ref
                      .read(taskListProvider.notifier)
                      .updateStatus(task.id, next);
                },
                title: Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
                activeColor: AppColors.emerald,
                checkColor: Colors.white,
                side: const BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
