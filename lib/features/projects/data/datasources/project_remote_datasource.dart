import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectRemoteDatasource {
  final SupabaseClient _client;
  const ProjectRemoteDatasource(this._client);

  Future<void> upsert(Map<String, dynamic> data) =>
      _client.from('projects').upsert(data);
}
