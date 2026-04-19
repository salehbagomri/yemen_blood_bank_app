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
  /// ─────────────────────────────────────────────────────
  /// عنوان Supabase عبر Cloudflare Worker (Reverse Proxy)
  /// ─────────────────────────────────────────────────────
  /// 🚨 مهم: بعد إنشاء الـ Worker في Cloudflare، استبدل
  /// الـ defaultValue بالرابط الفعلي للـ Worker.
  ///
  /// مثال: https://mahrah-blood-bank-proxy.saleh-xxx.workers.dev
  /// ─────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mahrah-blood-bank-proxy.bagosaleh.workers.dev',
    // ⬆️ استبدل WORKER_URL_HERE برابط الـ Worker بعد إنشائه
    // مثال: 'https://mahrah-blood-bank-proxy.saleh-abc.workers.dev'
  );

  /// عنوان Supabase الأصلي (للاستخدام الداخلي فقط — محجوب في اليمن)
  static const String supabaseDirectUrl =
      'https://mgeshfxrcdilwjohoniv.supabase.co';

  /// المفتاح العام (Anon Key)
  /// يُقرأ من --dart-define=SUPABASE_ANON_KEY
  /// أو يستخدم القيمة الافتراضية للتطوير
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nZXNoZnhyY2RpbHdqb2hvbml2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NDU5MDEsImV4cCI6MjA4MDAyMTkwMX0.7Ypc4eQWJRU1hfb1TLzG-qhSMQ8rIsE9OOAxATQvaAA',
  );

  /// ملاحظات:
  /// 1. لا تستخدم service_role key في التطبيق أبداً
  /// 2. المفتاح العام (anon key) آمن للاستخدام في التطبيق
  /// 3. الحماية تتم عبر Row Level Security (RLS) في Supabase
  /// 4. في الإنتاج، مرر المفاتيح عبر --dart-define أو --dart-define-from-file
  /// 5. الـ URL الآن يمر عبر Cloudflare Worker لتجاوز حجب supabase.co

  /// التحقق من صحة الإعدادات
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseUrl != 'WORKER_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
}
