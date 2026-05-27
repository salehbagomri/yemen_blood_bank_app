// =====================================================================
// Unit Tests: Validators
// =====================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/utils/validators.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════
  group('Validators.validateName', () {
    test('يقبل الأسماء العربية الصحيحة', () {
      expect(Validators.validateName('أحمد محمد'), isNull);
      expect(Validators.validateName('فاطمة علي القحطاني'), isNull);
      expect(Validators.validateName('سالم'), isNull);
    });

    test('يرفض الاسم الفارغ أو null', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('   '), isNotNull);
      expect(Validators.validateName(null), isNotNull);
    });

    test('يرفض الاسم الأقل من 3 أحرف', () {
      expect(Validators.validateName('ab'), isNotNull);
      expect(Validators.validateName('أح'), isNotNull);
    });

    test('يقبل اسم مكوّن من 3 أحرف بالضبط', () {
      expect(Validators.validateName('abc'), isNull);
      expect(Validators.validateName('أحم'), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validatePhoneNumber', () {
    test('يقبل أرقام يمنية صحيحة بـ 9 أرقام تبدأ بـ 7', () {
      expect(Validators.validatePhoneNumber('777123456'), isNull);
      expect(Validators.validatePhoneNumber('711000000'), isNull);
      expect(Validators.validatePhoneNumber('733999888'), isNull);
      expect(Validators.validatePhoneNumber('700000000'), isNull);
    });

    test('يقبل أرقام بكود الدولة +967', () {
      expect(Validators.validatePhoneNumber('967777123456'), isNull);
    });

    test('يقبل أرقام بكود الدولة 00967', () {
      expect(Validators.validatePhoneNumber('00967777123456'), isNull);
    });

    test('يرفض الرقم الفارغ', () {
      expect(Validators.validatePhoneNumber(''), isNotNull);
      expect(Validators.validatePhoneNumber(null), isNotNull);
    });

    test('يرفض أرقام قصيرة جداً', () {
      expect(Validators.validatePhoneNumber('123'), isNotNull);
      expect(Validators.validatePhoneNumber('7771'), isNotNull);
    });

    test('يرفض أرقام لا تبدأ بـ 7 (بعد إزالة كود الدولة)', () {
      // رقم مكوّن من 9 أرقام لكن لا يبدأ بـ 7
      expect(Validators.validatePhoneNumber('999999999'), isNotNull);
      expect(Validators.validatePhoneNumber('222222222'), isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validateAge', () {
    test('يقبل الأعمار الصحيحة بين 18 و 65', () {
      expect(Validators.validateAge('18'), isNull);
      expect(Validators.validateAge('25'), isNull);
      expect(Validators.validateAge('40'), isNull);
      expect(Validators.validateAge('65'), isNull);
    });

    test('يرفض العمر الأقل من 18', () {
      expect(Validators.validateAge('17'), isNotNull);
      expect(Validators.validateAge('1'), isNotNull);
      expect(Validators.validateAge('0'), isNotNull);
    });

    test('يرفض العمر الأكبر من 65', () {
      expect(Validators.validateAge('66'), isNotNull);
      expect(Validators.validateAge('100'), isNotNull);
    });

    test('يرفض النص غير الرقمي', () {
      expect(Validators.validateAge('abc'), isNotNull);
      expect(Validators.validateAge('عشرون'), isNotNull);
    });

    test('يرفض القيمة الفارغة أو null', () {
      expect(Validators.validateAge(''), isNotNull);
      expect(Validators.validateAge(null), isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validateEmail', () {
    test('يقبل بريد إلكتروني صحيح', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.name+tag@domain.org'), isNull);
    });

    test('يرفض بريد إلكتروني غير صحيح', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('missing@'), isNotNull);
      expect(Validators.validateEmail('@nodomain.com'), isNotNull);
    });

    test('يرفض الفارغ أو null', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validatePassword', () {
    test('يقبل كلمات مرور صحيحة', () {
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('abc123'), isNull);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('يرفض كلمة مرور أقل من 6 أحرف', () {
      expect(Validators.validatePassword('abc'), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('يرفض الفارغ أو null', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validateNotEmpty', () {
    test('يقبل النص غير الفارغ', () {
      expect(Validators.validateNotEmpty('Hello', 'الحقل'), isNull);
    });

    test('يرفض النص الفارغ أو المسافات فقط', () {
      expect(Validators.validateNotEmpty('', 'الحقل'), isNotNull);
      expect(Validators.validateNotEmpty('   ', 'الحقل'), isNotNull);
      expect(Validators.validateNotEmpty(null, 'الحقل'), isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('Validators.validateInList', () {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    test('يقبل القيمة الموجودة في القائمة', () {
      expect(Validators.validateInList('A+', bloodTypes, 'الفصيلة'), isNull);
      expect(Validators.validateInList('O-', bloodTypes, 'الفصيلة'), isNull);
    });

    test('يرفض القيمة غير الموجودة في القائمة', () {
      expect(Validators.validateInList('X+', bloodTypes, 'الفصيلة'), isNotNull);
      expect(Validators.validateInList('Z', bloodTypes, 'الفصيلة'), isNotNull);
    });

    test('يرفض القيمة الفارغة أو null', () {
      expect(Validators.validateInList('', bloodTypes, 'الفصيلة'), isNotNull);
      expect(Validators.validateInList(null, bloodTypes, 'الفصيلة'), isNotNull);
    });
  });
}
