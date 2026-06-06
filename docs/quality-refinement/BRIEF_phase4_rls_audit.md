# 📓 مذكّرة تنفيذ — المرحلة 4: تدقيق RLS واختبار الاختراق الفعلي

> **موجَّهة إلى:** صاحب المشروع (تنفيذ يدوي عبر Supabase SQL Editor) + وكيل الكود (التوثيق).
> **المخطِّط:** Claude.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 4.

---

## 🎯 السياق والهدف المعدَّل

**اكتشاف حاسم أثناء الفحص غيّر نطاق المرحلة:** مفتاح Supabase `anon` **علني** (مكتوب في `supabase_config.dart` المرفوع). لذا RLS هو خط الدفاع الوحيد. لكن فحص الكود كشف أيضاً أن:

1. **القراءة العامة قرار معماري أصيل لا ثغرة:** البحث بلا تسجيل، عرض المتبرعين، الإحصائيات — كلها تقرأ `donors` مباشرة عبر `.from('donors').select()` (في `getAllDonors`, `getDonorsByGovernorate`, `searchByNameOrPhone`, `getSuspendedDonors`, `StatisticsService`). تضييق سياسة SELECT **سيكسر التطبيق**. وسياسة الخصوصية تعلن صراحةً مشاركة بيانات المتبرع مع طالبي الدم.

2. **الخطر الحقيقي = الكتابة لا القراءة.** الهدف: التأكد الفعلي أن مهاجماً بالمفتاح العلني **لا يستطيع تعديل/حذف** بيانات، خصوصاً عبر المحافظات.

**نطاق المرحلة المعدَّل:**
- (أ) اختبار اختراق فعلي لعمليات الكتابة (UPDATE/DELETE/INSERT) بنمط `ROLLBACK` آمن.
- (ب) توثيق القراءة العامة كقرار معماري واعٍ (منع وكيل لاحق من «إصلاحها» وكسر التطبيق).
- (ج) توصية تقييد معدّل الطلبات (Rate Limiting) كدفاع متناسب ضد السحب الجماعي.

---

## 🔑 المعرّفات (مُثبّتة — جاهزة)

**المستشفى المُحاكى (المهاجم):** `4fa3de67-8b31-47f4-b1c3-7744bcee35c3` (مستشفى ابن سيناء — حضرموت).

**المتبرعون:**
- **الداخلي** (حضرموت — نفس محافظة المستشفى): `02263d06-b90a-4af4-9310-2840ee801390` — `added_by = b38f24cd-b881-4a64-bfd7-390743f473b1` (حساب آخر، غالباً أدمن — **ليس** المستشفى المهاجم).
- **الخارجي** (شبوة — محافظة مختلفة): `543de8b5-f94a-43f9-93c0-37161fbe1374` — `added_by = NULL` (تسجيل ذاتي عام).

### 🔍 تحليل الملكية (حاسم لتفسير النتائج)

سياسة UPDATE = `auth.uid() = added_by OR is_admin()` ⇒ الحماية قائمة على **ملكية الصف، لا المحافظة**.
- تعديل الداخلي: `4fa3... = b38f...` → `false` ⇒ **متوقَّع 0** (المستشفى لا يملكه، رغم أنه في محافظته).
- تعديل الخارجي: `4fa3... = NULL` → `null` ⇒ **متوقَّع 0** (مرفوض).

> 🟡 **ملاحظة معمارية مهمة:** المستشفى يعدّل **فقط** ما أضافه بنفسه — حتى متبرعو محافظته الذين أضافهم غيره لا يستطيع تعديلهم عبر المسار العادي. هذا **آمن جداً** لكنه مقيّد؛ ولهذا وُجدت دالة `suspend_donor_by_hospital` (تمنح الإيقاف ضمن المحافظة بحراسة، متجاوزةً قيد الملكية).

---

## 🛡️ قاعدة الأمان المطلقة لكل الاختبارات

**كل اختبار كتابة يُلفّ في معاملة تُلغى:** `BEGIN; ... ROLLBACK;`. حتى لو نجح تعديل لا نريده، يُلغى فوراً ولا يترك أثراً. **لا تستخدم `COMMIT` أبداً في اختبارات الاختراق.**

> ⚠️ نفّذ كل بلوك `BEGIN...ROLLBACK` **كاملاً دفعة واحدة** في SQL Editor، لا سطراً سطراً.

---

## 🧪 القسم (أ): اختبارات الاختراق

> **آلية المحاكاة:** في SQL Editor (يعمل بدور `postgres` المتجاوز)، نحاكي دوراً عبر ضبط `role` و `request.jwt.claims`. هذا يجعل `auth.uid()` و `is_hospital()` تتصرف كأن المستخدم المعني هو المتصل.

### اختبار 1 — هل يستطيع مستشفى تعديل متبرع خارج محافظته؟ (الأخطر)

**المتوقَّع:** 0 صفوف متأثرة (الخارجي `added_by=NULL` ⇒ `uid = null` = `null`).

```sql
BEGIN;
-- محاكاة مستشفى ابن سيناء (حضرموت)
SET LOCAL role = 'authenticated';
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', '4fa3de67-8b31-47f4-b1c3-7744bcee35c3', 'role', 'authenticated')::text,
  true
);

-- محاولة تعديل المتبرع الخارجي (شبوة)
UPDATE public.donors
SET name = 'اختراق_تجريبي'
WHERE id = '543de8b5-f94a-43f9-93c0-37161fbe1374';

-- كم صفاً تأثر فعلياً؟ المتوقَّع 0
SELECT 'صفوف متأثرة (يجب 0):' AS note;
ROLLBACK;
```

**تفسير:**
- **0 صفوف متأثرة** = ✅ آمن. RLS منعت التعديل.
- **1 صف** = 🟥 ثغرة خطيرة. أبلغني فوراً.

---

### اختبار 1ب — هل يستطيع المستشفى تعديل متبرع في محافظته لكن أضافه غيره؟

**المتوقَّع:** 0 صفوف (الداخلي `added_by=b38f...` ≠ المستشفى). يؤكّد أن الحماية بالملكية لا المحافظة.

```sql
BEGIN;
SET LOCAL role = 'authenticated';
SELECT set_config('request.jwt.claims',
  json_build_object('sub','4fa3de67-8b31-47f4-b1c3-7744bcee35c3','role','authenticated')::text, true);

UPDATE public.donors SET name = 'اختراق_داخلي'
WHERE id = '02263d06-b90a-4af4-9310-2840ee801390';
SELECT 'صفوف متأثرة (يجب 0):' AS note;
ROLLBACK;
```

**تفسير:** 0 = ✅ آمن (الملكية تحرس حتى داخل المحافظة).

---

### اختبار 2 — هل يستطيع مستشفى حذف متبرع؟ (DELETE للأدمن فقط)

**المتوقَّع:** 0 صفوف (سياسة DELETE = `is_admin()` فقط).

```sql
BEGIN;
SET LOCAL role = 'authenticated';
SELECT set_config('request.jwt.claims',
  json_build_object('sub', '4fa3de67-8b31-47f4-b1c3-7744bcee35c3', 'role', 'authenticated')::text, true);

DELETE FROM public.donors WHERE id = '02263d06-b90a-4af4-9310-2840ee801390';
SELECT 'صفوف محذوفة (يجب 0):' AS note;
ROLLBACK;
```

**تفسير:** 0 = ✅ آمن (المستشفى لا تحذف). أي حذف = 🟥 ثغرة.

---

### اختبار 3 — هل يستطيع زائر مجهول (anon) حذف أو تعديل؟

**المتوقَّع:** فشل كامل (لا سياسة UPDATE/DELETE لـ anon).

```sql
BEGIN;
SET LOCAL role = 'anon';
SELECT set_config('request.jwt.claims',
  json_build_object('role', 'anon')::text, true);

UPDATE public.donors SET name = 'اختراق_anon' WHERE id = '02263d06-b90a-4af4-9310-2840ee801390';
SELECT 'تعديل anon (يجب 0):' AS note;

DELETE FROM public.donors WHERE id = '02263d06-b90a-4af4-9310-2840ee801390';
SELECT 'حذف anon (يجب 0):' AS note;
ROLLBACK;
```

**تفسير:** كلاهما 0 = ✅ آمن.

---

### اختبار 4 — متانة ضابط الإدراج العام (anon): هل يمكن انتحال ملكية؟

السياسة: `WITH CHECK (is_active = true AND added_by IS NULL)`. نختبر تجاوزها.

```sql
BEGIN;
SET LOCAL role = 'anon';
SELECT set_config('request.jwt.claims',
  json_build_object('role', 'anon')::text, true);

-- محاولة 1: إدراج بانتحال added_by (يجب أن يُرفض)
INSERT INTO public.donors (name, phone_number, blood_type, district, governorate, age, gender, is_active, added_by)
VALUES ('انتحال', '770000000', 'O+', 'حضرموت - المكلا', 'حضرموت', 30, 'male', true, '4fa3de67-8b31-47f4-b1c3-7744bcee35c3');
SELECT 'إدراج بانتحال added_by: نجح = ثغرة' AS note;
ROLLBACK;
```

**تفسير:**
- **رسالة خطأ / فشل (`new row violates row-level security`)** = ✅ آمن. الضابط يمنع الانتحال.
- **نجح الإدراج** = 🟠 ثغرة متوسطة (يمكن لـ anon إنشاء صف منسوب لمستشفى).

```sql
-- محاولة 2: إدراج بـ is_active=false (يجب أن يُرفض)
BEGIN;
SET LOCAL role = 'anon';
SELECT set_config('request.jwt.claims', json_build_object('role','anon')::text, true);
INSERT INTO public.donors (name, phone_number, blood_type, district, governorate, age, gender, is_active, added_by)
VALUES ('غير نشط', '770000001', 'O+', 'حضرموت - المكلا', 'حضرموت', 30, 'male', false, NULL);
SELECT 'إدراج is_active=false: نجح = خرق للضابط' AS note;
ROLLBACK;
```

---

### اختبار 5 — دالة suspend_donor_by_hospital ترفض متبرعاً خارج المحافظة

دالة `SECURITY DEFINER` تتجاوز RLS لكن تتحقق داخلياً من المحافظة. نختبر الرفض.

```sql
BEGIN;
SET LOCAL role = 'authenticated';
SELECT set_config('request.jwt.claims',
  json_build_object('sub','4fa3de67-8b31-47f4-b1c3-7744bcee35c3','role','authenticated')::text, true);

-- محاولة إيقاف المتبرع الخارجي (شبوة) من مستشفى حضرموت
SELECT public.suspend_donor_by_hospital('543de8b5-f94a-43f9-93c0-37161fbe1374');
-- المتوقَّع: EXCEPTION "غير مصرح: لا يمكن للمستشفى إيقاف متبرع من خارج محافظته"
ROLLBACK;
```

**تفسير:** ظهور الاستثناء = ✅ آمن (الدالة تحرس المحافظة). نجاح الإيقاف = 🟥 ثغرة في الدالة.

---

### اختبار 6 — دالة suspend_donor_by_hospital تسمح بمتبرع داخل المحافظة (الوظيفة الصحيحة)

نتأكّد أن الحماية لا تكسر الوظيفة: مستشفى حضرموت **يجب** أن يستطيع إيقاف متبرع حضرموت.

```sql
BEGIN;
SET LOCAL role = 'authenticated';
SELECT set_config('request.jwt.claims',
  json_build_object('sub','4fa3de67-8b31-47f4-b1c3-7744bcee35c3','role','authenticated')::text, true);

-- إيقاف المتبرع الداخلي (حضرموت) من مستشفى حضرموت
SELECT id, suspended_until FROM public.suspend_donor_by_hospital('02263d06-b90a-4af4-9310-2840ee801390');
-- المتوقَّع: نجاح، suspended_until = بعد ~180 يوماً
ROLLBACK;
```

**تفسير:**
- **نجاح + `suspended_until` مستقبلي** = ✅ ممتاز (الحماية لا تكسر الوظيفة الشرعية).
- **EXCEPTION** = 🟠 الدالة مقيّدة أكثر من اللازم (تمنع وظيفة مشروعة) — نراجعها.

> هذا الاختبار **إيجابي** (نتوقّع النجاح)، عكس البقية. يثبت توازن التصميم: يمنع الخطأ، يسمح بالصواب.

---

## 📝 القسم (ب): توثيق القراءة العامة كقرار معماري

أضف إلى `yemen_blood_bank_handoff.md` (قسم 4 — RLS) فقرة صريحة:

```
> 🟢 قرار معماري مقصود (موثَّق 2026-06-03): سياسة SELECT على donors عامة
> (USING is_active = true) عن عمد. السبب: البحث الوطني بلا تسجيل + عرض
> المتبرعين + الإحصائيات تقرأ الجدول مباشرة. هذا متوافق مع سياسة الخصوصية
> (المتبرع يوافق على مشاركة بياناته مع طالبي الدم). ⚠️ لا تُضيّق سياسة SELECT
> دون إعادة هندسة كل دوال القراءة لتمرّ عبر RPCs — التضييق سيكسر لوحة المستشفى
> والأدمن والبحث بالاسم والإحصائيات. الحماية ضد السحب الجماعي = Rate Limiting
> لا تضييق RLS.
```

---

## 📝 القسم (ج): توصية Rate Limiting (الدفاع المتناسب)

السحب الجماعي (تفريغ آلاف الأرقام) يُعالَج بتقييد معدّل الطلبات، لا بكسر القراءة:

- **خيار 1 (موصى به):** تفعيل Rate Limiting على مستوى Cloudflare Worker (موجود أصلاً في معماريتك كـ reverse proxy — `useCloudflareWorker`). يُضبط حد أقصى للطلبات لكل IP/دقيقة.
- **خيار 2:** Supabase حديثاً يوفّر حدود معدّل على مستوى المشروع — تُراجَع في لوحة التحكم.
- **خيار 3 (تطبيقي):** تحويل البحث الحساس لـ RPC `SECURITY DEFINER` تُرجع نتائج محدودة (LIMIT) بدل القراءة المفتوحة — لكن هذا تغيير أكبر يؤجَّل.

> **القرار:** نوصي بالخيار 1 عند تجهيز النشر. لا يُنفَّذ الآن (التطبيق تطويري). يُسجَّل كبند في «القيود المعروفة».

---

## ✅ قائمة التحقق (Definition of Done)

- [x] المعرّفات مُثبّتة (مستشفى ابن سيناء + متبرعا حضرموت/شبوة + تحليل added_by).
- [ ] الاختبارات 1، 1ب، 2، 3، 4، 5، 6 نُفِّذت، والنتائج طابقت المتوقَّع (1-5 آمن/0، و6 نجاح).
- [ ] القراءة العامة موثَّقة كقرار معماري في handoff.
- [ ] توصية Rate Limiting مسجَّلة في «القيود المعروفة».
- [ ] لا تغيير فعلي على قاعدة البيانات (كل الاختبارات ROLLBACK).
- [ ] قيد PROJECT_LOG يوثّق نتيجة التدقيق.

---

## 📝 قيد PROJECT_LOG.md المقترح

```
### YYYY-MM-DD — [test] تدقيق أمان RLS واختبار اختراق فعلي لعمليات الكتابة
- **الوصف:** اختبار اختراق فعلي (بنمط ROLLBACK آمن) لسياسات RLS على donors: تعديل/حذف عبر المحافثات، تجاوز anon، متانة ضابط الإدراج العام، وحراسة دالة suspend_donor_by_hospital. النتيجة: [آمن/ثغرات]. توثيق القراءة العامة كقرار معماري مقصود (لا تُضيّق SELECT). توصية Rate Limiting عبر Cloudflare Worker لمنع السحب الجماعي (مؤجَّلة للنشر).
- **الملفات:** `yemen_blood_bank_handoff.md`, `QUALITY_REFINEMENT_PLAN.md`
- **السبب/الدافع:** المفتاح anon علني ⇒ RLS هو الدفاع الوحيد. التحقق الفعلي لا الورقي.
- **اختبار:** 5 اختبارات اختراق عبر SQL Editor، كلها ROLLBACK، لا تغيير بيانات.
- **Commit:** `<hash>`
```

> **صيغة commit:** `test: audit RLS write policies with live penetration tests`

---

## ⚠️ تنبيهات

1. **لا COMMIT** في أي اختبار اختراق — `ROLLBACK` فقط.
2. لو أظهر أي اختبار **ثغرة (🟥/🟠)**، توقّف وأبلغني قبل أي إصلاح — نصمّمه معاً.
3. هذه المرحلة **لا تغيّر** قاعدة البيانات ولا الكود (عدا التوثيق). إصلاح أي ثغرة مكتشفة = مذكّرة منفصلة.
4. محاكاة الأدوار في SQL Editor تقريبية؛ لو شككت في نتيجة، نؤكّدها بحساب مستشفى حقيقي عبر التطبيق.
