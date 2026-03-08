import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// Provides the single [AppDatabase] instance to the rest of the app.
///
/// `keepAlive: true` ensures the DB connection is never closed while
/// the app is running. Only disposed when the ProviderScope is unmounted
/// (i.e., app exits).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
