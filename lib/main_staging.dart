import 'package:jarvis/bootstrap.dart';
import 'package:jarvis/core/config/app_flavor.dart';

/// Staging flavor entry point. Used by CI to produce test builds.
///
/// Run with:
///   flutter run --flavor staging -t lib/main_staging.dart
void main() => bootstrap(AppFlavor.staging);
