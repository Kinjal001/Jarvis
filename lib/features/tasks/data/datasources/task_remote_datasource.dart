import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRemoteDatasource {
  final SupabaseClient _client;
  const TaskRemoteDatasource(this._client);

  Future<void> upsert(Map<String, dynamic> data) =>
      _client.from('tasks').upsert(data);
}
