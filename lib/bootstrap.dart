import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/app.dart';
import 'package:jarvis/core/config/app_flavor.dart';
import 'package:jarvis/core/config/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared app initialization logic for all three flavors.
///
/// Called from main_dev.dart, main_staging.dart, and main_prod.dart.
/// Order matters:
///   1. WidgetsFlutterBinding — required before any Flutter API is called
///   2. dotenv — loads .env file so all other inits can read config
///   3. Supabase — connects to backend
///   4. Sentry — wraps runApp so it catches errors from launch onwards
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the flavor-specific .env file.
  // The file is bundled as a Flutter asset (declared in pubspec.yaml).
  // On CI, the file is created from GitHub Secrets before the build runs.
  await dotenv.load(fileName: '.env.${flavor.name}');

  // Initialize Supabase. The client becomes available as a singleton via
  // Supabase.instance.client, exposed to the app through supabaseClientProvider.
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );

  // Wrap runApp in Sentry so it captures Flutter framework errors,
  // async errors, and platform errors automatically.
  await SentryFlutter.init(
    (options) {
      options.dsn = AppEnv.sentryDsn;
      options.environment = flavor.name;
      // Sample 100% of transactions in dev/staging so we see everything.
      // In prod, sample 20% to stay within the free tier quota.
      options.tracesSampleRate = flavor == AppFlavor.prod ? 0.2 : 1.0;
      options.debug = flavor == AppFlavor.dev;
    },
    appRunner: () => runApp(
      // ProviderScope is the Riverpod dependency injection container.
      // Every provider in the app is scoped to this.
      const ProviderScope(
        child: JarvisApp(),
      ),
    ),
  );
}
