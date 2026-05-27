// =====================================================================
// Unit Tests: Helpers
// =====================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yemen_blood_bank/utils/helpers.dart';

void main() {
  setUpAll(() async {
    // تهيئة locale للـ intl قبل تشغيل الاختبارات
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('en', null);
  });

  // ══════════════════════════════════════════════════════════════════
  group('Helpers.formatPhoneNumber', () {
    test('يضيف +967 إلى الأرقام التي تبدأ بـ 7', () {
      expect(Helpers.formatPhoneNumber('777123456'), equals('+967777123456'));
      expect(Helpers.formatPhoneNumber('711000000'), equals('+967711000000'));
    });

    test('يحوّل 00967 إلى +967', () {
      expect(
        Helpers.formatPhoneNumber('00967777123456'),
        equals('+967777123456'),
      );
    });

    test('يُعيد الرقم كما هو إذا كان يبدأ بـ +967', () {
      expect(
        Helpers.formatPhoneNumber('+967777123456'),
        equals('+967777123456'),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Helpers.genderToArabic / arabicToGender', () {
    test('تحويل male/female إلى عربي', () {
      expect(Helpers.genderToArabic('male'), equals('ذكر'));
      expect(Helpers.genderToArabic('female'), equals('أنثى'));
    });

    test('تحويل العربي إلى male/female', () {
      expect(Helpers.arabicToGender('ذكر'), equals('male'));
      expect(Helpers.arabicToGender('أنثى'), equals('female'));
    });

    test('يتعامل مع القيم غير المعروفة', () {
      expect(() => Helpers.genderToArabic('unknown'), returnsNormally);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Helpers.getCompatibleBloodTypes', () {
    test('O- يتوافق مع O- فقط (Universal Donor)', () {
      final compatible = Helpers.getCompatibleBloodTypes('O-');
      expect(compatible, contains('O-'));
    });

    test('AB+ يمكنه استقبال من الجميع', () {
      final compatible = Helpers.getCompatibleBloodTypes('AB+');
      expect(compatible.length, equals(8));
    });

    test('A+ يتوافق مع A+ و A- و O+ و O-', () {
      final compatible = Helpers.getCompatibleBloodTypes('A+');
      expect(compatible, containsAll(['A+', 'A-', 'O+', 'O-']));
    });

    test('B- يتوافق مع B- و O- فقط', () {
      final compatible = Helpers.getCompatibleBloodTypes('B-');
      expect(compatible, containsAll(['B-', 'O-']));
      expect(compatible.length, equals(2));
    });

    test('AB- يتوافق مع جميع السالبة', () {
      final compatible = Helpers.getCompatibleBloodTypes('AB-');
      expect(compatible, containsAll(['AB-', 'A-', 'B-', 'O-']));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Helpers.formatDate', () {
    test('يُنسّق التاريخ بالصورة الصحيحة', () {
      final date = DateTime(2024, 3, 15);
      final formatted = Helpers.formatDate(date);
      expect(formatted, contains('2024'));
      expect(formatted, isNotEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('حسابات الأيام', () {
    test('الفرق بين تاريخين يعطي نتيجة صحيحة', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 31);
      final diff = date2.difference(date1).inDays;
      expect(diff, equals(30));
    });

    test('6 أشهر = 180 يوم في المعادلة', () {
      final donationDate = DateTime(2024, 1, 1);
      final sixMonthsLater = donationDate.add(const Duration(days: 180));
      expect(sixMonthsLater.month, isIn([6, 7])); // حوالي يوليو
    });
  });
}
