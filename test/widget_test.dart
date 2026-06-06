// =====================================================================
// Test Runner - يجمع جميع اختبارات التطبيق
//
// تنظيم الاختبارات:
//   test/unit/    → Unit tests (لا تحتاج Flutter)
//   test/widget/  → Widget tests (تحتاج Flutter/MaterialApp)
//
// تشغيل الاختبارات:
//   flutter test                          (جميع الاختبارات)
//   flutter test test/unit/              (Unit tests فقط)
//   flutter test test/widget/            (Widget tests فقط)
//   flutter test --coverage              (مع تقرير Coverage)
// =====================================================================

// Unit Tests
import 'unit/donor_model_test.dart' as donor_model;
import 'unit/validators_test.dart' as validators;
import 'unit/helpers_test.dart' as helpers;
import 'unit/constants_test.dart' as constants;
import 'unit/hospital_model_test.dart' as hospital_model;
import 'unit/admin_model_test.dart' as admin_model;
import 'unit/banner_model_test.dart' as banner_model;

// Widget Tests
import 'widget/shimmer_test.dart' as shimmer;

void main() {
  // ── Unit Tests ──────────────────────────────────────────────────
  donor_model.main();
  validators.main();
  helpers.main();
  constants.main();
  hospital_model.main();
  admin_model.main();
  banner_model.main();

  // ── Widget Tests ────────────────────────────────────────────────
  shimmer.main();
}
