import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:jarvis/core/database/database_provider.dart';
import 'package:jarvis/core/supabase/supabase_provider.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:jarvis/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:jarvis/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:jarvis/features/tasks/domain/entities/task.dart';
import 'package:jarvis/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:jarvis/features/tasks/domain/usecases/create_task.dart';
import 'package:jarvis/features/tasks/domain/usecases/get_tasks.dart';
import 'package:jarvis/features/tasks/domain/usecases/get_tasks_due_today.dart';
import 'package:jarvis/features/tasks/domain/usecases/update_task_status.dart';

part 'task_providers.g.dart';

// ── Datasources ───────────────────────────────────────────────────────────────

@riverpod
TaskLocalDatasource taskLocalDatasource(Ref ref) {
  return TaskLocalDatasource(ref.watch(appDatabaseProvider));
}

@riverpod
TaskRemoteDatasource taskRemoteDatasource(Ref ref) {
  return TaskRemoteDatasource(ref.watch(supabaseClientProvider));
}

// ── Repository ────────────────────────────────────────────────────────────────

@riverpod
ITaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImpl(
    ref.watch(taskLocalDatasourceProvider),
    ref.watch(taskRemoteDatasourceProvider),
  );
}

// ── Use cases ─────────────────────────────────────────────────────────────────

@riverpod
GetTasks getTasks(Ref ref) => GetTasks(ref.watch(taskRepositoryProvider));

@riverpod
GetTasksDueToday getTasksDueToday(Ref ref) =>
    GetTasksDueToday(ref.watch(taskRepositoryProvider));

@riverpod
CreateTask createTask(Ref ref) => CreateTask(ref.watch(taskRepositoryProvider));

@riverpod
UpdateTaskStatus updateTaskStatus(Ref ref) =>
    UpdateTaskStatus(ref.watch(taskRepositoryProvider));

// ── All-tasks notifier ────────────────────────────────────────────────────────

@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    final result = await ref.watch(getTasksProvider).call();
    return result.fold((f) => throw f, (tasks) => tasks);
  }

  Future<void> create({required String title}) async {
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final task = Task(
      id: const Uuid().v4(),
      userId: user.id,
      title: title,
      priority: 3,
      status: TaskStatus.pending,
      isRecurring: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await ref.read(createTaskProvider).call(task);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    final result = await ref.read(updateTaskStatusProvider).call(id, status);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

// ── Due-today notifier ────────────────────────────────────────────────────────

@riverpod
class TasksDueToday extends _$TasksDueToday {
  @override
  Future<List<Task>> build() async {
    final result = await ref.watch(getTasksDueTodayProvider).call();
    return result.fold((f) => throw f, (tasks) => tasks);
  }

  Future<void> updateStatus(String id, TaskStatus status) async {
    final result = await ref.read(updateTaskStatusProvider).call(id, status);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}
