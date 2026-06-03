# 📓 مذكّرة تنفيذ — المرحلة 8: تدقيق الأمان والأسرار والتوقيع

> **موجَّهة إلى:** وكيل محرر الكود (المنفِّذ).
> **المخطِّط:** Claude (التحليل والتصميم).
> **القرار صاحب المشروع:** المستودع **عام**، التطبيق **قيد التطوير (غير منشور على Google Play)**، كلمة مرور الـ keystore **فريدة وغير مستخدمة في حسابات أخرى**.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 8.

---

## 🎯 السياق والقرار المعتمد

كشف الفحص تسريبين على المستودع العام:

1. **`KEYSTORE_INFO.txt`** متعقَّب ومرفوع، ويحتوي **كلمات مرور keystore بنص صريح** (storePassword + keyPassword + alias). ملف المفتاح `.jks` نفسه **غير مرفوع** (محمي بـ `.gitignore`).
2. **`lib/config/supabase_config.dart`** يحتوي قيمة افتراضية صريحة لـ `anon key` و `supabaseDirectUrl`. (ملاحظة: مفتاح anon عام بطبيعته والحماية على RLS — أقل خطورة، لكن يرفع إلحاح تدقيق RLS في المرحلة 4.)

**القرار المعتمد من صاحب المشروع:** بما أن التطبيق **لم يُنشر بعد**، نتبع المسار الأنظف: **إنشاء keystore جديد بكلمات مرور جديدة واعتبار القديم محروقاً**، بدل محاولة تنظيف التاريخ فقط. هذا يجعل المفتاح المكشوف عديم القيمة نهائياً.

---

## 🧩 الأنماط المحمية التي يجب ألا تُكسر

- لا تلمس منطق `build.gradle.kts` لقراءة `key.properties` — هو سليم (يقرأ من ملف غير مرفوع).
- لا تغيّر `applicationId` أو `namespace` (`com.bagomri.yemenbloodbank`).
- `versionCode`/`versionName` يبقيان مقروءين من Flutter (`pubspec.yaml`) — لا تُقحم قيماً ثابتة.
- لا ترفع أي ملف أسرار جديد. تحقّق من `.gitignore` قبل أي `git add`.

---

## 📋 المهام بالترتيب

### المهمة 8.1 — التأمين الفوري لـ KEYSTORE_INFO.txt

```powershell
# إزالة الملف من تعقّب Git (يبقى محلياً على الجهاز)
git rm --cached KEYSTORE_INFO.txt
```

ثم أضف إلى `.gitignore` في جذر المشروع (تحت قسم Keystore الموجود):

```
# Keystore info file (contains plaintext passwords - NEVER commit)
KEYSTORE_INFO.txt
SIGNATURE_VERIFICATION_REPORT.txt
```

> **ملاحظة:** `SIGNATURE_VERIFICATION_REPORT.txt` يحتوي بصمات وتفاصيل توقيع — يُفضّل عدم رفعه أيضاً. تحقّق إن كان متعقَّباً (`git ls-files | Select-String signature`) وأزِله بنفس الطريقة إن لزم.

---

### المهمة 8.2 — إنشاء keystore جديد بكلمة مرور جديدة

> **حرج:** اختر كلمة مرور جديدة قوية (لا تُعاد القديمة). خزّنها في مدير كلمات مرور، لا في ملف نصي داخل المشروع.

```powershell
# من جذر المشروع. استبدل NEW_STRONG_PASSWORD بكلمة مرور جديدة فعلية.
keytool -genkey -v -keystore "android/keystore/yemen-release-key-v2.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass "NEW_STRONG_PASSWORD" -keypass "NEW_STRONG_PASSWORD" -dname "CN=Saleh Bagomri, OU=Yemen Blood Bank, O=Yemen Blood Bank App, L=Aden, ST=Aden, C=YE"
```

> اسم جديد للملف (`-v2`) لتمييزه عن القديم المحروق. تأكد أن `**/*.jks` و `**/android/keystore/` في `.gitignore` (موجودان فعلاً — تحقّق).

---

### المهمة 8.3 — تحديث key.properties (ملف غير مرفوع)

عدّل `android/key.properties` (أو جذر `android/`) ليشير للمفتاح الجديد:

```properties
storePassword=NEW_STRONG_PASSWORD
keyPassword=NEW_STRONG_PASSWORD
keyAlias=upload
storeFile=keystore/yemen-release-key-v2.jks
```

> تحقّق أن `key.properties` في `.gitignore` (موجود: `**/key.properties`).

---

### المهمة 8.4 — حذف الملف القديم المحروق (محلياً)

بعد التأكد أن المفتاح الجديد يبني بنجاح (المهمة 8.6):

```powershell
Remove-Item "android/keystore/yemen-release-key.jks"
```

> لا تحذفه قبل التحقق من نجاح البناء بالمفتاح الجديد.

---

### المهمة 8.5 — إزالة الأسرار الصريحة من supabase_config.dart — 🟦 مؤجَّلة لما قبل النشر

> **قرار صاحب المشروع:** **مؤجَّلة. لا تُنفَّذ في هذه المرحلة.**

**المشكلة:** قيم `defaultValue` الصريحة للـ anon key و `supabaseDirectUrl` في الكود المرفوع على المستودع العام.

**لماذا التأجيل (لا التجاهل):** مفتاح `anon` مُصمَّم ليكون عاماً بطبيعته (يُستخرج من أي تطبيق مثبَّت على أي حال)، والحماية الفعلية تقع على **سياسات RLS** لا على سرّية المفتاح. لذا هذا ليس خطراً عاجلاً يستحق إقحام تغيير في آلية البناء وسط مرحلة الأمان الحرجة (الـ keystore).

**الترتيب المعتمد:**
1. **الآن:** تُنفَّذ بقية مهام المرحلة 8 (الـ keystore) فقط.
2. **التالي مباشرة:** المرحلة 4 (تدقيق RLS) — صارت أكثر أهمية لأن المفتاح علني، فهي خط الدفاع الحقيقي.
3. **عند تجهيز الإصدار للنشر:** يُنفَّذ نقل المفتاح خارج الكود كالتالي:
   - جعل `defaultValue` فارغة أو placeholder (`'SET_VIA_DART_DEFINE'`).
   - تمرير القيم الفعلية وقت البناء عبر `--dart-define-from-file=.env.json`.
   - إنشاء `.env.json.example` (يُرفع) و `.env.json` (في `.gitignore` — مغطّى بـ `.env.*`).

> **للمنفِّذ:** تجاوز هذه المهمة الآن. ستُفعّل في مذكّرة منفصلة عند مرحلة ما قبل النشر.

---

### المهمة 8.6 — التحقق من البناء بالمفتاح الجديد

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

ثم تحقّق من التوقيع:

```powershell
keytool -printcert -jarfile "build/app/outputs/flutter-apk/app-release.apk"
```

سجّل بصمة SHA الجديدة (ستختلف عن القديمة — هذا متوقَّع ومطلوب).

---

### المهمة 8.7 — تحديث التوثيق ببصمة واحدة نظيفة

- حدّث `yemen_blood_bank_handoff.md` قسم (د): استبدل البصمات القديمة بالبصمة الجديدة الوحيدة، **دون ذكر أي كلمة مرور**.
- احذف أو فرّغ أي إشارة لكلمات المرور في أي ملف `.md`/`.txt` متعقَّب.

---

## ✅ قائمة التحقق (Definition of Done)

- [ ] `KEYSTORE_INFO.txt` لم يعد متعقَّباً (`git ls-files` لا يُظهره).
- [ ] `.gitignore` يغطي `KEYSTORE_INFO.txt` وملفات الأسرار.
- [ ] keystore جديد (`-v2`) أُنشئ بكلمة مرور جديدة فريدة.
- [ ] `key.properties` يشير للمفتاح الجديد.
- [ ] البناء `flutter build apk --release` ناجح وموقَّع بالمفتاح الجديد.
- [ ] الملف القديم `.jks` حُذف محلياً بعد نجاح البناء.
- [ ] المهمة 8.5 (supabase_config) **مؤجَّلة لما قبل النشر — لا تُنفَّذ الآن**.
- [ ] `flutter analyze` = 0 أخطاء/تحذيرات.
- [ ] لا كلمات مرور في أي ملف متعقَّب.
- [ ] التوثيق محدَّث ببصمة واحدة.

---

## 📝 قيد PROJECT_LOG.md المقترح (يُضاف في الأعلى بعد التنفيذ)

```
### YYYY-MM-DD — [fix] تأمين بيانات التوقيع وإزالة الأسرار من المستودع العام
- **الوصف:** إزالة KEYSTORE_INFO.txt من تعقّب Git (كان يحوي كلمات مرور صريحة)، إنشاء keystore جديد بكلمة مرور جديدة واعتبار القديم محروقاً (التطبيق غير منشور بعد فلا تبعات)، تحديث key.properties، وتوثيق بصمة توقيع واحدة نظيفة. (تأمين مفتاح Supabase anon مؤجَّل لما قبل النشر.)
- **الملفات:** `.gitignore`, `android/key.properties`, `android/keystore/yemen-release-key-v2.jks` (غير مرفوع), `yemen_blood_bank_handoff.md`
- **السبب/الدافع:** فحص أمني كشف رفع كلمات مرور keystore على مستودع عام. المعالجة بإبطال المفتاح المكشوف بالكامل.
- **اختبار:** analyze ✅ / build apk release موقَّع بالمفتاح الجديد ✅ / يدوي ⚠️.
- **Commit:** `<hash>`
```

> **صيغة commit:** `fix: secure signing credentials and remove secrets from public repo`

---

## ⚠️ تنبيهات للمنفِّذ

1. **لا تكتب كلمة المرور الجديدة في أي ملف داخل المشروع.** مدير كلمات مرور فقط.
2. **لا تحذف المفتاح القديم قبل** التأكد من بناء ناجح بالجديد.
3. **التاريخ القديم يبقى مكشوفاً** — المفتاح القديم وكلمته يبقيان في تاريخ Git؛ أماننا يعتمد على أنه أصبح **غير مستخدم** لا على إخفائه. لا حاجة لإعادة كتابة التاريخ بما أن المفتاح أُبطل.
4. **خذ نسخة احتياطية آمنة** من المفتاح الجديد فور إنشائه (USB/Cloud مشفّر) — فقدانه يعني عدم القدرة على تحديث التطبيق مستقبلاً بعد النشر.
5. **المهمة 8.5 مؤجَّلة** لمرحلة ما قبل النشر — تجاوزها الآن ولا تنتظر بشأنها.
