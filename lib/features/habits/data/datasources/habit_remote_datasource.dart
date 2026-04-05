import 'package:supabase_flutter/supabase_flutter.dart';

class HabitRemoteDatasource {
  final SupabaseClient _client;
  const HabitRemoteDatasource(this._client);

  Future<void> upsertHabit(Map<String, dynamic> data) =>
      _client.from('habits').upsert(data);

  Future<void> upsertCompletion(Map<String, dynamic> data) =>
      _client.from('habit_completions').upsert(data);

  Future<void> deleteCompletion(String id) =>
      _client.from('habit_completions').delete().eq('id', id);
}
