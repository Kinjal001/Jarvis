/// All user-facing strings in one place.
///
/// Keeping strings here (instead of inline in widgets) serves two purposes:
/// 1. Easy to find and update copy without digging through widget code.
/// 2. Ready for internationalization (i18n) in Phase 5 — swap this class
///    for generated ARB strings without touching any widget.
class AppStrings {
  AppStrings._();

  // App identity
  static const appName = 'Jarvis';
  static const appTagline = 'Your personal productivity OS';

  // Generic UI
  static const loading = 'Loading...';
  static const error = 'Something went wrong';
  static const retry = 'Retry';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const delete = 'Delete';
  static const confirm = 'Confirm';

  // Phase 0 placeholder
  static const phase0Label = 'Phase 0 — Foundation';
}
