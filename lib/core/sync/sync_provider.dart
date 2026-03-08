import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/database/database_provider.dart';
import 'package:jarvis/core/supabase/supabase_provider.dart';
import 'package:jarvis/core/sync/sync_remote_gateway.dart';
import 'package:jarvis/core/sync/sync_service.dart';
import 'package:jarvis/features/auth/domain/entities/app_user.dart';
import 'package:jarvis/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_provider.g.dart';

// ── Gateway ───────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
SyncRemoteGateway syncRemoteGateway(Ref ref) {
  return SupabaseSyncGateway(ref.watch(supabaseClientProvider));
}

// ── Service ───────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  return SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(syncRemoteGatewayProvider),
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Keeps the local Drift database in sync with Supabase.
///
/// Triggers a full push + pull cycle:
///   - When the user signs in (auth state transitions null → user).
///   - When the app resumes from the background.
///
/// `keepAlive: true` so the lifecycle observer stays registered for the full
/// app session. Read this in [JarvisApp] to ensure it initialises immediately.
@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier with WidgetsBindingObserver {
  @override
  void build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));

    // Trigger sync when the user signs in (prev null → next user).
    ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider, (prev, next) {
      final wasLoggedOut = prev?.valueOrNull == null;
      final isLoggedIn = next.valueOrNull != null;
      if (wasLoggedOut && isLoggedIn) {
        _runSync(next.valueOrNull!.id);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user != null) _runSync(user.id);
    }
  }

  Future<void> _runSync(String userId) async {
    await ref.read(syncServiceProvider).sync(userId);
  }
}
