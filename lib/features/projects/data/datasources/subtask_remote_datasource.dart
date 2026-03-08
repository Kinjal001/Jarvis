import 'package:supabase_flutter/supabase_flutter.dart';

class SubtaskRemoteDatasource {
  final SupabaseClient _client;
  const SubtaskRemoteDatasource(this._client);

  Future<void> upsert(Map<String, dynamic> data) =>
      _client.from('subtasks').upsert(data);
}
