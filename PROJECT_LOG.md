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

### 2026-06-06 — [fix] دالة خادمة مخصصة ومحروسة جغرافياً لتحديث تاريخ التبرع للمستشفيات
- **الوصف:** المشكلة (قيد RLS لملكية الصف منع المستشفى من تحديث تاريخ تبرّع متبرع سجّل ذاتياً لأن added_by ليس للمستشفى)، الحل (إنشاء واستدعاء RPC مخصصة باسم update_donor_donation_date بتصنيف SECURITY DEFINER ومحروسة جغرافياً للتأكد من تطابق المحافظة بين المستشفى والمتبرع، مع تحسين معالجة الأخطاء محلياً وعرض snackbar للمستشفى وتنظيف حالة الخطأ، وحل مشكلة زر إعادة المحاولة عبر فرض التحديث forceRefresh وتجنب شاشة الخطأ الكاملة إذا لم تكن القائمة فارغة)، التحقق (اختبار اختراق محلي للتأكد من منع التحديث خارج المحافظة + اختبار يدوي ناجح).
- **الملفات:** docs/sql/phase10_update_donor_donation_date.sql, yemen_blood_bank_handoff.md, lib/services/donor_service.dart, lib/providers/donor_provider.dart, lib/widgets/expandable_donor_card.dart, lib/screens/hospital/manage_donors_hospital_screen.dart, lib/screens/admin/manage_donors_screen.dart, PROJECT_LOG.md
- **السبب/الدافع:** منع تعطل تسجيل تبرعات المتبرعين الذين سجلوا ذاتياً من قبل المستشفيات مع الحفاظ على الأمان الجغرافي.
- **اختبار:** analyze ✅ / اختبار يدوي واختبار اختراق ✅.
- **Commit:** `b08a555`

### 2026-06-06 — [test] التحقق النهائي الشامل لمراجعة الجودة (إغلاق الخطة)
- **الوصف:** بوابة تحقّق نهائية بعد إتمام المراحل 1-9. آلي: analyze=0، 198 اختبار/0 فشل، build apk release ناجح، build appbundle ناجح (تجاوز مشكلة dex index). يدوي على جهاز: السيناريوهات الأربعة (طالب/متبرع/مستشفى/أدمن) + RTL + عدم الاتصال + شاشة حول الديناميكية — كلها ناجحة. تم إصلاح خطأ RLS عند تحديث المستشفى لتاريخ التبرع عبر RPC مخصصة ومحكمة جغرافياً، وتحسين زر إعادة المحاولة ومعالجة الأخطاء.
- **الملفات:** PROJECT_LOG.md, docs/PROJECT_STATUS.md, yemen_blood_bank_handoff.md, docs/quality-refinement/QUALITY_REFINEMENT_PLAN.md, docs/quality-refinement/BRIEF_phase10_final_verification.md, lib/services/donor_service.dart, lib/providers/donor_provider.dart, lib/widgets/expandable_donor_card.dart, lib/screens/hospital/manage_donors_hospital_screen.dart, lib/screens/admin/manage_donors_screen.dart
- **السبب/الدافع:** إغلاق رسمي لخطة رفع الجودة بعد التحقّق الشامل وإصلاح خلل RLS المكتشف أثناء الفحص اليدوي.
- **اختبار:** آلي + يدوي شامل (انظر أعلاه).
- **Commit:** `b25b819`

### 2026-06-06 — [docs] إزالة بصمة keystore المحروقة بالكامل ونقل المذكرة الأخيرة
- **الوصف:** استبدال بصمات keystore المحروقة في FIREBASE_SETUP_GUIDE.md و PUBLISHING_GUIDE.md بإشارة مرجعية موحدة تشير إلى yemen_blood_bank_handoff.md. نقل مذكرة BRIEF_phase9_docs.md إلى docs/quality-refinement/ للحفاظ على الهيكلية النظيفة.
- **الملفات:** docs/FIREBASE_SETUP_GUIDE.md, docs/PUBLISHING_GUIDE.md, docs/quality-refinement/BRIEF_phase9_docs.md
- **السبب/الدافع:** تلافي تكرار بصمات keystore المحروقة أو حدوث تضارب في المعلومات البرمجية لاحقاً.
- **اختبار:** analyze = 0 للتأكيد ✅.
- **Commit:** `fd01398`

### 2026-06-06 — [docs] تنظيف التوثيق: أرشفة التقارير القديمة + مصدر حيّ واحد
- **الوصف:** نقل 5 تقارير قديمة متناقضة (ديسمبر 2025) إلى docs/archive/ بوسم «تاريخي لا يُعتمد»، وتنظيم مذكّرات مراجعة الجودة في docs/quality-refinement/. إعادة كتابة PROJECT_STATUS.md كمصدر حيّ واحد دقيق يعكس الواقع (analyze=0، 198 اختبار، نطاق وطني) مع قسم «القيود المعروفة» صريح. وسم الأدلة الإجرائية. إضافة قسم القيود المعروفة في handoff. إزالة الاعتماد على بصمات keystore المحروق من الملفات الحيّة (تبقى في الأرشيف الموسوم فقط).
- **الملفات:** docs/archive/* (منقولة), docs/quality-refinement/* (منقولة), docs/PROJECT_STATUS.md (إعادة كتابة), docs/PUBLISHING_GUIDE.md, docs/FIREBASE_SETUP_GUIDE.md, yemen_blood_bank_handoff.md
- **السبب/الدافع:** التوثيق كان متأخّراً عن الواقع ومتناقضاً ومضلّلاً لأي وكيل قادم.
- **اختبار:** لا كود (توثيق). analyze = 0 للتأكيد.
- **Commit:** `0878380`

### 2026-06-06 — [test] إصلاح الاختبارات المهجورة وتوسيع تغطية النماذج
- **الوصف:** إصلاح اختبارين فاشلين في constants_test (كانا يفحصان 9 مديريات مهرة قديمة بينما AppStrings.districts صار 22 محافظة). إضافة اختبارات وحدة جديدة: HospitalModel وAdminModel (المنطق الدفاعي: updated_at→created_at، اشتقاق governorate من district، null الدفاعي) وBannerModel (النوع المزدوج صوري/نصي). ربطها بالمجمّع widget_test.
- **الملفات:** `test/unit/constants_test.dart`, `test/unit/hospital_model_test.dart`, `test/unit/admin_model_test.dart`, `test/unit/banner_model_test.dart`, `test/widget_test.dart`
- **السبب/الدافع:** اختبارات مهجورة من حقبة المهرة + ثغرات تغطية في نماذج حرجة.
- **اختبار:** flutter test كل الاختبارات تمرّ (198 اختبار ناجح) ✅ / analyze 0 ✅ / تغطية: 76.39%.
- **Commit:** `79de821`

### 2026-06-03 — [refactor] تنظيف كامل لتحذيرات flutter analyze (وصول لصفر)
- **الوصف:** إزالة كل الـ 179 info على 3 دفعات: (1) ~163 withOpacity ⟶ withValues، (2) متفرقات صغيرة (print ⟶ debugPrint، unnecessary_import، prefer_initializing_formals، unnecessary_underscores، strict_top_level_inference، value ⟶ initialValue)، (3) ترقية share_plus إلى SharePlus.instance.share(ShareParams) مع اختبار يدوي. النتيجة: flutter analyze = 0 issues تماماً.
- **الملفات:** عشرات الملفات في `lib/` (شاشات/widgets/services/utils/models) + `test/`
- **السبب/الدافع:** الوصول لصفر تحذيرات (نظافة كاملة)، خاصة استبدال API مُلغاة.
- **اختبار:** analyze = 0 ✅ / مراجعة بصرية للشفافيات ✅ / مشاركة نص+ملف تعملان ✅.
- **Commit:** `c651de2`, `d47e398`, `5a48823`

### 2026-06-03 — [fix] معالجة 12 حالة BuildContext across async gaps
- **الوصف:** إضافة حراسة mounted/context.mounted للحالات الـ 12 من use_build_context_synchronously، مصنّفة في 4 أنماط: Future.microtask في initState (7)، تحويل .then إلى async/await مع فحص context.mounted في شاشات المتبرعين (2)، await متعدّد بفحص ناقص (2)، Future.delayed مع GlobalKey (1).
- **الملفات:** `lib/screens/admin/manage_donors_screen.dart`, `lib/screens/hospital/blood_type_report_screen.dart`, `lib/screens/hospital/hospital_dashboard_screen.dart`, `lib/screens/hospital/manage_donors_hospital_screen.dart`, `lib/screens/hospital/reports/blood_type_detailed_report_screen.dart`, `lib/screens/admin/report_detail_screen.dart`, `lib/screens/info/about_screen.dart`, `lib/widgets/expandable_donor_card.dart`
- **السبب/الدافع:** مخاطر runtime حقيقية (استخدام context لـ widget قد يكون أُغلق).
- **اختبار:** analyze: 0 use_build_context_synchronously، الإجمالي 179 info ✅ / يدوي: فتح/إغلاق سريع بلا تعطّل ✅.
- **Commit:** `<hash>`

### 2026-06-03 — [perf] جعل إعادة ترتيب البانرات عملية ذرّية عبر RPC
- **الوصف:** استبدال حلقة UPDATE المتسلسلة (N رحلات شبكة، غير ذرّية) في `banner_service.reorderBanners` بدالة RPC واحدة `reorder_banners(p_ids UUID[])` تحدّث كل الترتيب في معاملة واحدة عبر unnest WITH ORDINALITY، محصورة للأدمن. إضافة حارس في واجهة الإدارة لتعطيل أزرار النقل أثناء جاري التحميل لمنع الضغط المتكرر.
- **الملفات:** `docs/sql/phase9_reorder_banners.sql` (جديد), `lib/services/banner_service.dart`, `lib/screens/admin/manage_banners_screen.dart`
- **السبب/الدافع:** الحلقة المتسلسلة بطيئة وغير ذرّية (فشل في المنتصف يكسر الترتيب).
- **اختبار:** SQL مُطبَّق ومُتحقَّق ✅ / analyze 0/0 ✅ / يدوي: ترتيب يثبت ✅.
- **Commit:** `<hash>`

### 2026-06-03 — [docs] وسم ملف PROJECT_STATUS.md كتقرير تاريخي
- **الوصف:** إضافة تنبيه في أعلى مستند `docs/PROJECT_STATUS.md` يوضح أن أرقام الإصدار وحالة الجاهزية المذكورة فيه هي أرقام تاريخية سابقة لمراجعة الجودة الحالية، وأن مصدر الإصدار الوحيد هو `pubspec.yaml`.
- **الملفات:** `docs/PROJECT_STATUS.md`
- **السبب/الدافع:** تلافي تضارب المعلومات حول إصدار وجاهزية التطبيق.
- **اختبار:** لا يحتاج (توثيق فقط).
- **Commit:** `<hash>`

### 2026-06-03 — [refactor] جعل رقم إصدار التطبيق ديناميكياً وتوحيد مصدر الحقيقة
- **الوصف:** تعديل شاشة "حول التطبيق" لتقرأ رقم الإصدار ديناميكياً من `pubspec.yaml` باستخدام حزمة `package_info_plus` بدلاً من النص الثابت. إضافة حزمة `package_info_plus` للاعتمادات، وتحديث ملفات التوثيق (`CLAUDE.md`, `RELEASE_PREPARATION_REPORT.md`, `FIREBASE_CONFIGURATION_REPORT.md`) لتوضيح أن `pubspec.yaml` هو المصدر الوحيد والصحيح للإصدار.
- **الملفات:** `lib/screens/info/about_screen.dart`, `pubspec.yaml`, `CLAUDE.md`, `docs/RELEASE_PREPARATION_REPORT.md`, `docs/FIREBASE_CONFIGURATION_REPORT.md`
- **السبب/الدافع:** تضارب أرقام الإصدار في ملفات مختلفة؛ توحيد مصدر الإصدار وجعله يقرأ تلقائياً.
- **اختبار:** analyze ✅ / يدوي ⚠️.
- **Commit:** `<hash>`

### 2026-06-03 — [chore] إزالة ملف MainActivity الشبح من مسار الحزمة القديم
- **الوصف:** حذف ملف `MainActivity` والمجلدات الفرعية المتبقية في مسار الحزمة القديم `com.bagomri.yemen_blood_bank` (بقايا عملية إعادة التسمية السابقة). الملف الفعلي للتطبيق نشط في المسار الصحيح `com.bagomri.yemenbloodbank` وعملية البناء لم تتأثر بالحذف.
- **الملفات:** `android/app/src/main/kotlin/com/bagomri/yemen_blood_bank/MainActivity.kt` (محذوف)
- **السبب/الدافع:** تنظيف الملفات القديمة والمتروكة وتجنب تشتيت المطورين أو تداخل المسارات.
- **اختبار:** analyze ✅ / build apk release ✅.
- **Commit:** `<hash>`

### 2026-06-03 — [test] تدقيق أمان RLS واختبار اختراق فعلي لعمليات الكتابة
- **الوصف:** 7 اختبارات اختراق فعلية (بنمط ROLLBACK آمن) على سياسات RLS لجدول donors،
  بمحاكاة مستشفى حقيقي (ابن سيناء/حضرموت) وزائر anon. غُطّيت: التعديل عبر المحافظات،
  التعديل داخل المحافظة بلا ملكية، الحذف، تعديل/حذف anon، انتحال added_by، وحراسة
  دالة suspend_donor_by_hospital (منع خارجي + سماح داخلي). كل النتائج طابقت المتوقَّع.
  الخلاصة: طبقة الكتابة محكمة رغم أن مفتاح anon علني. توثيق القراءة العامة كقرار
  معماري مقصود (لا تُضيّق SELECT). توصية Rate Limiting عبر Cloudflare Worker للنشر.
- **الملفات:** `yemen_blood_bank_handoff.md`, `docs/QUALITY_REFINEMENT_PLAN.md`,
  `docs/BRIEF_phase4_rls_audit.md`
- **السبب/الدافع:** المفتاح anon علني ⇒ RLS هو الدفاع الوحيد. تحقّق فعلي لا ورقي.
- **اختبار:** 7 اختبارات SQL Editor، كلها ROLLBACK، صفر تغيير على البيانات.
- **Commit:** `<hash>`

### 2026-06-03 — [fix] تأمين بيانات التوقيع وإزالة الأسرار من المستودع العام
- **الوصف:** إزالة KEYSTORE_INFO.txt من تعقّب Git (كان يحوي كلمات مرور صريحة)، إنشاء keystore جديد بكلمة مرور جديدة واعتبار القديم محروقاً (التطبيق غير منشور بعد فلا تبعات)، تحديث key.properties، وتوثيق بصمة توقيع واحدة نظيفة. (تأمين مفتاح Supabase anon مؤجَّل لما قبل النشر.)
- **الملفات:** `.gitignore`, `android/key.properties`, `android/keystore/yemen-release-key-v2.jks` (غير مرفوع), `yemen_blood_bank_handoff.md`, `docs/FIREBASE_SETUP_GUIDE.md`, `docs/SHA_FINGERPRINTS.txt`
- **السبب/الدافع:** فحص أمني كشف رفع كلمات مرور keystore على مستودع عام. المعالجة بإبطال المفتاح المكشوف بالكامل.
- **اختبار:** analyze ✅ / build apk release موقَّع بالمفتاح الجديد ✅ / يدوي ⚠️.
- **Commit:** `4f94bf8`

### 2026-06-02 — [fix] إصلاح خطأ Colors.black55 وتحديث المحاذير الملغاة في شاشة إدارة البانرات
- **الوصف:** تصحيح الخطأ الإملائي للون `Colors.black55` إلى `Colors.black54` وتجاوز التحذيرات الخاصة بالمكونات الملغاة (deprecations) باستبدال المعلمة `value` بـ `initialValue` في حقول الاختيار، و`activeColor` بـ `activeThumbColor` في المفاتيح، وتحويل أزرار الراديو للإجراء إلى قائمة منسدلة `DropdownButtonFormField` نظيفة وأكثر توافقاً.
- **الملفات:** `lib/screens/admin/manage_banners_screen.dart`
- **السبب/الدافع:** بلاغ المحلل عن خطأ بناء بسبب `Colors.black55` بالإضافة إلى تحذيرات deprecation.
- **اختبار:** analyze ✅ / يدوي على جهاز ⚠️.
- **Commit:** `1ebf492`

### 2026-06-02 — [feat] نظام البانرات المزدوج (صوري ونصي) المدار للأدمن
- **الوصف:** توسيع نظام البانرات لدعم البانرات النصية بجانب الصورية؛ تم تعديل الجدول في Supabase ليكون مسار الصورة اختيارياً وإضافة حقول للأيقونة (`icon_name`) والتدرج اللوني للخلفية (`bg_gradient`) مع رفع 5 بنرات توعوية وإحصائية كـ seed. تعديل النموذج والخدمة والـ Provider والـ Cache والواجهة الأمامية والأدمن لتمكين التحكم الكامل وتفعيل/إيقاف وتعديل البانرات النصية والصورية.
- **الملفات:** `docs/sql/phase8_banners_dual_type.sql`, `lib/models/banner_model.dart`, `lib/services/banner_service.dart`, `lib/providers/banner_provider.dart`, `lib/screens/home/widgets/home_banner_slider.dart`, `lib/screens/admin/manage_banners_screen.dart`.
- **السبب/الدافع:** تمكين المدير من كتابة تنويهات ونصوص توعوية مباشرة بأيقونة وتدرج لوني دون الحاجة لتصميم ورفع صور.
- **اختبار:** analyze ✅ / يدوي على جهاز ⚠️.
- **Commit:** `95a6a86`

### 2026-06-02 — [feat] نظام البانرات الديناميكي المدار للأدمن وسلايدر الرئيسية
- **الوصف:** بناء نظام البانرات بالكامل: جدول banners وسياسات RLS وbucket تخزين الصور على Supabase. إضافة نماذج البيانات والخدمات والـ Providers مع دعم التخزين المؤقت الكاش (Hive). تصميم شاشة كاملة للأدمن لإدارة البانرات (إضافة، تعديل، حذف، تفعيل، ترتيب، وجدولة زمنية)، وربطها بالصفحة الرئيسية بسلايدر تفاعلي ذكي يدعم السحب والإيقاف المؤقت عند اللمس.
- **الملفات:** `docs/sql/phase8_banners.sql`, `lib/models/banner_model.dart`, `lib/services/banner_service.dart`, `lib/providers/banner_provider.dart`, `lib/services/cache_service.dart`, `lib/screens/admin/manage_banners_screen.dart`, `lib/screens/home/widgets/home_banner_slider.dart`, `lib/screens/home/home_screen.dart` + 6 ملفات إعدادات وواجهات.
- **السبب/الدافع:** متطلب تحسين السلايدر ليصبح احترافياً ويديره الأدمن بالكامل ديناميكياً دون تحديث التطبيق.
- **اختبار:** analyze ✅ / يدوي على جهاز ⚠️.
- **Commit:** `9c418c5`

### 2026-06-02 — [feat] تعديل وتجميل الفوتر وتحديث إصدار التطبيق
- **الوصف:** رفع عبارة "صنع بحب لأهالي اليمن" والخط الفاصل للأعلى لتقليص المساحات الفارغة، وحذف عبارة "بواسطة Saleh Bagomri" بالكامل من الواجهة الرئيسية مع إزالة دالة _launchURL غير المستخدمة لتفادي تنبيهات التحليل. وتحديث رقم الإصدار في شاشة "حول التطبيق" ليكون `1.0.0` بدلاً من `1.0.3` ليتناسب مع المتجر.
- **الملفات:** `lib/screens/home/home_screen.dart`, `lib/screens/info/about_screen.dart`
- **السبب/الدافع:** طلب المستخدم رفع الفوتر، إزالة اسم المطور، وتعديل الإصدار لـ 1.0.0.
- **اختبار:** `flutter analyze` ✅ / يدوي على جهاز ⚠️.
- **Commit:** `15804e7`

### 2026-06-02 — [chore] توليد وتطبيق أيقونات التطبيق الجديدة
- **الوصف:** تشغيل أداة `flutter_launcher_icons` لتوليد وتطبيق أيقونات التطبيق الجديدة لمنصتي Android و iOS بناءً على التغييرات الجديدة التي أجراها المستخدم على ملفات الأيقونات الأساسية `icon.png` و `logo-m.svg` في مجلد الأصول.
- **الملفات:** `assets/icons/icon.png`, `assets/icons/logo-m.svg`, وملفات الأيقونات المولدة تلقائياً تحت `android/app/src/main/res/` و `ios/Runner/Assets.xcassets/`.
- **السبب/الدافع:** طلب المستخدم لتطبيق الأيقونات الجديدة على التطبيق بالكامل بعد استبداله للملفات في مجلد `icons` بنفس الأسماء السابقة.
- **اختبار:** `flutter analyze` ✅ / توليد ناجح عبر CLI ✅.
- **Commit:** `0d721f1`

### 2026-05-30 — [fix] حل مشكلة فشل إيقاف المتبرع للمستشفيات بسبب RLS
- **الوصف:** إنشاء دالة RPC جديدة خادميًا (`suspend_donor_by_hospital`) تعمل بصفة `SECURITY DEFINER` لتجاوز RLS وتحديث حالة إيقاف المتبرع وتاريخ تبرعه الأخير بشكل آمن، مع فرض ضوابط أمنية وجغرافية قوية (يُسمح فقط للأدمن أو المستشفى التابع لنفس محافظة المتبرع). تحديث خدمة `DonorService.suspendDonorFor6Months` لاستدعاء هذه الدالة بدلاً من إجراء `UPDATE` المباشر المرفوض سابقًا بـ RLS.
- **الملفات:** `lib/services/donor_service.dart`, `docs/sql/phase7_suspend_donor_fix.sql`
- **السبب/الدافع:** شكوى المستخدم من ظهور خطأ `PGRST116: Cannot coerce the result to a single JSON object` مع "0 rows" عند محاولة إدارة المستشفى إيقاف متبرع (تسجيل تبرعه) لم تقم بإضافته بنفسها بسبب تقييد RLS للتحديث بالمنشئ.
- **اختبار:** analyze ✅ / يدوي على جهاز ✅.
- **Commit:** `b4f9446`

### 2026-05-30 — [feat] تحسين تجربة المستخدم: إحصائيات المتبرعين 2×2 وقسم التطوير التلقائي السكرول
- **الوصف:** (1) إعادة تصميم إحصائيات إدارة المتبرعين لتكون شبكة 2×2 لتفادي تداخل واقتطاع نصوص التصنيفات (الإجمالي، متاح، موقوف، معطل). (2) تحويل قسم التطوير والدعم الفني في شاشة "حول التطبيق" ليكون قابلاً للطي/الفتح. (3) تفعيل السكرول التلقائي لأعلى (Auto-Scroll) عند فتح قسم التطوير ليصبح المحتوى ظاهراً بالكامل تلقائياً دون الحاجة لسكرول يدوي.
- **الملفات:** `lib/screens/admin/manage_donors_screen.dart`, `lib/screens/info/about_screen.dart`
- **السبب/الدافع:** ملاحظات المستخدم حول اقتطاع نصوص الإحصائيات الأربعة للمتبرعين، وصعوبة قراءة تفاصيل الدعم الفني دون سكرول يدوي بعد فتحه.
- **اختبار:** analyze ✅ / يدوي على جهاز ✅.
- **Commit:** `a2c3269`

### 2026-05-30 — [fix] إصلاح تحديث بيانات المستشفى + كارد قابل للطي
- **الوصف:** (1) إصلاح خطأ `PGRST204: is_active column not found` بإزالة العمود غير الموجود من الاستعلام. (2) إضافة `governorate` المفقودة في `copyWith`. (3) إصلاح `copyWith` للحقول الاختيارية (sentinel pattern). (4) إصلاح overflow بـ 0.9px في إحصائيات إدارة المستشفيات. (5) تحويل `EnhancedHospitalCard` من `StatelessWidget` إلى `StatefulWidget` قابل للطي/الفتح مثل `AdminDonorCard` — الهيدر (اسم + مديرية + حالة) ظاهر دائماً، والتفاصيل (بريد/هاتف/تاريخ) + الإجراءات (تعديل/حذف/نسخ) تظهر عند الضغط. (6) توحيد تصميم الإحصائيات السريعة في شاشة إدارة المتبرعين (بطاقة gradient مع مربعات أيقونات) مطابقة لشاشة المستشفيات. (7) إضافة أزرار اتصال/واتساب سريعة في `AdminDonorCard` لكل أرقام المتبرع.
- **الملفات:** `lib/services/hospital_service.dart`, `lib/screens/admin/edit_hospital_screen.dart`, `lib/models/hospital_model.dart`, `lib/screens/admin/manage_hospitals_screen.dart`, `lib/screens/admin/widgets/enhanced_hospital_card.dart`, `lib/screens/admin/manage_donors_screen.dart`, `lib/screens/admin/widgets/admin_donor_card.dart`
- **السبب/الدافع:** بلاغات المستخدم: فشل تحديث المستشفى + overflow + طلب تحسين الكارد ليكون قابل للطي + توحيد تصميم الإحصائيات + إضافة تواصل سريع مع المتبرعين.
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
