# 📓 مذكّرة تنفيذ — المرحلة 7: إصلاح الاختبارات القديمة وتوسيع التغطية

> **موجَّهة إلى:** وكيل الكود (المنفِّذ).
> **المخطِّط:** Claude.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 7.

---

## 🎯 السياق (من تشغيل flutter test الفعلي)

النتيجة: **140 نجح، 4 فشل** (`+140 -4`). الأربعة فعلياً **اختباران مكرّران** (يظهران مرتين: مباشرةً عبر `constants_test.dart`، ومرة عبر `widget_test.dart` المجمّع الذي يستورد كل الاختبارات ويشغّل `main()`).

**جذر الفشل:** `constants_test.dart` يفحص `AppStrings.districts.length == 9` وأسماء مديريات المهرة القديمة. لكن `AppStrings.districts` تغيّر دلالةً أثناء التحويل الوطني — صار يحتوي **22 محافظة** (أمانة العاصمة، عدن، تعز...) لا 9 مديريات. الاختبار مهجور.

**البنية المكتشفة:** `widget_test.dart` = مجمّع (test runner) يستورد `donor_model`, `validators`, `helpers`, `constants`, `shimmer`. إصلاح `constants_test.dart` وحده يحلّ الظهورين.

---

## 🧩 الأنماط المحمية

- لا تغيّر بيانات اختبار `donor_model_test` (تستخدم أسماء مثل «الغيضة» كقيم نصية — تعمل بغضّ النظر عن المحافظة، ليست خطأً).
- اختبر المنطق الدفاعي الفعلي للنماذج (updated_at→created_at، اشتقاق governorate) — هذا جوهر الأنماط المحمية في CLAUDE.md.
- لا إيموجي في كود الاختبار. أسماء محلية بلا شرطة سفلية بادئة (تجنّب تكرار lint).

---

## 📋 المهام

### المهمة 7.1 — إصلاح constants_test.dart (الاختباران الفاشلان)

**استبدل** الاختبارين المهجورين بما يطابق الواقع الوطني. الخيار الأنسب: اختبار `governorateDistricts` (الخريطة الوطنية) بدل `districts` القديمة.

```dart
test('قائمة المحافظات تحتوي على 22 محافظة', () {
  expect(AppStrings.districts.length, equals(22));
});

test('قائمة المحافظات تحتوي على محافظات أساسية صحيحة', () {
  const expectedGovernorates = [
    'حضرموت', 'عدن', 'صنعاء', 'تعز', 'المهرة', 'شبوة',
  ];
  for (final gov in expectedGovernorates) {
    expect(
      AppStrings.districts,
      contains(gov),
      reason: 'يجب أن تحتوي القائمة على "$gov"',
    );
  }
});
```

> **تحقّق من الاسم الفعلي:** افتح `app_strings.dart` وتأكّد أن `districts` فعلاً قائمة المحافظات الـ22، وأن `governorateDistricts` هي خريطة المحافظة→المديريات. اضبط أسماء الحقول حسب الموجود فعلياً.

**أضف اختباراً للبنية الجغرافية الجديدة:**
```dart
test('خريطة المحافظات والمديريات مكتملة', () {
  expect(AppStrings.governorateDistricts.length, equals(22));
  // كل محافظة لها مديرية واحدة على الأقل
  for (final entry in AppStrings.governorateDistricts.entries) {
    expect(entry.value, isNotEmpty,
      reason: 'محافظة ${entry.key} بلا مديريات');
  }
});
```

---

### المهمة 7.2 — اختبارات HospitalModel (ثغرة: لا اختبار حالياً)

أنشئ `test/unit/hospital_model_test.dart`. اختبر المنطق الدفاعي:
- `fromJson` صحيح بكل الحقول.
- **السقوط من updated_at إلى created_at** عند غياب الأول.
- **اشتقاق governorate من district** عند غياب عمود governorate (مثل `"حضرموت - المكلا"` ⟶ `"حضرموت"`).
- التعامل مع null الدفاعي (حقول اختيارية غائبة).

```dart
test('fromJson يشتق governorate من district عند غيابه', () {
  final json = { /* ... بلا governorate، مع district: 'حضرموت - المكلا' */ };
  final h = HospitalModel.fromJson(json);
  expect(h.governorate, equals('حضرموت'));
});

test('fromJson يسقط من updated_at إلى created_at', () {
  final json = { /* ... بلا updated_at، مع created_at */ };
  final h = HospitalModel.fromJson(json);
  expect(h.updatedAt, equals(h.createdAt));
});
```

> راجع `hospital_model.dart` للحقول الفعلية وتوقيع fromJson قبل الكتابة.

---

### المهمة 7.3 — اختبارات AdminModel (ثغرة: لا اختبار)

أنشئ `test/unit/admin_model_test.dart`. نفس نمط الدفاع: fromJson، السقوط updated_at→created_at، null الدفاعي. (أبسط من Hospital — حقول أقل غالباً.)

---

### المهمة 7.4 — اختبارات BannerModel (النوع المزدوج)

أنشئ `test/unit/banner_model_test.dart`. اختبر:
- بانر **صوري** (imagePath موجود).
- بانر **نصي** (imagePath فارغ/null، مع iconName/bgGradient).
- `fromJson` الدفاعي للحقول الاختيارية (subtitle, actionValue, starts_at, ends_at).
- منطق التمييز بين النوعين (إن وُجد getter مثل `isImageBanner`).

> راجع `banner_model.dart` للحقول الفعلية.

---

### المهمة 7.5 — ربط الاختبارات الجديدة بالمجمّع

في `test/widget_test.dart` أضف الاستيرادات والاستدعاءات:
```dart
import 'unit/hospital_model_test.dart' as hospital_model;
import 'unit/admin_model_test.dart' as admin_model;
import 'unit/banner_model_test.dart' as banner_model;
// ... في main():
hospital_model.main();
admin_model.main();
banner_model.main();
```

---

### المهمة 7.6 — تشغيل وتسجيل التغطية

```
flutter test                  # يجب أن يمرّ الكل (0 فشل)
flutter test --coverage       # توليد coverage/lcov.info
```
سجّل عدد الاختبارات الكلي ونسبة التغطية كخط أساس في القيد.

---

## ✅ قائمة التحقق (Definition of Done)

- [ ] `constants_test.dart` يطابق الواقع الوطني (22 محافظة) — لا فحص مهجور.
- [ ] `flutter test` = **0 فشل** (كان 4).
- [ ] اختبارات HospitalModel/AdminModel/BannerModel مضافة وتمرّ.
- [ ] المنطق الدفاعي (updated_at→created_at، اشتقاق governorate) مُختبَر.
- [ ] الاختبارات الجديدة مربوطة بالمجمّع.
- [ ] `flutter analyze` = 0 (لا lint جديد في كود الاختبار).
- [ ] التغطية مسجّلة كخط أساس.

---

## 📝 قيد PROJECT_LOG.md المقترح

```
### YYYY-MM-DD — [test] إصلاح الاختبارات المهجورة وتوسيع تغطية النماذج
- **الوصف:** إصلاح اختبارين فاشلين في constants_test (كانا يفحصان 9 مديريات مهرة
  قديمة بينما AppStrings.districts صار 22 محافظة). إضافة اختبارات وحدة جديدة:
  HospitalModel وAdminModel (المنطق الدفاعي: updated_at→created_at، اشتقاق
  governorate من district، null الدفاعي) وBannerModel (النوع المزدوج صوري/نصي).
  ربطها بالمجمّع widget_test. flutter test: 0 فشل (كان 4).
- **الملفات:** `test/unit/constants_test.dart`, `test/unit/hospital_model_test.dart` (جديد),
  `test/unit/admin_model_test.dart` (جديد), `test/unit/banner_model_test.dart` (جديد),
  `test/widget_test.dart`
- **السبب/الدافع:** اختبارات مهجورة من حقبة المهرة + ثغرات تغطية في نماذج حرجة.
- **اختبار:** flutter test كل الاختبارات تمرّ ✅ / analyze 0 ✅ / تغطية: <النسبة>.
- **Commit:** `<hash>`
```

> **صيغة commit:** `test: fix stale district tests and add model coverage`

---

## ⚠️ تنبيهات

1. **اقرأ كل نموذج فعلياً قبل كتابة اختباره** (hospital_model, admin_model, banner_model) — الحقول وتواقيع fromJson تختلف. لا تخمّن.
2. لو كشف اختبار جديد **خطأً حقيقياً** في منطق نموذج (لا مجرد اختبار خاطئ)، توقّف وأبلغني — قد نكون وجدنا bug فعلي.
3. عالج `constants_test` أولاً (يصلح الفشل الحالي)، ثم أضف الجديد تدريجياً مع `flutter test` بعد كل ملف.
4. لا تستخدم شرطة سفلية بادئة لأسماء دوال المساعدة المحلية في الاختبار (`makeHospital` لا `_makeHospital`) تفادياً لتكرار lint.
