import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:jarvis/core/database/database_provider.dart';
import 'package:jarvis/core/supabase/supabase_provider.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:jarvis/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:jarvis/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:jarvis/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:jarvis/features/goals/domain/entities/goal.dart';
import 'package:jarvis/features/goals/domain/repositories/i_goal_repository.dart';
import 'package:jarvis/features/goals/domain/usecases/archive_goal.dart';
import 'package:jarvis/features/goals/domain/usecases/create_goal.dart';
import 'package:jarvis/features/goals/domain/usecases/get_goals.dart';
import 'package:jarvis/features/goals/domain/usecases/update_goal.dart';

part 'goal_providers.g.dart';

// ── Datasources ──────────────────────────────────────────────────────────────

@riverpod
GoalLocalDatasource goalLocalDatasource(Ref ref) {
  return GoalLocalDatasource(ref.watch(appDatabaseProvider));
}

@riverpod
GoalRemoteDatasource goalRemoteDatasource(Ref ref) {
  return GoalRemoteDatasource(ref.watch(supabaseClientProvider));
}

// ── Repository ────────────────────────────────────────────────────────────────

@riverpod
IGoalRepository goalRepository(Ref ref) {
  return GoalRepositoryImpl(
    ref.watch(goalLocalDatasourceProvider),
    ref.watch(goalRemoteDatasourceProvider),
  );
}

// ── Use cases ─────────────────────────────────────────────────────────────────

@riverpod
GetGoals getGoals(Ref ref) => GetGoals(ref.watch(goalRepositoryProvider));

@riverpod
CreateGoal createGoal(Ref ref) => CreateGoal(ref.watch(goalRepositoryProvider));

@riverpod
UpdateGoal updateGoal(Ref ref) => UpdateGoal(ref.watch(goalRepositoryProvider));

@riverpod
ArchiveGoal archiveGoal(Ref ref) =>
    ArchiveGoal(ref.watch(goalRepositoryProvider));

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class GoalList extends _$GoalList {
  @override
  Future<List<Goal>> build() async {
    final result = await ref.watch(getGoalsProvider).call();
    return result.fold((f) => throw f, (goals) => goals);
  }

  Future<void> create({
    required String title,
    required String intention,
  }) async {
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final goal = Goal(
      id: const Uuid().v4(),
      userId: user.id,
      title: title,
      intention: intention,
      priority: 3,
      status: GoalStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await ref.read(createGoalProvider).call(goal);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> archive(String id) async {
    final result = await ref.read(archiveGoalProvider).call(id);
    result.fold(
      (f) => state = AsyncError(f, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}
