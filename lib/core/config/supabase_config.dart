/// Supabase connection settings.
/// HOW TO FILL IN:
/// 1. Supabase project -> Settings -> API
/// 2. Copy "Project URL" -> paste as supabaseUrl
/// 3. Copy "anon public" key -> paste as supabaseAnonKey
/// The anon key is SAFE in the app. Never put the service_role key here.
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://dfzaazwojsgmgnfizabs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmemFhendvanNnbWduZml6YWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwNzgzODYsImV4cCI6MjA5NzY1NDM4Nn0.MKNE-xsJat26pX1Ev00meEpTnOOPWwpgizla6Os7oDc';

  static bool get isConfigured =>
      !supabaseUrl.contains('PASTE_') && !supabaseAnonKey.contains('PASTE_');
}
