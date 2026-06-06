# 🩸 دليل تسليم مشروع بنك دم اليمن (Yemen Blood Bank - Handoff Guide)

هذا الملف مخصص لمساعدة أي مطور أو وكيل ذكاء اصطناعي (AI Agent) مستقبلي لفهم المشروع بسرعة البرق، ومواصلة تطويره أو إجراء أي تعديل عليه دون الحاجة للبحث الطويل.

---

## 📋 1. نظرة عامة على المشروع (Project Context)
* **فكرة المشروع:** تطبيق فلاتر (Flutter) لإدارة متبرعي الدم والربط بين المستشفيات والمتبرعين على مستوى اليمن.
* **الإصدار:** `1.0.0+1` — أُعيد تعيينه (كان `1.0.3+6` لتطبيق المهرة القديم) لأن الحزمة الجديدة `com.bagomri.yemenbloodbank` تطبيق جديد كلياً على المتجر. **لا يُرفع الإصدار إلا عند النشر الفعلي.**
* **التحويل الوطني (مكتمل):** تحوّل المشروع من نطاق محافظة واحدة (المهرة) إلى **اليمن كاملاً (22 محافظة، 224+ مديرية)** عبر 6 مراحل (خلفية، نماذج/خدمات، حوكمة جغرافية، تبسيط UX، أداء، تحقق) — راجع [docs/DEVELOPMENT_PLAN.md](./docs/DEVELOPMENT_PLAN.md) للتفصيل و[PROJECT_LOG.md](./PROJECT_LOG.md) للسجل الزمني.
* **حالة التطبيق الحالية:** يعمل بنجاح؛ `flutter analyze` = 0 أخطاء/تحذيرات؛ اجتاز اختبار الجهاز للسيناريوهات الأربعة (متبرع، طالب دم، مستشفى، أدمن). التطوير مستمر، والنشر مؤجَّل بقرار المالك.

---

## 🛠️ 2. التغييرات التي تم إنجازها بالكامل (Completed Tasks)

### أ. التسمية والهوية الرقمية (App Rebranding & Package ID)
* **معرف التطبيق (Android Package Name):** تم التغيير من `com.bagomri.mahrahbloodbank` إلى `com.bagomri.yemenbloodbank` في:
  * `android/app/build.gradle.kts` (`namespace` و `applicationId`).
  * `android/app/src/main/AndroidManifest.xml` (اسم الحزمة وتسمية التطبيق).
  * نقل ملف `MainActivity.kt` إلى مساره الجديد المطابق للحزمة الجديدة: `android/app/src/main/kotlin/com/bagomri/yemenbloodbank/MainActivity.kt`.
* **معرف التطبيق (iOS Bundle ID):** تم التغيير إلى `com.bagomri.yemenbloodbank` في `ios/Runner.xcodeproj/project.pbxproj` (في جميع مواقع الإعداد الستة).
* **اسم التطبيق الظاهري:** تم تعديله إلى **"بنك دم اليمن"** (بالعربية) و **"Yemen Blood Bank"** (بالإنجليزية) في كافة ملفات التكوين والواجهات (`Info.plist`, `AndroidManifest.xml`, `app_strings.dart`, `about_screen.dart`, إلخ).

### ب. الهيكلية الجغرافية ثنائية المستويات للمحافظات والمديريات (Two-Tier Geographic Hierarchy)
* تم إضافة خريطة المديريات الشاملة لكافة الـ 22 محافظة في اليمن في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart).
* تم تحويل واجهة الإدخال والتعديل إلى **نظام قوائم منسدلة متتالية ذكية (Cascading Dropdowns)** في خمس شاشات رئيسية:
  1. [إضافة متبرع (Add Donor Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/donor/add_donor_screen.dart)
  2. [تعديل متبرع (Edit Donor Screen - للأدمن)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/edit_donor_screen.dart)
  3. [إضافة مستشفى (Add Hospital Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/add_hospital_screen.dart)
  4. [تعديل مستشفى (Edit Hospital Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/edit_hospital_screen.dart)
  5. [شاشة البحث عن المتبرعين (Search Donors Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/donor/search_donors_screen.dart)
* **ذكاء تخزين وفلترة الموقع:**
  * يُحفظ الموقع المدمج كـ `"المحافظة - المديرية"` (مثل: `"حضرموت - المكلا"`) في حقل `district` (للعرض والتوافق).
  * **إضافة لاحقة (المرحلة 0):** أُضيف عمود `governorate` مستقل ومفهرس إلى `donors` و`hospitals` (مع backfill من `district`)، فأصبحت فلترة المحافظة عبر العمود المفهرس بدل `LIKE` — أسرع وأنظف للتوسع الوطني.
  * النماذج تشتق `governorate` دفاعياً من `district` إن غاب العمود.
  * تم توحيد الفلاتر المحلية على `startsWith` لمطابقة اللاحقة في كل الشاشات ووضع عدم الاتصال.

### ج. البرمجة الدفاعية والحماية من الانهيار (Defensive Programming & Null Safety)
* تم الكشف عن خلل في عدم تطابق حقل `updated_at` في النماذج (حيث كان غير موجود في سكيما الجداول بينما تفرضه النماذج برمجياً وتطالب به كـ `String` غير فارغ).
* قمنا بحل هذا الخلل جذرياً عن طريق إدخال **منطق حماية برمجي دفاعي (Defensive Fallback)** في المحللات (fromJson) الخاصة بالنماذج البرمجية الثلاثة:
  * [DonorModel](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/models/donor_model.dart)
  * [HospitalModel](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/models/hospital_model.dart)
  * [AdminModel](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/models/admin_model.dart)
  بحيث إذا أرجعت قاعدة البيانات قيمة فارغة لـ `updated_at` يتجاوزها التطبيق تلقائياً وبسلاسة ويسند قيمة `created_at` بدلاً منها، مما يضمن أن التطبيق **لن ينهار أبداً**!

### د. مفتاح التوقيع الجديد للجمهور (Yemen Keystore Generation)
...
* **بصمات التوقيع النشطة للتطبيق الجديد (v2):**
  * **SHA-1:** `EC:E5:A7:FE:29:4F:E1:CA:C8:1E:0D:20:03:CB:D4:5D:99:86:1A:94`
  * **SHA-256:** `84:14:9A:00:58:89:26:C6:5D:B1:22:33:3F:71:EF:ED:65:E4:EA:FA:72:69:64:2A:7C:15:DB:D0:5B:65:D5:55`
* **متطلبات Firebase قبل النشر:**
  * إضافة بصمة keystore v2 النشطة أعلاه إلى منصة Firebase Console.
  * بعد رفع التطبيق إلى Google Play Console وتفعيل "Play App Signing"، يجب نسخ بصمة App Signing المُولّدة من Play Console وإضافتها إلى Firebase Console.
  * تنزيل ملف `google-services.json` الجديد واستبداله بالملف الحالي في المشروع.

### هـ. إصلاح تجاوز واجهة المستخدم (UI Overflow Fix)
* تم حل مشكلة تجاوز واجهة المستخدم بمقدار `4.5 بكسل` في أسفل بطاقة الإحصائيات للأدمن (`_StatCard` في ملف [admin_statistics_grid.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/widgets/admin_statistics_grid.dart)) عن طريق ضبط نسبة العرض إلى الارتفاع `childAspectRatio` إلى `1.3` وتقليل الحشوات وأحجام الأيقونات والنصوص رأسياً لتلائم الشاشات الصغيرة بشكل مثالي.

### و. تحديث بيئة التطوير وملفات IDE (.iml & .idea)
* تم حذف مراجع التكوين القديمة بالكامل.
* أنشأنا ملف تكوين جذري [yemen_blood_bank.iml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/yemen_blood_bank.iml) وملف موديول الأندرويد المحدث [yemen_blood_bank_android.iml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/android/yemen_blood_bank_android.iml) وربطهما بملف الفهرسة الرئيسي [modules.xml](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/.idea/modules.xml).

### ز. الحوكمة الجغرافية (Geographic Governance) — جوهر التحويل الوطني
* **النموذج:** المستشفى **مقيّدة بمحافظتها** (ترى/تدير متبرعي محافظتها فقط)، والأدمن **عام** يرى كل اليمن ويفلتر بالمحافظة.
* `AuthProvider.hospitalGovernorate` يُحمَّل عند الدخول عبر `SupabaseService.getCurrentHospitalGovernorate` (دفاعي: العمود أو مشتق من `district`).
* لوحة المستشفى تحسب إحصائياتها لمحافظتها عبر مسار مخصّص في `DashboardProvider` (استعلام `getDonorsByGovernorate` + حساب محلي).
* عند إضافة متبرع من حساب مستشفى تُثبَّت المحافظة وتُقفل (`CustomDropdown.enabled=false`).
* **⚠️ التقييد على مستوى التطبيق لا RLS:** سياسة SELECT على `donors` عامة (`is_active=true` لـ public) لأن البحث الوطني يعمل بلا تسجيل، وسياسات RLS تُجمَع بـ OR — فلا يمكن تضييق قراءة المستشفى عبر RLS. لذا التقييد يكون في طبقة Dart.

### ح. سياسات وإعدادات Supabase الإضافية
* **إدراج عام للمتبرعين (anon):** سياسة `"Public can self-register as donor"` تسمح لغير المسجّل بإضافة متبرع بضوابط `is_active=true AND added_by IS NULL` (المستخدم العادي يضيف بلا حساب).
* **`mailer_autoconfirm = true`:** لتفادي خطأ "email rate limit exceeded" عند إضافة مستشفى (الأدمن يسلّم كلمة المرور يدوياً، فلا داعي لتأكيد البريد).
* **دوال خادمية للإحصائيات (GROUP BY):** `get_governorate_stats(p_governorate)`، `get_bloodtype_stats()`، `get_district_stats()` — تحل محل جلب كل الصفوف للعدّ محلياً (تتوسع لآلاف السجلات؛ مُتحقَّق عند 20k صف).

### ط. تبسيط تجربة المستخدم والإصلاحات
* **بحث بالمحافظة وحدها** (المديرية اختيارية) + عدّاد "وُجد X متبرعاً في محافظة Y".
* **دليل أول مرة (Onboarding):** [onboarding_screen.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/onboarding/onboarding_screen.dart) — 3 صفحات تظهر أول تشغيل فقط (flag في `shared_preferences`)، مدموجة في مسار splash.
* **صيغة الهاتف:** بادئة `+967` ونص مساعد "9 أرقام تبدأ بـ 7" في إضافة متبرع.
* **إصلاحات:** ومضة شاشة الدخول (علامة `_navigating` + انتقال `slideFromRight` للوحات)، وتجاوز (overflow) قوائم الفلاتر (`isExpanded: true`).

### ي. نظام البانرات الديناميكي وسلايدر الصفحة الرئيسية (Dynamic Banners System & New Slider)
* تم بناء نظام البانرات بالكامل:
  1. **قاعدة البيانات:** جدول `banners` مع RLS (قراءة عامة، كتابة للأدمن) ومستودع تخزين صور البانرات (`banners` bucket) مع سياسات حماية كاملة للأدمن. السكربت: [docs/sql/phase8_banners.sql](./docs/sql/phase8_banners.sql).
  2. **النماذج والخدمات:** بناء `BannerModel` مع منطق parsed دفاعي للتواريخ، وبناء `BannerService` لدعم عمليات CRUD ورفع/حذف الصور وإعادة ترتيب البانرات من لوحة الأدمن.
  3. **التخزين المؤقت (Caching):** إضافة صندوق `banners_cache` في `CacheService` وربطه بالـ `BannerProvider` لتقديم البانرات بنظام Cache-First ودعم العمل التام بلا إنترنت (Offline Mode).
  4. **لوحة الأدمن:** إضافة شاشة إدارة البانرات كاملة (`manage_banners_screen.dart`) تتيح إضافة بانر جديد، وتعديله، وحذفه، وتغيير حالته، وإعادة ترتيب البانرات بأسهم أعلى/أسفل، مع إرشادات للأبعاد المثالية (1200×600 بكسل، نسبة 2:1، حجم < 2MB). تتيح البانرات تحديد نوع الإجراء عند الضغط (لا شيء، فتح شاشة داخلية مع dropdown، أو فتح رابط خارجي).
  5. **سلايدر الرئيسية:** استبدال السلايدر القديم الثابت بالكامل بالـ `HomeBannerSlider` التفاعلي الجديد القائم على `PageView.builder` مع تشغيل تلقائي ذكي (يتوقف مؤقتاً عند اللمس ويستأنف بعد 3 ثوانٍ من الإفلات)، وshimmer loading للصور، ونقاط تنقل حديثة `ExpandingDots`؛ وعند غياب البانرات يُعرض السلايدر الاحتياطي التوعوي والإحصائي محلياً بشكل تلقائي.

---

## 🏗️ 3. المعمارية التقنية للمشروع (Technical Architecture)

يعتمد التطبيق على معمارية معيارية نظيفة وسهلة الصيانة:
1. **إدارة الحالة (State Management):** يستخدم حزمة `Provider` لإدارة الحالات المختلفة للتطبيق ومزامنة البيانات.
2. **حقن الاعتمادات (Dependency Injection):** يستخدم حزمة `GetIt` عبر كلاس مركزي [service_locator.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/config/service_locator.dart) لتسجيل الخدمات (Services) والـ Providers للوصول السهل.
3. **التخزين المؤقت وقاعدة البيانات المحلية (Local Caching):** يعتمد على قاعدة بيانات **Hive** السريعة جداً للعمل في وضع عدم الاتصال بالإنترنت (Offline Mode) وحفظ الإحصائيات وبيانات التبرع والتحقق منها دورياً.
4. **قاعدة البيانات البعيدة (Remote Database Backend):** يستهدف قاعدة بيانات **Supabase** عبر مكتبة `supabase_flutter`.

---

## ⚙️ 4. قاعدة بيانات Supabase (Schema & RPCs)

**المرجع الكامل والقابل للتنفيذ:** [docs/sql/phase0_governorate_migration.sql](./docs/sql/phase0_governorate_migration.sql) — يحوي كل التغييرات (مُطبَّقة فعلياً على مشروع `wdvsjpdrlvydoohvvhtx`). للوصول البرمجي راجع ملف `.env` (محمي بـ gitignore) وذاكرة الوكيل.

ملخص البنية الحالية:
* **`donors`:** الأعمدة الأساسية + `district TEXT` (المحافظة - المديرية) + **`governorate TEXT` (مفهرس)** + `added_by`/`is_active`/`suspended_until`/تواريخ. قيود: `age 17..70`، `gender IN ('male','female')`.
* **`hospitals` / `admins`:** المعرّف `id = auth.users.id`. للمستشفى عمود `governorate` (مفهرس).
* **الفهارس:** `idx_donors_gov`, `idx_donors_gov_blood`, `idx_hospitals_gov`.
* **`search_donors(p_blood_type, p_district, p_available_only, p_governorate DEFAULT NULL)`:** يفلتر بالمحافظة عبر العمود المفهرس + المديرية بالمطابقة الجزئية، ويُرجع المتاحين عند الطلب. (`SECURITY DEFINER` ⇒ يعمل للبحث العام بلا تسجيل.)
* **دوال إحصائية:** `get_governorate_stats(p_governorate)`, `get_bloodtype_stats()`, `get_district_stats()`.
* **`update_donor_donation_date(p_donor_id, p_last_donation_date, p_suspended_until)`**: دالة مخصصة بتصريح `SECURITY DEFINER` تتيح للمستشفى/الأدمن تحديث تاريخ آخر تبرع وحالة الإيقاف لمتبرع، مع حارس جغرافي يمنع المستشفى من تحديث متبرع خارج محافظته (تجاوزاً لقيد RLS للـ UPDATE المباشر).
* **`add_hospital_bypassing_rls(...)`**: يُنشئ صف المستشفى ويملأ `governorate` من `p_district` تلقائياً.
* **RLS:** قراءة `donors` عامة للنشطين؛ INSERT للعامة (anon) بضوابط + للمستشفى/الأدمن؛ UPDATE بالملكية (`added_by`) أو الأدمن؛ DELETE للأدمن.
  > 🟢 قرار معماري مقصود + تدقيق أمني (2026-06-03):
  > - سياسة SELECT على donors عامة (USING is_active=true) عن عمد: البحث الوطني
  >   بلا تسجيل + عرض المتبرعين + الإحصائيات تقرأ الجدول مباشرة. متوافق مع سياسة
  >   الخصوصية. ⚠️ لا تُضيّق SELECT دون إعادة هندسة كل دوال القراءة لتمرّ عبر RPCs
  >   (يكسر لوحة المستشفى/الأدمن/البحث بالاسم/الإحصائيات).
  > - طبقة الكتابة دُقِّقت باختبار اختراق فعلي (7 اختبارات، ROLLBACK): UPDATE/DELETE
  >   محصورة بملكية الصف (added_by) أو الأدمن؛ DELETE للأدمن فقط؛ إدراج anon بضوابط
  >   صارمة (added_by IS NULL، is_active=true) مُتحقَّقة؛ suspend_donor_by_hospital
  >   تحرس المحافظة. النتيجة: لا تعديل/حذف/انتحال غير مصرّح حتى بالمفتاح العلني.
  > - الحماية ضد السحب الجماعي للقراءة = Rate Limiting (Cloudflare Worker) عند النشر،
  >   لا تضييق RLS.
* **`governorates` / `districts` (إدارة المناطق المفعّلة):** جدولان يتحكم بهما الأدمن لإظهار/إخفاء المناطق (إطلاق تدريجي). `governorates(name, is_active, sort_order)` و`districts(id, governorate, name, is_active)`. RLS: قراءة عامة، كتابة للأدمن. دالة `district_in_use(gov,name)` تمنع تعديل/حذف مديرية مستخدمة. السكربت: [docs/sql/phase6_locations.sql](./docs/sql/phase6_locations.sql). في التطبيق: `LocationService`/`LocationProvider` (Cache-First، احتياطي `AppStrings` offline)، وشاشة الأدمن `manage_locations_screen.dart`. **كل القوائم المنسدلة الجغرافية تقرأ من `LocationProvider` لا من `AppStrings` مباشرة.**
* **`banners` (نظام البانرات الديناميكي):** الأعمدة: `id` (UUID)، `title TEXT NOT NULL`، `subtitle TEXT`، `image_path TEXT NOT NULL` (مسار الملف في Storage)، `action_type TEXT` (none | internal_route | external_url)، `action_value TEXT`، `sort_order INT`، `is_active BOOLEAN`، `starts_at TIMESTAMPTZ`، `ends_at TIMESTAMPTZ`، وتواريخ `created_at` / `updated_at`. RLS: قراءة عامة للجميع، وتحكم كامل (ALL) للأدمن فقط. السكربت: [docs/sql/phase8_banners.sql](./docs/sql/phase8_banners.sql).
* **Supabase Storage Bucket `banners`:** مستودع عام لتخزين صور البانرات. سياسات RLS: قراءة عامة للصور للجميع، ورفع وحذف الصور للأدمن فقط.
* **⚠️ إرسال Arabic عبر Management API:** يجب إرسال جسم الطلب كـ UTF-8 bytes (`[Text.Encoding]::UTF8.GetBytes($json)`)؛ الترميز الافتراضي في PowerShell 5.1 يفسد العربية إلى `?`.

> ملاحظة: أي تعديل لاحق على السكيما يُوثَّق في ملف الـ SQL أعلاه وفي هذا القسم.

---

## ⚠️ 5. القيود المعروفة (Known Limitations)
- **مفتاح Supabase anon علني في الكود:** مقبول بطبيعة الحال في تطبيقات الجوال القائمة على Supabase — ويتم الاعتماد كلياً على حماية قواعد الأمان في Supabase (RLS). يُنظف الكود خارجياً قبل النشر كخطوة اختيارية إضافية (المرحلة 8.5 المؤجَّلة).
- **معدل الاستدعاءات (Rate Limiting) غير مفعّل:** التطبيق لا يحتوي على حد لمعدل الطلبات لمنع سحب البيانات قراءةً على الـ API، ويوصى بتطبيق هذا حد عبر وسيط مثل Cloudflare Worker عند إطلاق التطبيق للجمهور.
- **حماية التعديل تعتمد على الملكية (`added_by`):** حماية تعديل بيانات المتبرع تعتمد على مطابقة معرّف المنشئ (حساب مستشفى أو أدمن) ولا تعتمد على تقييد جغرافي للمحافظات، وهو حل آمن وسليم، وقد يخضع للمراجعة مستقبلاً حسب متطلبات التشغيل.
- **مستوى التغطية الكودية (76.39%):** التغطية تشمل منطق النماذج والمساعدين والتحقق، بينما لا تغطي شاشات الواجهة والخدمات الشبكية (تتطلب اختبارات تكاملية).
- **مشكلة بناء App Bundle (AAB):** واجه التطبيق سابقاً مشكلة في بناء حزم الـ AAB (مفصلة في مستندات الأرشيف)، ويجب التحقق من جاهزية البناء الكاملة في بيئة نظيفة ومحدثة عند النشر الفعلي.

### خطة طوارئ: حجب Supabase في اليمن
حجب `supabase.co` حدث مؤقتاً في اليمن (8 أيام، انحلّ 10 فبراير 2026). اليمن بيئة رقابية، فقد يتكرّر. التطبيق حالياً يتصل مباشرة بـ `wdvsjpdrlvydoohvvhtx.supabase.co`.

إن عاد الحجب:
1. أنشئ Cloudflare Worker جديداً (reverse proxy) يشير للقاعدة الصحيحة:
   `const SUPABASE_URL = 'https://wdvsjpdrlvydoohvvhtx.supabase.co';`
2. انشره على Cloudflare (Workers & Pages → Create Worker → Deploy).
3. مرّر رابط الـ Worker للتطبيق عبر `--dart-define=SUPABASE_URL=<worker-url>` وأصدر تحديثاً. (لا حاجة لتعديل كود — فقط متغيّر البناء.)
ملاحظة: الحل الأبسط للمستخدمين وقت الحجب هو تغيير DNS (مثل Cloudflare 1.1.1.1) أو استخدام VPN، لأن الحجب كان على مستوى الـ DNS (DNS-level).

---

## 📝 6. نصائح وتوجيهات للوكلاء والمطورين المستقبليين (Tips for Future Agents)
* **التشغيل النظيف للأكواد:** بسبب تغيير اسم الحزمة محلياً، يجب أولاً **إلغاء تثبيت التطبيق تماماً من هاتفك** ثم تنفيذ رن كامل ونظيف:
  ```powershell
  flutter clean
  flutter run
  ```
* **تعديل المحافظات والمديريات:** المديريات مخزنة برمجياً في `AppStrings.governorateDistricts` في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart). عند الرغبة في التوسيع أو التعديل، يرجى التعديل مباشرة في تلك الخريطة (Map) لتنعكس تلقائياً في كافة الشاشات والواجهات! (عند إضافة متبرعين بمحافظة جديدة، يُملأ `governorate` تلقائياً من `district`.)
* **الوثائق الحية (اقرأها أولاً):** [CLAUDE.md](./CLAUDE.md) (قواعد العمل الإلزامية) + [PROJECT_LOG.md](./PROJECT_LOG.md) (سجل كل تعديل) + [docs/quality-refinement/QUALITY_REFINEMENT_PLAN.md](./docs/quality-refinement/QUALITY_REFINEMENT_PLAN.md) (الخطة وحالتها).
* **الإصدار:** لا ترفع `version` في `pubspec.yaml` إلا عند النشر الفعلي. القيمة الحالية `1.0.0+1` (أول إصدار للحزمة الجديدة).
* **الوصول لـ Supabase:** التوكن في `.env` (محمي)؛ التعديلات الخادمية عبر Management API. وثّق أي تغيير سكيما في [docs/sql/](./docs/sql/) والقسم 4 أعلاه.

هذا المشروع منظم ومرتب للغاية، ومعماريته النظيفة تجعل إضافة أي ميزات جديدة مهمة غاية في السهولة واليسر! 🩸🇾🇪🚀

