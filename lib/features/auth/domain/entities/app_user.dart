import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// The authenticated user.
///
/// Named [AppUser] (not User) to avoid collision with Supabase's own User class.
/// Only holds what the app needs — not a raw copy of the Supabase auth object.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
  }) = _AppUser;
}
