/// Dart extension methods used across the app.
///
/// Keep extensions focused and well-named.
/// Add new ones here as patterns emerge across the codebase.

extension StringExtensions on String {
  /// Capitalizes the first character of the string.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns null if the string is empty, otherwise returns the string.
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
