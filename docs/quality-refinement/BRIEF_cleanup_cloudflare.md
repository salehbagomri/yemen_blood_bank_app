# 📓 مذكّرة تنفيذ — حذف إعداد Cloudflare Worker الميت + توثيق خطة طوارئ الحجب

> **موجَّهة إلى:** وكيل الكود (المنفِّذ).
> **المخطِّط:** Claude.
> **سياق:** بند مرتبط بالقيود المعروفة (بديل لـ Rate Limiting المؤجَّل).

---

## 🎯 السياق والقرار

**الحقائق المؤكَّدة:**
1. قاعدة البيانات الحقيقية النشطة: `https://wdvsjpdrlvydoohvvhtx.supabase.co` (مؤكَّد من صاحب المشروع).
2. صاحب المشروع **لم ينشر أي Worker على Cloudflare فعلياً** — الكود مكتوب فقط، غير منشور.
3. `cloudflare-worker/worker.js` يشير لقاعدة **قديمة خاطئة** (`mgeshfxrcdilwjohoniv` — مشروع المهرة السابق).
4. `useCloudflareWorker = false` (الإعداد معطّل — التطبيق يتصل مباشرة بـ Supabase).
5. حجب supabase.co في اليمن كان **مؤقتاً (8 أيام) وانحلّ في 10 فبراير 2026** (مصدر Supabase الرسمي). غير نشط حالياً.

**الخلاصة:** إعداد الـ Worker كله **كود ميت مضلّل** (غير منشور + قاعدة خاطئة + معطّل) — مثل MainActivity الشبح. يُحذف بالكامل، مع توثيق الفكرة كخطة طوارئ إن عاد الحجب.

---

## 🧩 الأنماط المحمية

- لا تلمس `wdvsjpdrlvydoohvvhtx` (القاعدة الحقيقية) أو `supabaseAnonKey`.
- `supabaseDirectUrl` (القاعدة الحقيقية) يصبح هو المصدر الوحيد للاتصال.
- لا إيموجي في كود Dart. توثيق SQL/خطة في md فقط.
- بعد الحذف: `flutter analyze` = 0 (لا كسر).

---

## 📋 المهام

### المهمة 1 — تبسيط supabase_config.dart

**المشكلة:** الملف يحتوي منطق Worker معطّلاً + URL خاطئ في `supabaseUrl`.

**الحل:** احذف منطق الـ Worker، واجعل الاتصال مباشراً بالقاعدة الحقيقية:

```dart
class SupabaseConfig {
  /// عنوان Supabase (القاعدة الحقيقية)
  /// يُمرَّر عبر --dart-define وقت البناء، أو القيمة الافتراضية للتطوير
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wdvsjpdrlvydoohvvhtx.supabase.co',
  );

  /// المفتاح العام (anon) — آمن بطبيعته، الحماية على RLS
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGci...', // (أبقِ القيمة الحالية كما هي)
  );

  /// العنوان النشط (مباشر — لا Worker)
  static String get activeSupabaseUrl => supabaseUrl;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
```

**احذف:** `supabaseDirectUrl` المنفصل، `useCloudflareWorker`, ومنطق الـ ternary في `activeSupabaseUrl`. (الآن `activeSupabaseUrl` = `supabaseUrl` مباشرة.)

> ⚠️ **تحقّق:** `connectivity_service.dart` يستخدم `SupabaseConfig.activeSupabaseUrl` — تأكّد أنه لا يزال يعمل بعد التبسيط (الـ getter يبقى موجوداً، فقط يُرجع القيمة المباشرة).

---

### المهمة 2 — حذف مجلد cloudflare-worker

```
git rm -r cloudflare-worker/
```
(الكود ميت، غير منشور، يشير لقاعدة خاطئة.)

---

### المهمة 3 — توثيق خطة الطوارئ (في handoff + القيود المعروفة)

أضف في `yemen_blood_bank_handoff.md` (قسم البنية) وفي «القيود المعروفة» بـ`PROJECT_STATUS.md`:

```
## خطة طوارئ: حجب Supabase في اليمن
حجب supabase.co حدث مؤقتاً في اليمن (8 أيام، انحلّ 10 فبراير 2026). اليمن بيئة
رقابية، فقد يتكرّر. التطبيق حالياً يتصل مباشرة بـ wdvsjpdrlvydoohvvhtx.supabase.co.

إن عاد الحجب:
1. أنشئ Cloudflare Worker جديداً (reverse proxy) يشير للقاعدة الصحيحة:
   const SUPABASE_URL = 'https://wdvsjpdrlvydoohvvhtx.supabase.co';
2. انشره على Cloudflare (Workers & Pages → Create Worker → Deploy).
3. مرّر رابط الـ Worker للتطبيق عبر --dart-define=SUPABASE_URL=<worker-url>
   وأصدر تحديثاً. (لا حاجة لتعديل كود — فقط متغيّر البناء.)
ملاحظة: الحل الأبسط للمستخدمين وقت الحجب هو تغيير DNS (Cloudflare 1.1.1.1) أو VPN،
لأن الحجب كان DNS-level.
```

> بهذا الفكرة محفوظة دون إبقاء كود ميت.

---

### المهمة 4 — التحقق والبناء

```
flutter clean
flutter pub get
flutter analyze          # 0
flutter test            # 198/0
flutter build apk --release
```

**اختبار يدوي حرج:** شغّل التطبيق وتأكّد أنه **يتصل بقاعدة البيانات فعلياً** (البحث عن متبرع يُرجع نتائج). لأننا غيّرنا منطق الاتصال — يجب التأكد أن `activeSupabaseUrl` يعمل بعد التبسيط.

---

## ✅ قائمة التحقق (Definition of Done)

- [x] `supabase_config.dart` مبسّط، يتصل مباشرة بالقاعدة الحقيقية، لا منطق Worker.
- [x] مجلد `cloudflare-worker/` محذوف.
- [x] خطة الطوارئ موثّقة في handoff + القيود المعروفة.
- [x] `connectivity_service` لا يزال يعمل (يستخدم activeSupabaseUrl).
- [x] `flutter analyze` = 0، `flutter test` = 198/0.
- [x] اختبار يدوي: التطبيق يتصل بالقاعدة (البحث يُرجع نتائج).

---

## 📝 قيد PROJECT_LOG.md المقترح

```
### YYYY-MM-DD — [chore] حذف إعداد Cloudflare Worker الميت وتبسيط اتصال Supabase
- **الوصف:** حذف مجلد cloudflare-worker/ (كود غير منشور يشير لقاعدة مشروع المهرة
  القديمة mgeshfxrcdilwjohoniv) وتبسيط supabase_config.dart للاتصال المباشر بالقاعدة
  الحقيقية wdvsjpdrlvydoohvvhtx. حذف useCloudflareWorker وsupabaseDirectUrl المنفصل
  وURL الخاطئ. توثيق خطة طوارئ الحجب (Worker جديد عبر --dart-define إن عاد الحجب).
  السبب: الحجب المؤقت انحلّ (فبراير 2026)، والإعداد كان ميتاً ومضلّلاً.
- **الملفات:** lib/config/supabase_config.dart, cloudflare-worker/ (محذوف),
  yemen_blood_bank_handoff.md, docs/PROJECT_STATUS.md
- **اختبار:** analyze 0 / test 198 / يدوي: الاتصال بالقاعدة يعمل ✅.
- **Commit:** `<hash>`
```

> **صيغة commit:** `chore: remove dead Cloudflare Worker config, simplify Supabase connection`

---

## ⚠️ تنبيهات

1. **الاختبار اليدوي للاتصال حرج** — غيّرنا منطق الاتصال بالقاعدة. لا تكتفِ بـ analyze؛ تأكّد أن التطبيق يجلب البيانات فعلياً.
2. لا تحذف `supabaseAnonKey` ولا تغيّر القاعدة الحقيقية.
3. أبقِ getter `activeSupabaseUrl` (يستخدمه connectivity_service) — فقط بسّط ما يُرجعه.
4. هذا بند خارج المراحل العشر (مثل MainActivity الشبح) — يُسجّل في اللوحة كنقطة نظافة إضافية.
