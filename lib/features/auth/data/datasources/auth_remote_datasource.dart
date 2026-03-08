import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase Auth — the only auth datasource (no local table needed;
/// Supabase handles session persistence automatically).
class AuthRemoteDatasource {
  final SupabaseClient _client;
  const AuthRemoteDatasource(this._client);

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _mapUser(response.user!);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return _mapUser(response.user!);
  }

  Future<void> signOut() => _client.auth.signOut();

  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  Stream<AppUser?> get authStateChanges => _client.auth.onAuthStateChange.map(
    (event) =>
        event.session?.user == null ? null : _mapUser(event.session!.user),
  );

  AppUser _mapUser(User user) => AppUser(
    id: user.id,
    email: user.email!,
    displayName: user.userMetadata?['display_name'] as String?,
  );
}
