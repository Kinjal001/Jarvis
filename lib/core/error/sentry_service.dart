import 'package:sentry_flutter/sentry_flutter.dart';

/// Thin wrapper around Sentry to keep error reporting consistent.
///
/// Always use this class instead of calling [Sentry] directly.
/// This makes it easy to swap Sentry for another service later
/// and ensures we always attach consistent context.
class SentryService {
  SentryService._();

  /// Report an exception with an optional stack trace and extra context.
  ///
  /// Call this in every catch block:
  /// ```dart
  /// } catch (e, st) {
  ///   await SentryService.captureException(e, stackTrace: st);
  ///   return Left(Failure.unknown(message: e.toString()));
  /// }
  /// ```
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: extras != null
          ? (scope) => extras.forEach(scope.setExtra)
          : null,
    );
  }

  /// Report a non-fatal message (e.g., an unexpected but handled state).
  static Future<void> captureMessage(String message) async {
    await Sentry.captureMessage(message);
  }
}
