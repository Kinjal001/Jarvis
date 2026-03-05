import 'package:jarvis/bootstrap.dart';
import 'package:jarvis/core/config/app_flavor.dart';

/// Production flavor entry point. Used for App Store / Play Store builds.
///
/// Run with:
///   flutter run --flavor prod -t lib/main_prod.dart
void main() => bootstrap(AppFlavor.prod);
