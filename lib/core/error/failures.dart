import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Typed failure hierarchy used across all use cases.
///
/// Use cases return [Either<Failure, T>] (from fpdart).
/// The UI pattern-matches on the failure type to show the right message.
///
/// Why not exceptions? Exceptions are invisible in function signatures —
/// callers can forget to handle them. [Failure] forces the caller to deal
/// with both the success and failure cases at compile time.
@freezed
sealed class Failure with _$Failure {
  /// A network request failed (no connection, timeout, etc.)
  const factory Failure.network({required String message}) = NetworkFailure;

  /// A local database operation failed.
  const factory Failure.database({required String message}) = DatabaseFailure;

  /// The server returned an error response.
  const factory Failure.server({required String message, int? statusCode}) =
      ServerFailure;

  /// An unexpected error that doesn't fit the categories above.
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
