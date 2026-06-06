/// إعدادات Supabase
///
/// المفاتيح تُمرر عبر --dart-define وقت البناء
/// أو تُستخدم القيم الافتراضية (للتطوير المحلي فقط)
///
/// طريقة البناء:
/// flutter build apk --release \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxx
///
/// أو استخدم ملف .env.json:
/// flutter build apk --release --dart-define-from-file=.env.json
class SupabaseConfig {
  /// عنوان Supabase (القاعدة الحقيقية)
  /// يُمرَّر عبر --dart-define وقت البناء، أو القيمة الافتراضية للتطوير
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wdvsjpdrlvydoohvvhtx.supabase.co',
  );

  /// المفتاح العام (Anon Key)
  /// يُقرأ من --dart-define=SUPABASE_ANON_KEY
  /// أو يستخدم القيمة الافتراضية للتطوير
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndkdnNqcGRybHZ5ZG9vaHZ2aHR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5MDg2MTEsImV4cCI6MjA5NTQ4NDYxMX0.AFT-aJBoQECUE1f1vFSHooxWebsUgJaXL7BrChm0v_g',
  );

  /// العنوان النشط للاتصال بـ Supabase (مباشر)
  static String get activeSupabaseUrl => supabaseUrl;

  /// التحقق من صحة الإعدادات
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
