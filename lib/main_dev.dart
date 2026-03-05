import 'package:jarvis/bootstrap.dart';
import 'package:jarvis/core/config/app_flavor.dart';

/// Dev flavor entry point.
///
/// Run with:
///   flutter run --flavor dev -t lib/main_dev.dart
void main() => bootstrap(AppFlavor.dev);
