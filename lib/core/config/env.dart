import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jarvis/core/config/app_flavor.dart';

/// Typed access to environment variables loaded from the .env file.
///
/// All values are read from [dotenv] which is loaded during [bootstrap].
/// Never access dotenv directly outside of this class.
class AppEnv {
  AppEnv._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '0.0.1';

  static AppFlavor get flavor {
    final env = dotenv.env['APP_ENV'] ?? 'dev';
    return AppFlavor.values.firstWhere(
      (f) => f.name == env,
      orElse: () => AppFlavor.dev,
    );
  }
}
