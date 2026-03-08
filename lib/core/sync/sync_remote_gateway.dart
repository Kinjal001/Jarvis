import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface for the remote sync operations.
///
/// Keeping this thin and abstract makes [SyncService] fully testable
/// without a real Supabase connection.
abstract class SyncRemoteGateway {
  Future<void> upsertGoals(List<Map<String, dynamic>> rows);
  Future<List<Map<String, dynamic>>> fetchGoals(
    String userId, {
    DateTime? since,
  });

  Future<void> upsertProjects(List<Map<String, dynamic>> rows);
  Future<List<Map<String, dynamic>>> fetchProjects(
    String userId, {
    DateTime? since,
  });

  Future<void> upsertSubtasks(List<Map<String, dynamic>> rows);
  Future<List<Map<String, dynamic>>> fetchSubtasks(
    List<String> projectIds, {
    DateTime? since,
  });

  Future<void> upsertTasks(List<Map<String, dynamic>> rows);
  Future<List<Map<String, dynamic>>> fetchTasks(
    String userId, {
    DateTime? since,
  });
}

/// Supabase implementation of [SyncRemoteGateway].
class SupabaseSyncGateway implements SyncRemoteGateway {
  final SupabaseClient _client;
  const SupabaseSyncGateway(this._client);

  @override
  Future<void> upsertGoals(List<Map<String, dynamic>> rows) =>
      _client.from('goals').upsert(rows);

  @override
  Future<List<Map<String, dynamic>>> fetchGoals(
    String userId, {
    DateTime? since,
  }) async {
    final since_ = since?.toUtc().toIso8601String();
    final data = since_ != null
        ? await _client
              .from('goals')
              .select()
              .eq('user_id', userId)
              .gt('updated_at', since_)
        : await _client.from('goals').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> upsertProjects(List<Map<String, dynamic>> rows) =>
      _client.from('projects').upsert(rows);

  @override
  Future<List<Map<String, dynamic>>> fetchProjects(
    String userId, {
    DateTime? since,
  }) async {
    final since_ = since?.toUtc().toIso8601String();
    final data = since_ != null
        ? await _client
              .from('projects')
              .select()
              .eq('user_id', userId)
              .gt('updated_at', since_)
        : await _client.from('projects').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> upsertSubtasks(List<Map<String, dynamic>> rows) =>
      _client.from('subtasks').upsert(rows);

  @override
  Future<List<Map<String, dynamic>>> fetchSubtasks(
    List<String> projectIds, {
    DateTime? since,
  }) async {
    if (projectIds.isEmpty) return [];
    final since_ = since?.toUtc().toIso8601String();
    final data = since_ != null
        ? await _client
              .from('subtasks')
              .select()
              .inFilter('project_id', projectIds)
              .gt('updated_at', since_)
        : await _client
              .from('subtasks')
              .select()
              .inFilter('project_id', projectIds);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> upsertTasks(List<Map<String, dynamic>> rows) =>
      _client.from('tasks').upsert(rows);

  @override
  Future<List<Map<String, dynamic>>> fetchTasks(
    String userId, {
    DateTime? since,
  }) async {
    final since_ = since?.toUtc().toIso8601String();
    final data = since_ != null
        ? await _client
              .from('tasks')
              .select()
              .eq('user_id', userId)
              .gt('updated_at', since_)
        : await _client.from('tasks').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data);
  }
}
