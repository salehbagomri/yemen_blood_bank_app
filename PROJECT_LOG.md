# 📜 سجل تطور مشروع بنك دم اليمن (Living Changelog)

> **ملف حي** يُحدَّث بعد كل جلسة عمل. الأحدث في الأعلى.
>
> أي وكيل ينهي تعديلاً يجب أن يضيف قيداً جديداً وفق القالب أدناه قبل push.
> راجع [CLAUDE.md](./CLAUDE.md) للقواعد الكاملة.

---

## 📋 قالب القيد الموحد

```
### YYYY-MM-DD — [النوع] عنوان موجز
- **الوصف:** ما تم بالضبط (2-4 أسطر، عربي).
- **الملفات:** قائمة الملفات الرئيسية المتأثرة (relative paths).
- **السبب/الدافع:** لماذا تم هذا التعديل.
- **اختبار:** analyze ✅ / يدوي على جهاز ✅ / لم يُختبر ⚠️.
- **Commit:** `abc1234`
```

**أنواع القيود:** `feat` | `fix` | `docs` | `chore` | `refactor` | `test` | `perf` | `release`

---

## 🗂️ السجل (الأحدث أولاً)

### 2026-05-30 — [fix] إصلاح فشل تحديث بيانات المستشفى من قِبل المدير
- **الوصف:** كان تحديث بيانات المستشفى يفشل بخطأ `PGRST204: Could not find the 'is_active' column of 'hospitals'` لأن `updateHospital` في `HospitalService` يُرسل عمود `is_active` غير الموجود في جدول `hospitals`. أُزيل العمود من الـ update payload، وعُطِّلت `toggleHospitalStatus` مؤقتاً، وأُزيل فلتر `is_active` من `getActiveHospitals`. أيضاً أُضيف تمرير `governorate` المحدّثة في `copyWith` بشاشة التعديل (كانت تبقى بالقيمة القديمة)، وأُصلح `copyWith` في `HospitalModel` للتفريق بين "لم يُمرَّر" و"null" للحقول الاختيارية.
- **الملفات:** `lib/services/hospital_service.dart`, `lib/screens/admin/edit_hospital_screen.dart`, `lib/models/hospital_model.dart`
- **السبب/الدافع:** بلاغ المستخدم: تحديث بيانات المستشفى يفشل. التحقق المباشر من سكيما DB أكّد عدم وجود عمود `is_active` في `hospitals`.
- **اختبار:** `flutter analyze` = 0 أخطاء. فحص أعمدة DB عبر Management API.

### 2026-05-30 — [fix] إخفاء رمز الدولة (+967) من عرض أرقام الهواتف في كل التطبيق
- **الوصف:** إضافة `Helpers.displayPhoneNumber()` تُزيل البادئات `+967`/`00967`/`967` للعرض فقط. طُبِّقت في: expandable_donor_card، donor_card، admin_donor_card (شاشة + نص المشاركة)، enhanced_hospital_card، report_detail_screen (عرض + نص النسخ)، export_service (Excel/PDF)، suspended_donors_screen. أزرار الاتصال/واتساب تبقى بالرقم الكامل.
- **الملفات:** `lib/utils/helpers.dart` + 7 ملفات عرض.
- **السبب/الدافع:** طلب المستخدم إخفاء رمز الدولة من عرض الأرقام على مستوى التطبيق كاملاً.
- **اختبار:** `flutter analyze` = 0 أخطاء/تحذيرات.
- **Commit:** `b5883ae`

### 2026-05-29 — [feat] إضافة رابط "شروط الاستخدام" داخل التطبيق + صفحات خصوصية/شروط رسمية
- **الوصف:** إضافة عنصر "شروط الاستخدام" لقائمة الإعدادات في الرئيسية (بجانب سياسة الخصوصية) يفتح `https://salehbagomri.github.io/yemen-blood-bank-privacy/terms.html`. وفي مستودع `yemen-blood-bank-privacy` المنفصل: إنشاء صفحة شروط الاستخدام وإعادة تصميم صفحتَي الخصوصية والشروط بأسلوب رسمي بلا أيقونات (مقتبَس من قالب tamm)، بخط التطبيق IBM Plex Sans Arabic، ثنائية اللغة مع فهرس جانبي.
- **الملفات:** `lib/screens/home/home_screen.dart` (هذا المستودع) + `index.html`/`terms.html`/`TERMS.md` في مستودع الخصوصية.
- **السبب/الدافع:** متطلب نشر (سياسة خصوصية + شروط استخدام) وربطهما داخل التطبيق.
- **اختبار:** `flutter analyze` = 0/0. الصفحات على GitHub Pages.
- **Commit:** `e7b916d`

### 2026-05-29 — [feat] إدارة المناطق المفعّلة (Admin-Managed Locations)
- **الوصف:** نقل المحافظات/المديريات إلى قاعدة البيانات ليتحكم بها الأدمن (للإطلاق التدريجي). جدولان `governorates` (22، تفعيل/إيقاف) و`districts` (161، إضافة/تفعيل/تعديل-مقيَّد) على Supabase + seed من AppStrings + RLS (قراءة عامة، كتابة للأدمن) + دالة `district_in_use()`. طبقة Dart: `LocationModel`، `LocationService` (CRUD/toggle مع حارس الاستخدام)، `LocationProvider` (Cache-First في Hive، احتياطي AppStrings offline). شاشة أدمن جديدة "إدارة المناطق" + مسار + بطاقة في لوحة الأدمن. تحويل 8 شاشات قوائم منسدلة من `AppStrings` إلى `LocationProvider` (شاشات التعديل تدمج القيمة الحالية إن كانت موقوفة).
- **الملفات:** `lib/models/location_model.dart`, `lib/services/location_service.dart`, `lib/providers/location_provider.dart`, `lib/screens/admin/manage_locations_screen.dart` (جديدة)، + `service_locator.dart`, `main.dart`, `cache_service.dart`, `app_router.dart`, `admin_dashboard_screen.dart`, `add_donor_screen.dart`, `edit_donor_screen.dart`, `add_hospital_screen.dart`, `edit_hospital_screen.dart`, `search_donors_screen.dart`, `manage_donors_screen.dart`, `manage_donors_hospital_screen.dart`, `advanced_search_screen.dart`, `docs/sql/phase6_locations.sql`
- **السبب/الدافع:** تمكين الإطلاق التدريجي (محافظة واحدة أولاً ثم توسعة) دون تحديث التطبيق، مع حماية البيانات (منع تعديل/حذف مديرية مستخدمة لأنها تكسر حقل donors.district).
- **اختبار:** `flutter analyze` = 0/0. الخلفية مُطبَّقة ومُتحقَّقة (22 محافظة، 161 مديرية، Arabic سليم). لم يُختبر على جهاز بعد.
- **ملاحظة تقنية:** إرسال Arabic عبر Management API يتطلب جسم UTF-8 bytes (الترميز الافتراضي في PowerShell يفسد العربية إلى '?').
- **Commit:** `2d7c644`

### 2026-05-29 — [docs] إعادة تعيين الإصدار + تحديث handoff بالبنية الوطنية
- **الوصف:** إعادة تعيين `version` في pubspec من `1.0.3+6` (تطبيق المهرة القديم) إلى **`1.0.0+1`** لأن الحزمة الجديدة تطبيق جديد على المتجر. تحديث شامل لـ `yemen_blood_bank_handoff.md` ليعكس: عمود `governorate` المفهرس، نموذج الحوكمة (مستشفى مقيّدة بمحافظتها + تقييد على مستوى التطبيق لا RLS)، الدوال الخادمية الثلاث، سياسة anon-insert، `mailer_autoconfirm`، Onboarding، صيغة الهاتف، وإصلاحات الومضة/overflow؛ مع تحديث قسم Schema للإشارة إلى ملف SQL القانوني وروابط الوثائق الحية.
- **الملفات:** `pubspec.yaml`, `yemen_blood_bank_handoff.md`
- **السبب/الدافع:** طلب المالك إعادة تعيين الإصدار + إغلاق مرحلة التحويل الوطني بتوثيق مرجعي نظيف.
- **اختبار:** لا يحتاج (إصدار + وثائق). الإصدار لا يُرفع إلا عند النشر.
- **Commit:** `459edc1`

### 2026-05-29 — [test] اجتياز اختبار الجهاز للمراحل 1→4 (النشر مؤجَّل)
- **الوصف:** أكّد المستخدم نجاح كل اختبارات الجهاز للسيناريوهات الأربعة والإصلاحات الأخيرة (Onboarding، إضافة متبرع + صيغة الهاتف، البحث بالمحافظة + العدّاد، دخول الإدارة بلا ومضة، إضافة مستشفى بعد autoconfirm، تقييد المستشفى بمحافظتها، اختفاء overflow الفلاتر).
- **الملفات:** `docs/DEVELOPMENT_PLAN.md` (حالة المرحلة 5)
- **السبب/الدافع:** توثيق اجتياز التحقق. قرار المستخدم: **عدم النشر الآن** والتطوير مستمر ⇒ لم يُرفع `version` (يبقى `1.0.3+6`)؛ يُرفع عند قرار النشر فقط.
- **اختبار:** يدوي على جهاز ✅ (المستخدم).
- **Commit:** `0f0ec98`

### 2026-05-29 — [perf] المرحلة 4: تحقق الأداء + تجميع إحصائي حسب المحافظة
- **الوصف:** تحقق أداء البحث المفهرس عبر إدخال 20,000 صف تجريبي على Supabase ثم `EXPLAIN ANALYZE`: أكّد استخدام `idx_donors_gov_blood` (Bitmap Index Scan، تنفيذ <1ms للاستعلام المباشر و~7ms لدالة `search_donors`)، ثم حُذفت كل صفوف الاختبار (0 متبقٍ). إضافة getter `governorateDistribution` في `StatisticsModel` يطوي مفاتيح "المحافظة - المديرية" إلى محافظات، واستخدامه في النظرة الوطنية للأدمن (توزيع المحافظات بدل 224 مديرية). مراجعة مدد كاش Hive والفلترة دون اتصال — كافية (للبحث fallback محلي بـ startsWith).
- **الملفات:** `lib/models/statistics_model.dart`, `lib/screens/admin/system_overview_screen.dart`, `docs/DEVELOPMENT_PLAN.md`
- **السبب/الدافع:** التأكد من جاهزية البنية للتوسع الوطني (آلاف السجلات) وتحسين قراءة الإحصائيات الوطنية.
- **اختبار:** `flutter analyze` = 0/0. تحقق أداء خادمي فعلي عند 20k. لم يُختبر على جهاز.
- **Commit:** `3d70f4a`

### 2026-05-29 — [fix] إزالة ومضة شاشة الدخول بعد تسجيل الدخول (admin/hospital)
- **الوصف:** بعد توضيح المستخدم (تصوير بطيء): الومضة هي **نموذج تسجيل الدخول** يظهر للحظة بين شاشة "جاري تسجيل الدخول" ولوحة الإدارة. السبب: `AuthProvider.signIn` يضبط `isLoading=false` ويُخطر المستمعين قبل الانتقال، فتُعيد شاشة الدخول رسم النموذج. الحل: علامة محلية `_navigating` في LoginScreen تبقي شاشة التحميل ظاهرة حتى يكتمل الانتقال. (أُبقي أيضاً تغيير الانتقال إلى `slideFromRight` لمنع كشف الخلفية أثناء الحركة.)
- **الملفات:** `lib/screens/auth/login_screen.dart`, `lib/config/app_router.dart`
- **السبب/الدافع:** بلاغ المستخدم: ومضة شاشة الدخول قبل الدخول للوحة.
- **اختبار:** `flutter analyze` = 0/0. يحتاج تأكيد بصري على الجهاز بعد hot restart. (شاشة "جاري تحميل البيانات" في اللوحة طبيعية — تحميل بيانات وليست خللاً.)
- **Commit:** `841c261` (الانتقال) + `c0853b3` (علامة _navigating)

### 2026-05-28 — [fix] إصلاح تجاوز (overflow) في قوائم الفلاتر المنسدلة
- **الوصف:** إضافة `isExpanded: true` لقائمة "المديرية" في شاشة إدارة متبرعي المستشفى (كانت تتجاوز 19px لأن قيم "المحافظة - المديرية" أطول من العرض)، ووقائياً لقائمة "المحافظة" في شاشة إدارة متبرعي الأدمن. الآن يُقصُّ النص (ellipsis) بدل التجاوز.
- **الملفات:** `lib/screens/hospital/manage_donors_hospital_screen.dart`, `lib/screens/admin/manage_donors_screen.dart`
- **السبب/الدافع:** بلاغ خطأ من المستخدم على الجهاز (RenderFlex overflowed by 19 pixels).
- **اختبار:** `flutter analyze` = 0/0. يحتاج تأكيد بصري على الجهاز.
- **Commit:** `2b4a4a4`

### 2026-05-28 — [chore] تفعيل التأكيد التلقائي للبريد في Supabase Auth
- **الوصف:** ضبط `mailer_autoconfirm = true` في إعدادات Supabase Auth (عبر Management API). كان `false` مع حد `rate_limit_email_sent = 2/ساعة` على البريد المدمج، مما سبّب خطأ "email rate limit exceeded" عند إضافة مستشفى (لأن `auth.signUp` يرسل بريد تأكيد).
- **الملفات:** لا كود — تغيير إعداد خادمي فقط.
- **السبب/الدافع:** الأدمن ينشئ حساب المستشفى ويسلّم كلمة المرور يدوياً، فتأكيد البريد غير ضروري. لا يوجد تسجيل ذاتي عام (المستخدمون يضيفون متبرعين بلا حساب)، فأثر الأمان ضئيل.
- **اختبار:** أُكِّد التغيير عبر API (mailer_autoconfirm=True). يحتاج المستخدم تأكيد نجاح إضافة مستشفى من التطبيق.
- **Commit:** `091880a`

### 2026-05-28 — [feat] المرحلة 3: تبسيط تجربة المستخدم العادي
- **الوصف:** شاشة البحث تستخدم الآن معامل `governorate` المفهرس (بحث بالمحافظة وحدها يعمل، والمديرية تضييق اختياري) مع تحديث نصوص الإرشاد. عدّاد النتائج يعرض "وُجد X متبرعاً في محافظة Y". توضيح صيغة الهاتف في إضافة متبرع: بادئة `+967` ونص مساعد "9 أرقام تبدأ بـ 7". دليل تعريفي (Onboarding) من 3 صفحات يظهر أول تشغيل فقط (flag في shared_preferences) مدموج في مسار splash. إضافة `helperText`/`prefixText` لـ CustomTextField.
- **الملفات:** `lib/screens/donor/search_donors_screen.dart`, `add_donor_screen.dart`, `lib/screens/onboarding/onboarding_screen.dart` (جديد), `lib/widgets/custom_text_field.dart`, `lib/config/app_router.dart`, `lib/main.dart`, `docs/DEVELOPMENT_PLAN.md`
- **السبب/الدافع:** تسهيل الاستخدام للمستخدم اليمني العادي. تُخطّيت القوائم القابلة للبحث (3.2) لأن التصميم المتتالي يبقي كل قائمة قصيرة (≤22)، وتوضيح الإيقاف (3.7) ورسائل العربية (3.5) موجودة أصلاً.
- **اختبار:** `flutter analyze` = 0 أخطاء، 0 تحذيرات. لم يُختبر على جهاز بعد (يُنصح بمسح بيانات التطبيق لرؤية Onboarding).
- **Commit:** `6813b77`

### 2026-05-28 — [feat] المرحلة 2: الحوكمة الجغرافية (تقييد المستشفى بمحافظتها)
- **الوصف:** `AuthProvider` يحمّل `hospitalGovernorate` عند الدخول (عبر `SupabaseService.getCurrentHospitalGovernorate` الدفاعية). شاشة إدارة متبرعي المستشفى تُقيَّد إلزامياً بمحافظتها مع عنوان "متبرعو محافظة X" وفلتر مديريات المحافظة فقط. لوحة المستشفى تحسب إحصائياتها لمحافظتها عبر مسار مُخصَّص في `DashboardProvider` (استعلام واحد + حساب محلي)، مع عرض المحافظة في الهيدر. تثبيت المحافظة (وقفلها) عند إضافة متبرع من حساب مستشفى. تحديث RPC `add_hospital_bypassing_rls` ليحفظ `governorate`. إعادة تسمية فلتر الأدمن "المديرية"→"المحافظة" (كان يفلتر بالمحافظة أصلاً). إضافة `enabled` لـ CustomDropdown. حذف حقل `_districts` غير المستخدم في edit_hospital_screen.
- **الملفات:** `lib/services/supabase_service.dart`, `lib/providers/auth_provider.dart`, `dashboard_provider.dart`, `lib/screens/hospital/manage_donors_hospital_screen.dart`, `hospital_dashboard_screen.dart`, `widgets/dashboard_header.dart`, `lib/screens/donor/add_donor_screen.dart`, `lib/screens/admin/manage_donors_screen.dart`, `edit_hospital_screen.dart`, `lib/widgets/custom_dropdown.dart`, `docs/sql/phase0_governorate_migration.sql`, `docs/DEVELOPMENT_PLAN.md`
- **السبب/الدافع:** تطبيق قرار الحوكمة (مستشفى مقيّدة بمحافظتها + أدمن عام). التقييد على مستوى التطبيق لأن RLS لا يصلح (SELECT عام للبحث الوطني).
- **اختبار:** `flutter analyze` = 0 أخطاء، 0 تحذيرات (213 info سابقة/تجميلية). لم يُختبر على جهاز بعد (يحتاج حساب مستشفى ببيانات).
- **Commit:** `c95dfd5`

### 2026-05-28 — [feat] المرحلة 1: مزامنة طبقة Dart مع البنية الجغرافية + إصلاحات
- **الوصف:** إضافة حقل `governorate` لـ DonorModel و HospitalModel (مشتق دفاعياً من `district` إن غاب، مع toJson/fromJson/copyWith). تمرير `p_governorate` في `DonorService.searchDonors` + دالتا `getDonorsByGovernorate` و `getGovernorateStats`. تحويل الإحصائيات للتجميع الخادمي عبر RPCs (`get_bloodtype_stats`، `get_district_stats`) في `statistics_service` و`donor_service` بدل جلب كل الصفوف. توحيد الفلترة المحلية على `startsWith` في `donor_provider` و`advanced_search_screen`. حفظ `governorate` في `HospitalService.updateHospital`. إنشاء سياسة INSERT للعامة (anon) على Supabase للسماح بالتسجيل بلا حساب.
- **الملفات:** `lib/models/donor_model.dart`, `hospital_model.dart`, `lib/services/donor_service.dart`, `statistics_service.dart`, `hospital_service.dart`, `lib/providers/donor_provider.dart`, `lib/screens/hospital/advanced_search_screen.dart`, `docs/sql/phase0_governorate_migration.sql`, `docs/DEVELOPMENT_PLAN.md`
- **السبب/الدافع:** إكمال التحويل الوطني على طبقة التطبيق بعد إرساء الخلفية. الإحصائيات الخادمية تحل مشكلة عدم التوسع. توحيد الفلترة يصلح خطأ عدم ظهور مديريات المحافظة في وضع عدم الاتصال.
- **اختبار:** `flutter analyze` = 0 أخطاء (211 info/warning سابقة كما هي)، اختبارات `donor_model_test` (16) ناجحة. RPCs مُنشأة ومُتحقَّق منها خادمياً. لم يُختبر على جهاز بعد.
- **⚠️ ملاحظة بيانات:** خلال الجلسة لوحظ أن صفوف المتبرعين التجريبية (5) أصبحت 0 رغم بقاء البنية والفهارس وحساب الأدمن. لم يُنفَّذ أي أمر حذف من جانبي. يحتاج تأكيد المستخدم.
- **Commit:** `67bb43e`

### 2026-05-28 — [feat] تطبيق المرحلة 0 (الخلفية) على Supabase
- **الوصف:** تنفيذ القسم (أ) من migration المرحلة 0 مباشرة على قاعدة بيانات Supabase عبر Management API: إضافة عمود `governorate` إلى `donors` و `hospitals`، backfill من حقل `district` (5 صفوف: حضرموت 4، عدن 1)، 3 فهارس، تحديث `search_donors` بمعامل `p_governorate`، ودالة `get_governorate_stats` خادمية. تم التحقق من كل شيء (0 صفوف بلا محافظة).
- **الملفات:** `docs/sql/phase0_governorate_migration.sql` (تحديث ملاحظات)، `docs/DEVELOPMENT_PLAN.md` (حالة + اكتشافات)
- **السبب/الدافع:** إرساء أساس البنية الجغرافية الوطنية قبل تعديلات Dart. اكتشاف: تقييد المستشفى بالمحافظة لا يصلح عبر RLS (SELECT عام للبحث الوطني) ⇒ يُنقل لطبقة التطبيق. وتناقض في سياسة INSERT (تتطلب تسجيل دخول بينما الإضافة العامة متاحة) يحتاج قراراً.
- **اختبار:** تحقق خادمي عبر استعلامات قراءة (العمود/الفهارس/الدوال تعمل). لم يُختبر على التطبيق بعد.
- **Commit:** `57acaa2`

### 2026-05-28 — [docs] خطة التطوير الوطنية الشاملة + سكربت المرحلة 0
- **الوصف:** إنشاء خطة تطوير مرحلية شاملة لتحويل التطبيق من نطاق محافظة واحدة إلى اليمن كاملاً (6 مراحل: خلفي، نماذج/خدمات، حوكمة جغرافية، تبسيط UX، جودة/أداء، تحقق). إضافة سكربت SQL للمرحلة 0 (عمود governorate + backfill + فهارس + تحديث RPC search_donors + دالة إحصائيات GROUP BY + مسودة RLS لتقييد المستشفى بمحافظتها).
- **الملفات:** `docs/DEVELOPMENT_PLAN.md`, `docs/sql/phase0_governorate_migration.sql`
- **السبب/الدافع:** التحويل الوطني المنجَز كان سطحياً؛ هذه الخطة تكمل الجوهر (المستشفى حالياً ترى كل اليمن، الإحصائيات لا تتوسع، تضارب في الفلترة المحلية). القرارات: عمود محافظة مستقل، مستشفى مقيّدة بمحافظتها + أدمن عام، المتبرع يبقى بلا حساب.
- **اختبار:** لا يحتاج (تخطيط + SQL لم يُشغّل بعد على Supabase).
- **Commit:** `950860b`

### 2026-05-28 — [docs] إنشاء نظام التوثيق والمرجع الحي
- **الوصف:** إنشاء ملف `CLAUDE.md` كتعليمات ثابتة تُحمَّل تلقائياً لكل وكيل يعمل على المشروع، وإنشاء `PROJECT_LOG.md` (هذا الملف) كسجل حي يُحدَّث بعد كل جلسة. التعليمات تشمل سير العمل الإلزامي، الأنماط المعمارية المحمية، صيغ commit الموحدة، والممنوعات.
- **الملفات:** `CLAUDE.md`, `PROJECT_LOG.md`
- **السبب/الدافع:** ضمان اتساق سلوك الوكلاء المختلفين عبر الجلسات، حفظ المكاسب المعمارية (cascading dropdowns + defensive parsing)، وتوفير سجل تاريخي يسهّل على أي مطور/وكيل لاحق فهم مسار التطوير دون الرجوع لـ `git log` فقط.
- **اختبار:** لا يحتاج (وثائق فقط) — تحقق وظيفي: في الجلسة القادمة يجب أن يستشهد Claude Code بـ `CLAUDE.md` تلقائياً.
- **Commit:** `8366ea8`

---

## 📚 ما قبل بدء السجل الحي (2026-05-28)

التغييرات السابقة موثقة بشكل تفصيلي في [yemen_blood_bank_handoff.md](./yemen_blood_bank_handoff.md) وفي `git log`. أبرز آخر commits:

| Commit | النوع | الوصف |
|--------|------|--------|
| `e0b1e29` | docs | تحديث handoff بنظام المستويين والـ defensive parsing |
| `f19c5b5` | fix | إزالة `_onDistrictChanged` غير المستخدم في شاشة البحث |
| `4243b22` | feat | قوائم منسدلة متتالية في `SearchDonorsScreen` |
| `a4883cd` | fix | منطق `updatedAt` دفاعي في كل النماذج |
| `dfc216a` | feat | الهيكلية الجغرافية ثنائية المستويات + إصلاح overflow في dashboard الأدمن |

**معالم سابقة كبرى (راجع handoff للتفاصيل):**
- إعادة التسمية الكاملة من "بنك دم المهرة" إلى "بنك دم اليمن".
- تغيير معرف الحزمة Android/iOS إلى `com.bagomri.yemenbloodbank`.
- توسعة النطاق من مديريات المهرة إلى 22 محافظة يمنية.
- إنشاء مفتاح توقيع جديد `yemen-release-key.jks`.
- تحديث دالة البحث RPC في Supabase لدعم المطابقة الجزئية.
