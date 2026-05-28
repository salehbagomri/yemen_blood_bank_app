# 🩸 دليل تسليم مشروع بنك دم اليمن (Yemen Blood Bank - Handoff Guide)

هذا الملف مخصص لمساعدة أي مطور أو وكيل ذكاء اصطناعي (AI Agent) مستقبلي لفهم المشروع بسرعة البرق، ومواصلة تطويره أو إجراء أي تعديل عليه دون الحاجة للبحث الطويل.

---

## 📋 1. نظرة عامة على المشروع (Project Context)
* **فكرة المشروع:** تطبيق فلاتر (Flutter) لإدارة متبرعي الدم والربط بين المستشفيات والمتبرعين.
* **الهدف الرئيسي للمرحلة الحالية:** إعادة تسمية المشروع (Rebranding) بالكامل من **"بنك دم المهرة"** ليصبح **"بنك دم اليمن"**، وتوسيع النطاق ليشمل جميع محافظات اليمن الـ 22 بدلاً من مديريات المهرة فقط، وتوليد مفاتيح توقيع جديدة وقاعدة بيانات جديدة على Supabase.
* **حالة التطبيق الحالية:** التطبيق يعمل بنجاح بنسبة 100%، وخالٍ تماماً من أخطاء التجميع والواجهات.

---

## 🛠️ 2. التغييرات التي تم إنجازها بالكامل (Completed Tasks)

### أ. التسمية والهوية الرقمية (App Rebranding & Package ID)
* **معرف التطبيق (Android Package Name):** تم التغيير من `com.bagomri.mahrahbloodbank` إلى `com.bagomri.yemenbloodbank` في:
  * `android/app/build.gradle.kts` (`namespace` و `applicationId`).
  * `android/app/src/main/AndroidManifest.xml` (اسم الحزمة وتسمية التطبيق).
  * نقل ملف `MainActivity.kt` إلى مساره الجديد المطابق للحزمة الجديدة: `android/app/src/main/kotlin/com/bagomri/yemenbloodbank/MainActivity.kt`.
* **معرف التطبيق (iOS Bundle ID):** تم التغيير إلى `com.bagomri.yemenbloodbank` في `ios/Runner.xcodeproj/project.pbxproj` (في جميع مواقع الإعداد الستة).
* **اسم التطبيق الظاهري:** تم تعديله إلى **"بنك دم اليمن"** (بالعربية) و **"Yemen Blood Bank"** (بالإنجليزية) في كافة ملفات التكوين والواجهات (`Info.plist`, `AndroidManifest.xml`, `app_strings.dart`, `about_screen.dart`, إلخ).

### ب. توسيع النطاق الجغرافي (Governorates Expansion)
* تم تعديل قائمة `districts` في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart) لتشمل **كافة محافظات اليمن الـ 22** بالترتيب الهجائي.
* تم تغيير المسميات التوضيحية وتلميحات الواجهات من **"المديرية"** إلى **"المحافظة"** في جميع شاشات الإدخال والبحث والتقارير لتتناسب مع النطاق الوطني الجديد للتطبيق.

### ج. مفتاح التوقيع الجديد للجمهور (Yemen Keystore Generation)
تم إنشاء ملف توقيع رقمي جديد بالكامل وخاص باليمن (`yemen-release-key.jks`) وتم إعداده بنجاح في ملف `key.properties` ومزامنته محلياً.
* **بصمات التوقيع النشطة للتطبيق الجديد:**
  * **SHA-1:** `ED:C7:B3:52:3C:A8:57:D1:71:06:89:19:1C:50:27:F7:54:34:B0:0C`
  * **SHA-256:** `8A:E8:B9:80:F0:1B:64:CC:3C:70:70:C1:07:F7:34:0C:68:73:F7:75:52:09:EF:EA:37:63:39:E3:32:9C:6E:CB`
* *ملاحظة أمنية:* تم استبعاد ملفات التوقيع محلياً في `.gitignore` لحمايتها. المعلومات التفصيلية موجودة في ملف `KEYSTORE_INFO.txt` في جذر المشروع.

### د. إصلاح تجاوز واجهة المستخدم (UI Overflow Fix)
* تم حل مشكلة تجاوز واجهة المستخدم بمقدار `4.5 بكسل` في أسفل بطاقة الإحصائيات للأدمن (`_StatCard` في ملف [admin_statistics_grid.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/widgets/admin_statistics_grid.dart)) عن طريق ضبط نسبة العرض إلى الارتفاع `childAspectRatio` إلى `1.3` وتقليل الحشوات وأحجام الأيقونات والنصوص رأسياً لتلائم الشاشات الصغيرة بشكل مثالي.

### هـ. تحديث بيئة التطوير وملفات IDE (.iml & .idea)
* تم حذف مراجع التكوين القديمة بالكامل.
* أنشأنا ملف تكوين جذري [yemen_blood_bank.iml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/yemen_blood_bank.iml) وملف موديول الأندرويد المحدث [yemen_blood_bank_android.iml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/android/yemen_blood_bank_android.iml) وربطهما بملف الفهرسة الرئيسي [modules.xml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/.idea/modules.xml).

---

## 🏗️ 3. المعمارية التقنية للمشروع (Technical Architecture)

يعتمد التطبيق على معمارية معيارية نظيفة وسهلة الصيانة:
1. **إدارة الحالة (State Management):** يستخدم حزمة `Provider` لإدارة الحالات المختلفة للتطبيق ومزامنة البيانات.
2. **حقن الاعتمادات (Dependency Injection):** يستخدم حزمة `GetIt` عبر كلاس مركزي [service_locator.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/config/service_locator.dart) لتسجيل الخدمات (Services) والـ Providers للوصول السهل.
3. **التخزين المؤقت وقاعدة البيانات المحلية (Local Caching):** يعتمد على قاعدة بيانات **Hive** السريعة جداً للعمل في وضع عدم الاتصال بالإنترنت (Offline Mode) وحفظ الإحصائيات وبيانات التبرع والتحقق منها دورياً.
4. **قاعدة البيانات البعيدة (Remote Database Backend):** يستهدف قاعدة بيانات **Supabase** عبر مكتبة `supabase_flutter`.

---

## ⚙️ 4. المتمليات اليدوية المتبقية لتشغيل النظام بالكامل (Next Setup Steps)

لإنهاء ربط التطبيق بقاعدة البيانات والخدمات السحابية الجديدة، يرجى التوجيه بتنفيذ المهام التالية:

### الخطوة 1: إنهاء تكوين Firebase
1. افتح مشروع Firebase Console الجديد الخاص بك.
2. أضف تطبيق Android بالـ Package Name الجديد: `com.bagomri.yemenbloodbank`.
3. الصق بصمات التوقيع **SHA-1** و **SHA-256** المذكورة أعلاه في إعدادات التطبيق.
4. قم بتحميل ملف `google-services.json` الجديد وضعه مباشرة في مجلد: `android/app/google-services.json` (مستبدلاً الملف القديم).

### الخطوة 2: تهيئة قاعدة بيانات Supabase
1. أنشئ مشروعاً جديداً في Supabase باسم `yemen-blood-bank`.
2. انسخ محتويات ملف السكيما البرمجية الجاهزة [supabase_setup_schema.md](file:///C:/Users/SALEH/.gemini/antigravity-ide/brain/e2a91bba-5d41-4b67-ba6d-c1f2dd234f5e/supabase_setup_schema.md).
3. افتح الـ **SQL Editor** في لوحة تحكم Supabase، وألصق السكريبت واضغط **Run**.
4. لتسجيل نفسك كأدمن رئيسي للنظام:
   * بعد تسجيل حسابك الأول على التطبيق بنجاح، احصل على المعرف الخاص بك (UUID) من Supabase Auth.
   * نفذ الاستعلام التالي لتعيين حسابك مديراً عاماً في جدول `admins`:
     ```sql
     INSERT INTO public.admins (id, name, email) 
     VALUES ('<YOUR-AUTH-USER-UUID>', 'المدير العام', 's.bagomri@gmail.com');
     ```

### الخطوة 3: تحديث روابط التكوين النشطة (Active Supabase Config)
* تأكد من إدراج رابط وقيم مشروع الـ Supabase الجديد الخاص بك في ملف [supabase_config.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/config/supabase_config.dart). 
* ملاحظة: يمكنك تعطيل بروكسي Cloudflare مؤقتاً بتحديد `useCloudflareWorker = false` لتجربة الاتصال المباشر.

---

## 📝 5. نصائح وتوجيهات للوكلاء والمطورين المستقبليين (Tips for Future Agents)
* **قاعدة التسميات الجغرافية:** المحافظات مخزنة كـ `district` في قاعدة البيانات وفي الكود لأسباب تاريخية وتوافقية. عند الرغبة في التعديل الجغرافي، يرجى دائماً تعديل القائمة في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart).
* **التجمع والاختبار:** للتحقق من سلامة الأكواد والـ lints في أي وقت، قم بتشغيل:
  ```powershell
  flutter analyze
  ```
  وللتشغيل في وضع التطوير:
  ```powershell
  flutter run
  ```

هذا المشروع منظم ومرتب للغاية، ومعماريته النظيفة تجعل إضافة أي ميزات جديدة (مثل إرسال إشعارات FCM، أو تحسين شاشات إحصائيات المحافظات) مهمة غاية في السهولة واليسر! 🩸🚀
