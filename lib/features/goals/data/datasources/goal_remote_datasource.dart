import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase calls for the goals table.
///
/// Returns raw data — conversion to domain entities happens in the repository.
/// Any exception bubbles up; the repository catches and converts to [Failure].
class GoalRemoteDatasource {
  final SupabaseClient _client;
  const GoalRemoteDatasource(this._client);

  Future<void> upsert(Map<String, dynamic> data) =>
      _client.from('goals').upsert(data);
}
