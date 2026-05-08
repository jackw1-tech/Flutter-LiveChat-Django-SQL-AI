/// Supabase is reached only by the Django backend (server-side persistence
/// of the chat transcript). The Flutter client itself never talks to
/// Supabase, so these constants are kept here only as a placeholder if you
/// later add direct realtime subscriptions from the app.
class SupabaseConfig {
  static String get url => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'YOUR_SUPABASE_URL',
      );
  static String get anonKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'YOUR_SUPABASE_ANON_KEY',
      );

  static Future<void> init() async {}
}
