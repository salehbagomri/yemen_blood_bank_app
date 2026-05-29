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
تم إنشاء ملف توقيع رقمي جديد بالكامل وخاص باليمن (`yemen-release-key.jks`) وتم إعداده بنجاح في ملف `key.properties` ومزامنته محلياً.
* **بصمات التوقيع النشطة للتطبيق الجديد:**
  * **SHA-1:** `ED:C7:B3:52:3C:A8:57:D1:71:06:89:19:1C:50:27:F7:54:34:B0:0C`
  * **SHA-256:** `8A:E8:B9:80:F0:1B:64:CC:3C:70:70:C1:07:F7:34:0C:68:73:F7:75:52:09:EF:EA:37:63:39:E3:32:9C:6E:CB`

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
* **`add_hospital_bypassing_rls(...)`:** يُنشئ صف المستشفى ويملأ `governorate` من `p_district` تلقائياً.
* **RLS:** قراءة `donors` عامة للنشطين؛ INSERT للعامة (anon) بضوابط + للمستشفى/الأدمن؛ UPDATE بالملكية (`added_by`) أو الأدمن؛ DELETE للأدمن.
* **`governorates` / `districts` (إدارة المناطق المفعّلة):** جدولان يتحكم بهما الأدمن لإظهار/إخفاء المناطق (إطلاق تدريجي). `governorates(name, is_active, sort_order)` و`districts(id, governorate, name, is_active)`. RLS: قراءة عامة، كتابة للأدمن. دالة `district_in_use(gov,name)` تمنع تعديل/حذف مديرية مستخدمة. السكربت: [docs/sql/phase6_locations.sql](./docs/sql/phase6_locations.sql). في التطبيق: `LocationService`/`LocationProvider` (Cache-First، احتياطي `AppStrings` offline)، وشاشة الأدمن `manage_locations_screen.dart`. **كل القوائم المنسدلة الجغرافية تقرأ من `LocationProvider` لا من `AppStrings` مباشرة.**
* **⚠️ إرسال Arabic عبر Management API:** يجب إرسال جسم الطلب كـ UTF-8 bytes (`[Text.Encoding]::UTF8.GetBytes($json)`)؛ الترميز الافتراضي في PowerShell 5.1 يفسد العربية إلى `?`.

> ملاحظة: أي تعديل لاحق على السكيما يُوثَّق في ملف الـ SQL أعلاه وفي هذا القسم.

---

## 📝 5. نصائح وتوجيهات للوكلاء والمطورين المستقبليين (Tips for Future Agents)
* **التشغيل النظيف للأكواد:** بسبب تغيير اسم الحزمة محلياً، يجب أولاً **إلغاء تثبيت التطبيق تماماً من هاتفك** ثم تنفيذ رن كامل ونظيف:
  ```powershell
  flutter clean
  flutter run
  ```
* **تعديل المحافظات والمديريات:** المديريات مخزنة برمجياً في `AppStrings.governorateDistricts` في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart). عند الرغبة في التوسيع أو التعديل، يرجى التعديل مباشرة في تلك الخريطة (Map) لتنعكس تلقائياً في كافة الشاشات والواجهات! (عند إضافة متبرعين بمحافظة جديدة، يُملأ `governorate` تلقائياً من `district`.)
* **الوثائق الحية (اقرأها أولاً):** [CLAUDE.md](./CLAUDE.md) (قواعد العمل الإلزامية) + [PROJECT_LOG.md](./PROJECT_LOG.md) (سجل كل تعديل) + [docs/DEVELOPMENT_PLAN.md](./docs/DEVELOPMENT_PLAN.md) (الخطة وحالتها).
* **الإصدار:** لا ترفع `version` في `pubspec.yaml` إلا عند النشر الفعلي. القيمة الحالية `1.0.0+1` (أول إصدار للحزمة الجديدة).
* **الوصول لـ Supabase:** التوكن في `.env` (محمي)؛ التعديلات الخادمية عبر Management API. وثّق أي تغيير سكيما في [docs/sql/](./docs/sql/) والقسم 4 أعلاه.

هذا المشروع منظم ومرتب للغاية، ومعماريته النظيفة تجعل إضافة أي ميزات جديدة مهمة غاية في السهولة واليسر! 🩸🇾🇪🚀
