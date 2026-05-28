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

### ب. الهيكلية الجغرافية ثنائية المستويات للمحافظات والمديريات (Two-Tier Geographic Hierarchy)
* تم إضافة خريطة المديريات الشاملة لكافة الـ 22 محافظة في اليمن في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart).
* تم تحويل واجهة الإدخال والتعديل إلى **نظام قوائم منسدلة متتالية ذكية (Cascading Dropdowns)** في خمس شاشات رئيسية:
  1. [إضافة متبرع (Add Donor Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/donor/add_donor_screen.dart)
  2. [تعديل متبرع (Edit Donor Screen - للأدمن)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/edit_donor_screen.dart)
  3. [إضافة مستشفى (Add Hospital Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/add_hospital_screen.dart)
  4. [تعديل مستشفى (Edit Hospital Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/admin/edit_hospital_screen.dart)
  5. [شاشة البحث عن المتبرعين (Search Donors Screen)](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/screens/donor/search_donors_screen.dart)
* **ذكاء تخزين وفلترة الموقع (Backward Compatible):**
  * يتم دمج المحافظة والمديرية وحفظهما معاً كـ `"المحافظة - المديرية"` (مثل: `"حضرموت - المكلا"`) في حقل الـ `district` المفتوح لمنع أي مشاكل توافقية أو تطلب عمليات هجرة في الجداول.
  * تم تحديث دالة البحث RPC في قاعدة بيانات Supabase لتفهم الفلترة بالمطابقة الجزئية: `district = p_district OR district LIKE p_district || ' - %'` لتسترجع جميع متبرعي المحافظة والمديريات تلقائياً وبسرعة مذهلة!
  * تم تحديث الفلاتر المحلية لتدعم المطابقة باللاحقة في شاشات إدارة المتبرعين للأدمن والمستشفى.

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

---

## 🏗️ 3. المعمارية التقنية للمشروع (Technical Architecture)

يعتمد التطبيق على معمارية معيارية نظيفة وسهلة الصيانة:
1. **إدارة الحالة (State Management):** يستخدم حزمة `Provider` لإدارة الحالات المختلفة للتطبيق ومزامنة البيانات.
2. **حقن الاعتمادات (Dependency Injection):** يستخدم حزمة `GetIt` عبر كلاس مركزي [service_locator.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/config/service_locator.dart) لتسجيل الخدمات (Services) والـ Providers للوصول السهل.
3. **التخزين المؤقت وقاعدة البيانات المحلية (Local Caching):** يعتمد على قاعدة بيانات **Hive** السريعة جداً للعمل في وضع عدم الاتصال بالإنترنت (Offline Mode) وحفظ الإحصائيات وبيانات التبرع والتحقق منها دورياً.
4. **قاعدة البيانات البعيدة (Remote Database Backend):** يستهدف قاعدة بيانات **Supabase** عبر مكتبة `supabase_flutter`.

---

## ⚙️ 4. خطوات تهيئة قاعدة بيانات Supabase (Supabase Setup Script)

لضمان دقة كاملة، يُرجى التأكد من تنفيذ السكريبت التالي لتجهيز قاعدة البيانات لليمن وتعديل قيود الجنس وإضافة حقول التحديث التلقائي:

```sql
-- 1. تجهيز جداول قاعدة البيانات الأساسية مع تعديل قيد التحقق للجنس (ليطابق الأكواد 'male' و 'female')
CREATE TABLE IF NOT EXISTS public.donors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    phone_number_2 TEXT,
    phone_number_3 TEXT,
    blood_type TEXT NOT NULL,
    district TEXT NOT NULL,          -- يمثل "المحافظة - المديرية" في التطبيق الجديد
    age INTEGER NOT NULL CHECK (age >= 17 AND age <= 70),
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
    notes TEXT,
    is_available BOOLEAN DEFAULT true NOT NULL,
    last_donation_date TIMESTAMPTZ,
    suspended_until TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true NOT NULL,
    added_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. تصحيح قيود التحقق وإضافة أعمدة التحديث (في حال تم الإنشاء مسبقاً)
ALTER TABLE public.donors DROP CONSTRAINT IF EXISTS donors_gender_check;
ALTER TABLE public.donors ADD CONSTRAINT donors_gender_check CHECK (gender IN ('male', 'female'));
ALTER TABLE public.donors ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.hospitals ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now() NOT NULL;
ALTER TABLE public.admins ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now() NOT NULL;

-- 3. تحديث دالة البحث RPC لتشمل فلترة المديريات المتداخلة والمطابقة الجزئية
CREATE OR REPLACE FUNCTION public.search_donors(
    p_blood_type TEXT,
    p_district TEXT,
    p_available_only BOOLEAN
)
RETURNS SETOF public.donors AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.donors
    WHERE is_active = true
      AND (p_blood_type IS NULL OR blood_type = p_blood_type)
      AND (p_district IS NULL OR district = p_district OR district LIKE p_district || ' - %')
      AND (NOT p_available_only OR (suspended_until IS NULL OR suspended_until < now()));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📝 5. نصائح وتوجيهات للوكلاء والمطورين المستقبليين (Tips for Future Agents)
* **التشغيل النظيف للأكواد:** بسبب تغيير اسم الحزمة محلياً، يجب أولاً **إلغاء تثبيت التطبيق تماماً من هاتفك** ثم تنفيذ رن كامل ونظيف:
  ```powershell
  flutter clean
  flutter run
  ```
* **تعديل المحافظات والمديريات:** المديريات مخزنة برمجياً في `AppStrings.governorateDistricts` في [app_strings.dart](file:///c:/flutterprojects/yemen_blood_bank_app/yemen_blood_bank_app/lib/constants/app_strings.dart). عند الرغبة في التوسيع أو التعديل، يرجى التعديل مباشرة في تلك الخريطة (Map) لتنعكس تلقائياً في كافة الشاشات والواجهات!

هذا المشروع منظم ومرتب للغاية، ومعماريته النظيفة تجعل إضافة أي ميزات جديدة مهمة غاية في السهولة واليسر! 🩸🇾🇪🚀
