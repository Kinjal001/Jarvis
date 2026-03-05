import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provides the Supabase client to the rest of the app.
///
/// Supabase is initialized once in [bootstrap] before the app runs.
/// This provider just exposes the already-initialized client.
///
/// Usage:
/// ```dart
/// final supabase = ref.watch(supabaseClientProvider);
/// final data = await supabase.from('projects').select();
/// ```
///
/// Note: Never use this provider directly in a feature.
/// Features must go through their repository, which uses this internally.
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
