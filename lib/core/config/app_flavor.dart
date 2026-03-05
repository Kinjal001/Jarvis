/// The three environments Jarvis runs in.
///
/// - [dev]     Local development. Verbose logging, dev Supabase project.
/// - [staging] CI testing builds. Mimics prod. Staging Supabase project.
/// - [prod]    What users download from the app store.
///
/// The active flavor is set at app launch via the entry point
/// (main_dev.dart / main_staging.dart / main_prod.dart) and never changes
/// at runtime.
enum AppFlavor { dev, staging, prod }
