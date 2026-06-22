/// Supabase connection settings.
/// HOW TO FILL IN:
/// 1. Supabase project -> Settings -> API
/// 2. Copy "Project URL" -> paste as supabaseUrl
/// 3. Copy "anon public" key -> paste as supabaseAnonKey
/// The anon key is SAFE in the app. Never put the service_role key here.
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'PASTE_YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'PASTE_YOUR_ANON_KEY_HERE';

  static bool get isConfigured =>
      !supabaseUrl.contains('PASTE_') && !supabaseAnonKey.contains('PASTE_');
}
