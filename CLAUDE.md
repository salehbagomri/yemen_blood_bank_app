# 🤖 تعليمات الوكلاء (Agent Instructions) — مشروع بنك دم اليمن

> هذا الملف يُحمَّل تلقائياً في سياق كل جلسة عمل. أي وكيل (Claude Code أو غيره) يعمل على هذا المشروع **مُلزَم** بقراءة هذه التعليمات وتطبيقها قبل وبعد أي تعديل.

---

## 1. تعريف المشروع (Quick Profile)

| الحقل | القيمة |
|------|--------|
| الاسم | بنك دم اليمن (Yemen Blood Bank) |
| النوع | تطبيق Flutter لإدارة متبرعي الدم |
| الحزمة | `com.bagomri.yemenbloodbank` |
| الـ Backend | Supabase (PostgreSQL + RPC) |
| التخزين المحلي | Hive |
| إدارة الحالة | Provider |
| حقن الاعتمادات | GetIt (`lib/config/service_locator.dart`) |
| النطاق الجغرافي | 22 محافظة يمنية بنظام مديريات ثنائي المستويات |
| اللغة الأساسية | العربية (RTL) |
| الفرع الرئيسي | `main` (push مباشر — لا فروع PR) |
| الريموت | `https://github.com/salehbagomri/yemen_blood_bank_app.git` |

**مراجع تكميلية إلزامية:**
- 📘 [yemen_blood_bank_handoff.md](./yemen_blood_bank_handoff.md) — صورة شاملة ثابتة للمشروع (اقرأها أول مرة فقط).
- 📜 [PROJECT_LOG.md](./PROJECT_LOG.md) — السجل الحي لكل التغييرات (اقرأ آخر 5 قيود قبل أي عمل).

---

## 2. ⚠️ سير العمل الإلزامي بعد كل جلسة (Mandatory End-of-Session Workflow)

**هذه القائمة ليست اقتراحاً — هي إلزام:**

```
1. flutter analyze                      ← لا تتجاوز أي تحذير جديد
2. تحقق من .gitignore (لا أسرار مُسربة) ← key.properties / *.jks / .env / google-services.json
3. git add <الملفات المعدلة فقط>         ← لا تستخدم git add . عشوائياً
4. git commit -m "<type>: <وصف موجز>"    ← الصيغة في القسم 3
5. تحديث PROJECT_LOG.md (قيد جديد في الأعلى) ← القالب في الملف نفسه
6. git add PROJECT_LOG.md && git commit --amend --no-edit   أو commit جديد
7. git push origin main
8. إخبار المستخدم: ما تم + commit hash + رابط GitHub
```

**عند التعديلات المعمارية الكبيرة (سكيما DB، نمط جديد، إعادة هيكلة):**
- حدّث أيضاً `yemen_blood_bank_handoff.md` في القسم المعني.

---

## 3. صيغة الـ Commits الموحدة

استخدم **بادئة إنجليزية** ثم وصف بالإنجليزية. تجنّب العربية في رسائل commit لأن أدوات Git قد لا تعرضها بشكل صحيح في كل البيئات.

| البادئة | الاستخدام |
|---------|-----------|
| `feat:` | ميزة جديدة للمستخدم |
| `fix:` | إصلاح خلل |
| `docs:` | تعديل توثيق فقط |
| `chore:` | تنظيف، تحديث تبعيات، أو مهام صيانة |
| `refactor:` | إعادة هيكلة بدون تغيير سلوك |
| `test:` | إضافة/تعديل اختبارات |
| `perf:` | تحسين أداء |

أمثلة من السجل الحالي:
- `feat: implement two-tier cascading search dropdowns in SearchDonorsScreen`
- `fix: make updatedAt parsing defensive across all model parsers`
- `docs: update yemen_blood_bank_handoff.md with two-tier hierarchy`

---

## 4. الأنماط المعمارية المحمية (Architectural Invariants — Do Not Break)

### 4.1 القوائم المنسدلة المتتالية للموقع الجغرافي
- أي شاشة تحتاج محافظة/مديرية يجب أن تستخدم **Cascading Dropdowns** كما في الشاشات الخمس:
  - `lib/screens/donor/add_donor_screen.dart`
  - `lib/screens/admin/edit_donor_screen.dart`
  - `lib/screens/admin/add_hospital_screen.dart`
  - `lib/screens/admin/edit_hospital_screen.dart`
  - `lib/screens/donor/search_donors_screen.dart`
- **خريطة المديريات الرسمية:** `AppStrings.governorateDistricts` في `lib/constants/app_strings.dart`. كل تعديل جغرافي يبدأ من هنا.

### 4.2 صيغة تخزين الموقع
- يُحفظ دائماً كنص واحد: `"المحافظة - المديرية"` في حقل `district`.
- مثال: `"حضرموت - المكلا"` — لا تكسر هذا التنسيق حتى لا تتعطل دالة البحث RPC.

### 4.3 منطق fromJson الدفاعي
- أي نموذج يحتوي `updated_at` يجب أن يستخدم `created_at` كقيمة احتياطية إن كانت `updated_at` فارغة.
- النماذج الحالية المحمية: `DonorModel`, `HospitalModel`, `AdminModel`.

### 4.4 حقن الاعتمادات (GetIt)
- كل Service أو Provider جديد **يُسجَّل** في `lib/config/service_locator.dart`.
- لا تنشئ instances عشوائياً داخل الـ Widgets.

### 4.5 الفصل الطبقي
- ❌ لا استعلامات Supabase خام في الـ Widgets أو الشاشات.
- ❌ لا منطق أعمال داخل الـ Widgets.
- ✅ Screen → Provider → Service → Supabase

### 4.6 النصوص العربية
- كل نص يُعرَض للمستخدم يمر عبر `AppStrings`. لا نصوص حرفية مبعثرة في الشاشات.
- التطبيق RTL — أي layout جديد تحقق من سلوكه في RTL.

---

## 5. سير عمل الإصدارات (Release Workflow)

عند إصدار رسمي فقط:
1. زيادة الإصدار في `pubspec.yaml` (الحالي: `1.0.3+6` — صيغة `X.Y.Z+buildNumber`).
2. تشغيل `flutter analyze` و التأكد من نظافة كاملة.
3. `flutter build appbundle --release` بعد الاجتياز.
4. التحقق من بصمات التوقيع (موثقة في handoff قسم د) عبر `keytool`.

**خارج الإصدارات الفعلية: لا تزِد رقم الإصدار.**

---

## 6. ممنوعات صارمة (Anti-patterns)

- ❌ `git commit --no-verify` أو تجاوز أي hook.
- ❌ `git push --force` (خاصة على main).
- ❌ إنشاء فروع جديدة بدون طلب صريح من المستخدم.
- ❌ تثبيت حزم جديدة بدون موافقة (تضيف وزن APK وقد تكسر `in_app_update`).
- ❌ تجاوز `.gitignore` لإضافة أسرار.
- ❌ Emojis في ملفات الكود (`.dart`, `.kt`, `.gradle.kts`, إلخ). Emojis مسموحة فقط في ملفات `.md`.
- ❌ تجاهل تحديث `PROJECT_LOG.md` بعد commit.
- ❌ تعديل سكيما Supabase دون توثيق SQL في `yemen_blood_bank_handoff.md` قسم 4.

---

## 7. إذا فشل شيء (Error Handling Protocol)

| الموقف | التصرف |
|--------|---------|
| فشل `flutter analyze` | أصلح المشكلة، لا تتجاوزها بتعليق `// ignore`. |
| فشل `git push` (rejected) | `git pull --rebase` ثم push. لا تستخدم `--force`. |
| تعارض في merge | اسأل المستخدم — لا تختر طرفاً عشوائياً. |
| ملف غير مألوف موجود | اقرأه أولاً قبل التعديل — قد يكون عمل المستخدم. |
| طلب غامض من المستخدم | اسأل قبل التنفيذ، خاصة للعمليات غير القابلة للتراجع. |

---

## 8. ملخص سريع للتذكر (TL;DR)

```
قبل العمل:   اقرأ آخر 5 قيود في PROJECT_LOG.md
أثناء العمل: التزم بالأنماط المعمارية في القسم 4
بعد العمل:   analyze → commit → log → push → أبلغ المستخدم
```
