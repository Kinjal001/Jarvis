import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/core/theme/app_colors.dart';
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtaskListProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.subtasks),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_subtask_fab'),
        onPressed: () => _showCreateSubtaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: subtasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text(AppStrings.error)),
        data: (subtasks) {
          if (subtasks.isEmpty) {
            return _EmptySubtasks(
              onAdd: () => _showCreateSubtaskDialog(context, ref),
            );
          }
          // Show pending first, then completed — Zeigarnik effect
          final pending = subtasks
              .where((s) => s.status == SubtaskStatus.pending)
              .toList();
          final done = subtasks
              .where((s) => s.status == SubtaskStatus.completed)
              .toList();
          final sorted = [...pending, ...done];

          return Column(
            children: [
              // Progress bar at top
              _ProgressHeader(done: done.length, total: subtasks.length),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _SubtaskTile(subtask: sorted[i], projectId: projectId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Progress header ───────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? done / total : 0.0;
    final color = progress >= 1.0 ? AppColors.emerald : AppColors.blue;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$done / $total subtasks',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.cardElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtask tile ──────────────────────────────────────────────────────────────

class _SubtaskTile extends ConsumerWidget {
  const _SubtaskTile({required this.subtask, required this.projectId});

  final Subtask subtask;
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = subtask.status == SubtaskStatus.completed;

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
      child: CheckboxListTile(
        value: isDone,
        onChanged: (_) {
          final next = isDone ? SubtaskStatus.pending : SubtaskStatus.completed;
          ref
              .read(subtaskListProvider(projectId).notifier)
              .updateStatus(subtask.id, next);
        },
        title: Text(
          subtask.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? AppColors.textDisabled : AppColors.textPrimary,
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptySubtasks extends StatelessWidget {
  const _EmptySubtasks({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.blue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: AppColors.blue,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noSubtasksYet,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.newSubtask),
            ),
          ],
        ),
      ),
    );
  }
}
