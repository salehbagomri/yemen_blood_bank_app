# 📓 مذكّرة تنفيذ — المرحلة 5: معالجة BuildContext across async gaps

> **موجَّهة إلى:** وكيل الكود (المنفِّذ).
> **المخطِّط:** Claude.
> **مرتبطة بـ:** [QUALITY_REFINEMENT_PLAN.md](./QUALITY_REFINEMENT_PLAN.md) المرحلة 5.

---

## 🎯 السياق

12 حالة `use_build_context_synchronously` (لا 11 — المحلّل أدقّ). **ليست تجميلية** — مخاطر runtime: استخدام `context` بعد `await`/تأخير دون التأكد أن الـ widget لا يزال حياً. التشخيص الكامل صنّفها في **4 أنماط**، لكل علاجه.

> **مبدأ حاكم:** لا «وصفة واحدة». طبّق العلاج المطابق لكل نمط بدقة. بعد كل إصلاح، أعد `flutter analyze` للتأكد أن العدد ينقص دون ظهور تحذيرات جديدة.

---

## 🧩 الأنماط المحمية

- لا تغيّر منطق التحميل أو التنقّل — فقط أضف حراسة `mounted`.
- في `StatefulWidget`: استخدم `if (!mounted) return;` (الـ State لها `mounted`).
- عند استخدام `context` المُمرَّر كمعامل لدالة: استخدم `if (!context.mounted) return;`.
- لا إيموجي في كود Dart. لا تغيير على نصوص العرض.

---

## 📋 العلاج حسب النمط

### النمط الأول — `Future.microtask` في `initState` (7 حالات)
**الملفات/الأسطر:** `manage_donors_screen.dart:37`, `blood_type_report_screen.dart:22`, `hospital_dashboard_screen.dart:31` و`:32`, `manage_donors_hospital_screen.dart:40`, `blood_type_detailed_report_screen.dart:31` و`:32`.

**العلاج:** أضف `if (!mounted) return;` كأول سطر داخل الـ callback.

**مثال (manage_donors_screen.dart:37):**
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    if (!mounted) return;            // ← مضاف
    context.read<DonorProvider>().loadDonors();
  });
}
```

**للحالات ذات استدعاءين (hospital_dashboard:31-32، blood_type_detailed:31-32):** فحص واحد في الأعلى يكفي للاثنين:
```dart
Future.microtask(() {
  if (!mounted) return;            // ← يغطّي الاستدعاءين
  final gov = context.read<AuthProvider>().hospitalGovernorate;
  context.read<DashboardProvider>().loadDashboardData(governorate: gov);
});
```

---

### النمط الثاني — `.then` بعد التنقّل (حالتان)
**الملفات/الأسطر:** `manage_donors_screen.dart:104`, `manage_donors_hospital_screen.dart:103`.

**المشكلة:** `Navigator.pushNamed(...).then((_) => context.read...)` — الـ callback يُنفَّذ بعد العودة، وقد أُغلقت الشاشة.

**العلاج:** أضف فحصاً داخل `.then`:
```dart
onPressed: () {
  Navigator.of(context)
      .pushNamed(AppRouter.addDonor)
      .then((_) {
        if (!mounted) return;      // ← مضاف
        context.read<DonorProvider>().loadDonors();
      });
},
```

---

### النمط الثالث — `await` متعدّد بفحص ناقص (حالتان) — انتبه للدقة
**الملفات/الأسطر:** `report_detail_screen.dart:873`, `expandable_donor_card.dart:597`.

**المشكلة:** يوجد فحص `mounted` لكن **بعد** await لاحق، بينما `context` يُستخدم بعد await **سابق** دون فحص.

**report_detail_screen.dart (~873):** `context.read<DonorProvider>().deleteDonor` يُستدعى بعد `await _reportService.approveReport(...)` دون فحص بينهما.
```dart
try {
  await _reportService.approveReport(widget.report.id);
  if (!mounted) return;            // ← مضاف قبل استخدام context
  await context.read<DonorProvider>().deleteDonor(_donor!.id);
  if (mounted) { ... }             // الفحص الموجود يبقى
}
```

**expandable_donor_card.dart (~597):** `context` (معامل) يُستخدم في `showDialog` بعد `await showDatePicker` دون فحص. أضف بعد اختيار التاريخ:
```dart
if (selectedDate == null) return;
if (!context.mounted) return;      // ← مضاف (context معامل ⇒ context.mounted)
// ... ثم showDialog(context: context, ...)
```
(الفحص الموجود `if (confirmed != true || !context.mounted) return;` بعد showDialog يبقى.)

---

### النمط الرابع — `Future.delayed` مع GlobalKey (حالة واحدة)
**الملف/السطر:** `about_screen.dart:317` (داخل `onExpansionChanged`).

**العلاج:** أضف فحص `mounted` (State) داخل الـ delayed callback قبل استخدام `ctx`:
```dart
Future.delayed(const Duration(milliseconds: 300), () {
  if (!mounted) return;            // ← مضاف
  final ctx = _devSectionKey.currentContext;
  if (ctx != null) {
    Scrollable.ensureVisible(ctx, ...);
  }
});
```

---

## ✅ قائمة التحقق (Definition of Done)

- [ ] الحالات الـ 12 عولجت بالعلاج المطابق لنمطها.
- [ ] `flutter analyze`: **صفر** تحذيرات `use_build_context_synchronously`.
- [ ] عدد الـ info الكلي نقص بمقدار ~12 (من 191 إلى ~179) دون ظهور أي تحذير/خطأ جديد.
- [ ] لا تغيير في منطق التحميل/التنقّل (فقط حراسة mounted).
- [ ] اختبار يدوي سريع: فتح ثم إغلاق سريع لشاشة لوحة المستشفى/إدارة المتبرعين — لا تعطّل.

---

## 📝 قيد PROJECT_LOG.md المقترح

```
### YYYY-MM-DD — [fix] معالجة 12 حالة BuildContext across async gaps
- **الوصف:** إضافة حراسة mounted/context.mounted للحالات الـ 12 من
  use_build_context_synchronously، مصنّفة في 4 أنماط: Future.microtask في
  initState (7)، .then بعد التنقّل (2)، await متعدّد بفحص ناقص (2)،
  Future.delayed مع GlobalKey (1). لا تغيير في منطق التحميل/التنقّل.
- **الملفات:** manage_donors_screen, blood_type_report_screen,
  hospital_dashboard_screen, manage_donors_hospital_screen,
  blood_type_detailed_report_screen, report_detail_screen,
  expandable_donor_card, about_screen (كلها في lib/screens|widgets)
- **السبب/الدافع:** مخاطر runtime حقيقية (استخدام context لـ widget قد يكون أُغلق).
- **اختبار:** analyze: 0 use_build_context_synchronously، الإجمالي ~179 info ✅ /
  يدوي: فتح/إغلاق سريع بلا تعطّل ✅.
- **Commit:** `<hash>`
```

> **صيغة commit:** `fix: guard BuildContext across async gaps (12 cases)`

---

## ⚠️ تنبيهات

1. **فرّق بين `mounted` و `context.mounted`:** داخل `StatefulWidget` State استخدم `mounted`؛ في دالة تستقبل `context` معاملاً (report_detail، expandable_donor_card، أنماط الأزرار) استخدم `context.mounted` أو `mounted` حسب أيهما في النطاق. التشخيص يوضّح نوع كل حالة.
2. **لا تضف فحصاً مكرّراً** حيث يوجد فحص صحيح أصلاً — أضف فقط حيث الفجوة الفعلية (النمطان الثالث تحديداً يحتاجان فحصاً **إضافياً** في موضع محدّد، لا استبدال الموجود).
3. عالج ملفاً ملفاً وأعد analyze بعد كل ملف للتأكد من تناقص العدد، تفادياً لإصلاح خاطئ يمرّ دون انتباه.
4. **about_screen.dart:** عالج **فقط** حالة async gap (سطر 317). لا تلمس withOpacity في نفس الملف (للمرحلة 6).
