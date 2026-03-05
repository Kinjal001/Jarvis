import 'package:jarvis/bootstrap.dart';
import 'package:jarvis/core/config/app_flavor.dart';

/// Default entry point — always uses the dev flavor.
///
/// This file exists for convenience: `flutter run` (without --flavor) works
/// during development. In CI and on devices, the flavor-specific entry
/// points are used instead:
///   flutter run --flavor dev     -t lib/main_dev.dart
///   flutter run --flavor staging -t lib/main_staging.dart
///   flutter run --flavor prod    -t lib/main_prod.dart
void main() => bootstrap(AppFlavor.dev);
