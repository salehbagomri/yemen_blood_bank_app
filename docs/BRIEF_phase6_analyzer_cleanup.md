# 📓 مذكّرة تنفيذ — المرحلة 6: تنظيف تحذيرات flutter analyze (الوصول لصفر)

> **موجَّهة إلى:** وكيل الكود (المنفِّذ).
> **المخطِّط:** Claude.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 6.

---

## 🎯 السياق

179 info متبقية. الهدف: **صفر info** (لا مجرد صفر أخطاء). مقسّمة على **3 دفعات** بـ commits منفصلة، مرتّبة من الأكثر أماناً للأكثر حساسية.

> **عادة إلزامية (درس المرحلة 5):** بعد كل دفعة، شغّل `flutter analyze` وتحقّق أن العدد نزل كما هو متوقَّع **بأعينك**، لا بالافتراض. لا تعتمد على «يفترض أنه نجح».

---

## 🧩 الأنماط المحمية

- لا تغيير سلوكي — التحويلات تحافظ على نفس النتيجة البصرية/الوظيفية.
- لا إيموجي في كود Dart (لاحظ: نصوص العرض الحالية فيها إيموجي مثل `✅`/`❌` — **خارج النطاق، لا تلمسها**).
- لا حزمة جديدة.

---

## 📦 الدفعة 1 — withOpacity → withValues (~163 موضعاً)

**التحويل الميكانيكي:** `withOpacity(x)` ⟶ `withValues(alpha: x)`. نفس القيمة، دالة غير مُلغاة.

أمثلة:
```dart
Colors.grey.withOpacity(0.1)        ⟶  Colors.grey.withValues(alpha: 0.1)
AppColors.warning.withOpacity(0.3)  ⟶  AppColors.warning.withValues(alpha: 0.3)
Colors.white.withOpacity(0.2)       ⟶  Colors.white.withValues(alpha: 0.2)
```

**التنفيذ:** بحث/استبدال محكوم عبر المشروع. النمط ثابت: `.withOpacity(` ⟶ `.withValues(alpha: ` مع إضافة `)` الإغلاق في مكانه الصحيح (الوسيطة الوحيدة تصبح مُسمّاة).

> ⚠️ **انتبه:** الاستبدال ليس مجرد استبدال نصي بسيط للقوس — `withOpacity(0.1)` لها قوس إغلاق واحد، و`withValues(alpha: 0.1)` كذلك. تأكّد ألا يكسر الاستبدال الأقواس في الحالات المتداخلة. راجع عينة من 5-6 ملفات يدوياً بعد الاستبدال.

**بعد الدفعة:**
```
flutter analyze | Select-String "withOpacity"   # يجب أن يكون فارغاً
flutter analyze                                  # العدد ~179 ناقص عدد withOpacity
```

**مراجعة بصرية (مهمة):** شغّل التطبيق وتفقّد عيّنة: ظلال البطاقات، خلفيات التنبيهات، الـ headers المتدرّجة. يجب أن تبدو **مطابقة تماماً** لما كانت.

**commit:** `refactor: replace deprecated withOpacity with withValues`

---

## 📦 الدفعة 2 — المتفرقات الصغيرة الآمنة

| النوع | الموضع | العلاج |
|-------|--------|--------|
| `avoid_print` (3) | `report_export_utils.dart:193,302,325` | `print(...)` ⟶ `debugPrint(...)` (أضف `import 'package:flutter/foundation.dart';` إن لزم) |
| `unnecessary_import` | `banner_provider.dart:1` | احذف `import 'dart:typed_data';` (مُوفَّر عبر foundation) |
| `prefer_initializing_formals` | `donor_model.dart:41`, `hospital_model.dart:28` | حوّل لـ initializing formal: `this.field` في المُنشئ |
| `unnecessary_underscores` (~8) | `page_transitions.dart`, `search_donors_screen.dart:581`, `statistics_section.dart:288`, `shimmer_loading.dart:65` | `(__) ⟶ (_)` أو حسب اقتراح المحلّل |
| `strict_top_level_inference` (~3) | `hospital_dashboard_screen.dart:127,153`, `blood_type_detailed_report_screen.dart:115` | أضف نوع المعامل الصريح |
| `no_leading_underscores` (1) | `donor_model_test.dart:13` | أعد تسمية `_makeAvailableDonor` ⟶ `makeAvailableDonor` |
| `value deprecated` | `search_donors_screen.dart:448` | `value:` ⟶ `initialValue:` (DropdownButtonFormField) |

> كلها تحويلات بسيطة بلا أثر سلوكي. عالجها، ثم `flutter analyze`.

**commit:** `chore: resolve minor analyzer lints (print, imports, formals, inference)`

---

## 📦 الدفعة 3 — ترقية share_plus (الأكثر حساسية — منفصلة عمداً)

**لماذا منفصلة:** ترقية `Share.share()`/`shareXFiles()` إلى `SharePlus.instance.share(ShareParams(...))` **تغيير API سلوكي**، لا إعادة تسمية. يحتاج اختباراً فعلياً للمشاركة.

**المواضع:**
- `home_screen.dart:348` — `Share.share(shareText)`
- `export_service.dart:579` — `Share.shareXFiles(...)`
- `report_export_utils.dart:318` — `Share.shareXFiles(...)`

**التحويل (تحقّق من توقيع share_plus المثبَّت `^12.0.1` أو أحدث):**
```dart
// نص:
Share.share(shareText);
⟶ SharePlus.instance.share(ShareParams(text: shareText));

// ملفات:
Share.shareXFiles([XFile(path)], text: '...');
⟶ SharePlus.instance.share(ShareParams(files: [XFile(path)], text: '...'));
```

> ⚠️ **تحقّق أولاً** من التوقيع الفعلي في إصدارك: افتح `share_plus` في pub أو الكود المولَّد، فالـ API تغيّر بين الإصدارات. طبّق التوقيع الصحيح لإصدارك المثبَّت.

**اختبار يدوي إلزامي بعد هذه الدفعة:**
- زر مشاركة التطبيق في الصفحة الرئيسية → تظهر ورقة المشاركة بالنص الصحيح.
- تصدير تقرير (PDF/Excel) ومشاركته → الملف يُشارَك فعلاً.

**commit:** `refactor: migrate to SharePlus API (share_plus v12)`

---

## ✅ قائمة التحقق النهائية للمرحلة (Definition of Done)

- [ ] الدفعة 1: `flutter analyze | Select-String "withOpacity"` فارغ.
- [ ] الدفعة 2: المتفرقات الصغيرة كلها عولجت.
- [ ] الدفعة 3: share_plus مُرقّى ومُختبَر يدوياً (مشاركة نص + ملف تعملان).
- [ ] **الهدف النهائي:** `flutter analyze` = **0 issues** (صفر تام).
- [ ] مراجعة بصرية: لا تغيّر في مظهر الشفافيات.
- [ ] 3 commits منفصلة، كل دفعة موثّقة.

---

## 📝 قيد PROJECT_LOG.md المقترح (قيد واحد يلخّص الدفعات الثلاث)

```
### YYYY-MM-DD — [refactor] تنظيف كامل لتحذيرات flutter analyze (وصول لصفر)
- **الوصف:** إزالة كل الـ 179 info على 3 دفعات: (1) ~163 withOpacity→withValues،
  (2) متفرقات صغيرة (print→debugPrint، unnecessary_import، prefer_initializing_formals،
  unnecessary_underscores، strict_top_level_inference، value→initialValue)،
  (3) ترقية share_plus إلى SharePlus.instance.share(ShareParams) مع اختبار يدوي.
  النتيجة: flutter analyze = 0 issues تماماً.
- **الملفات:** عشرات الملفات في lib/ (شاشات/widgets/services/utils/models) + test
- **السبب/الدافع:** الوصول لصفر تحذيرات (نظافة كاملة)، خاصة استبدال API مُلغاة.
- **اختبار:** analyze = 0 ✅ / مراجعة بصرية للشفافيات ✅ / مشاركة نص+ملف تعملان ✅.
- **Commit:** `<hashes>` (3 commits)
```

> **صيغ commit:** كما في كل دفعة أعلاه (3 منفصلة).

---

## ⚠️ تنبيهات

1. **بعد كل دفعة `flutter analyze` + تحقّق العدد بالعين** — لا تجمع الدفعات الثلاث في commit واحد.
2. **الدفعة 3 تحتاج اختباراً يدوياً فعلياً** — لا تكتفِ بـ analyze (تغيير API سلوكي).
3. لو كشف أي شيء أن تحويل withOpacity كسر مظهراً، توقّف وأبلغني.
4. لا تلمس الإيموجي في نصوص العرض (`✅`/`❌` في SnackBars) — هي بيانات عرض لا كود، وخارج نطاق هذه المرحلة.
