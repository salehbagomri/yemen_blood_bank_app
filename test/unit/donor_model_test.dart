// =====================================================================
// Unit Tests: DonorModel
// يختبر منطق النموذج بشكل كامل — بدون حاجة لـ Flutter أو شبكة
// =====================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/models/donor_model.dart';

void main() {
  // ── بيانات اختبار ───────────────────────────────────────────────
  final now = DateTime.now();

  DonorModel _makeAvailableDonor({String? lastDonation}) {
    return DonorModel(
      id: 'test-id-1',
      name: 'أحمد محمد',
      phoneNumber: '777123456',
      bloodType: 'A+',
      district: 'الغيضة',
      age: 25,
      gender: 'male',
      createdAt: now,
      updatedAt: now,
      isAvailable: true,
      lastDonationDate: lastDonation != null
          ? DateTime.parse(lastDonation)
          : null,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — fromJson / toJson', () {
    test('fromJson يُنشئ نموذجاً صحيحاً', () {
      final json = {
        'id': 'abc-123',
        'name': 'فاطمة علي',
        'phone_number': '711000000',
        'phone_number_2': null,
        'phone_number_3': null,
        'blood_type': 'O-',
        'district': 'سيحوت',
        'age': 30,
        'gender': 'female',
        'notes': null,
        'is_available': true,
        'last_donation_date': null,
        'suspended_until': null,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'added_by': null,
        'is_active': true,
      };

      final donor = DonorModel.fromJson(json);

      expect(donor.id, equals('abc-123'));
      expect(donor.name, equals('فاطمة علي'));
      expect(donor.bloodType, equals('O-'));
      expect(donor.district, equals('سيحوت'));
      expect(donor.age, equals(30));
      expect(donor.gender, equals('female'));
      expect(donor.isAvailable, isTrue);
      expect(donor.isActive, isTrue);
      expect(donor.lastDonationDate, isNull);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final donor = _makeAvailableDonor();
      final json = donor.toJson();

      expect(json['id'], equals('test-id-1'));
      expect(json['name'], equals('أحمد محمد'));
      expect(json['blood_type'], equals('A+'));
      expect(json['district'], equals('الغيضة'));
      expect(json['age'], equals(25));
      expect(json['gender'], equals('male'));
      expect(json['is_available'], isTrue);
    });

    test('fromJson يعالج التواريخ بشكل صحيح', () {
      final json = {
        'id': 'x',
        'name': 'سالم',
        'phone_number': '777000001',
        'phone_number_2': null,
        'phone_number_3': null,
        'blood_type': 'B+',
        'district': 'حصوين',
        'age': 28,
        'gender': 'male',
        'notes': null,
        'is_available': false,
        'last_donation_date': '2024-06-01T00:00:00.000Z',
        'suspended_until': '2024-12-01T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-06-01T00:00:00.000Z',
        'added_by': null,
        'is_active': true,
      };

      final donor = DonorModel.fromJson(json);
      expect(donor.lastDonationDate, isNotNull);
      expect(donor.lastDonationDate!.year, equals(2024));
      expect(donor.lastDonationDate!.month, equals(6));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — isSuspended', () {
    test('يُرجع false إذا لم يكن موقوفاً', () {
      final donor = _makeAvailableDonor();
      expect(donor.isSuspended, isFalse);
    });

    test('يُرجع true إذا كان موقوفاً في المستقبل', () {
      final future = now.add(const Duration(days: 60));
      final donor = DonorModel(
        id: 'x',
        name: 'محمد',
        phoneNumber: '777000002',
        bloodType: 'B-',
        district: 'قشن',
        age: 22,
        gender: 'male',
        createdAt: now,
        updatedAt: now,
        suspendedUntil: future,
        isAvailable: false,
      );
      expect(donor.isSuspended, isTrue);
    });

    test('يُرجع false إذا مرّت فترة الإيقاف', () {
      final past = now.subtract(const Duration(days: 10));
      final donor = DonorModel(
        id: 'x',
        name: 'محمد',
        phoneNumber: '777000003',
        bloodType: 'AB+',
        district: 'حات',
        age: 35,
        gender: 'male',
        createdAt: now,
        updatedAt: now,
        suspendedUntil: past,
        isAvailable: true,
      );
      expect(donor.isSuspended, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — canDonateNow', () {
    test('يُرجع true إذا كان متاحاً ولم يتبرع من قبل', () {
      final donor = _makeAvailableDonor();
      expect(donor.canDonateNow, isTrue);
    });

    test('يُرجع false إذا تبرع منذ أقل من 6 أشهر', () {
      final recentDonation = now
          .subtract(const Duration(days: 30))
          .toIso8601String();
      final donor = _makeAvailableDonor(lastDonation: recentDonation);
      expect(donor.canDonateNow, isFalse);
    });

    test('يُرجع true إذا مر أكثر من 6 أشهر على آخر تبرع', () {
      final oldDonation = now
          .subtract(const Duration(days: 200))
          .toIso8601String();
      final donor = _makeAvailableDonor(lastDonation: oldDonation);
      expect(donor.canDonateNow, isTrue);
    });

    test('يُرجع false إذا كان غير نشط', () {
      final donor = DonorModel(
        id: 'x',
        name: '...',
        phoneNumber: '777000004',
        bloodType: 'O+',
        district: 'حوف',
        age: 40,
        gender: 'male',
        createdAt: now,
        updatedAt: now,
        isActive: false,
        isAvailable: true,
      );
      expect(donor.canDonateNow, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — allPhoneNumbers', () {
    test('يُرجع قائمة بالأرقام غير الفارغة فقط', () {
      final donor = DonorModel(
        id: 'x',
        name: '...',
        phoneNumber: '777000000',
        phoneNumber2: '711000000',
        phoneNumber3: '', // فارغ — لا يُضاف
        bloodType: 'O+',
        district: 'الغيضة',
        age: 30,
        gender: 'male',
        createdAt: now,
        updatedAt: now,
      );
      expect(donor.allPhoneNumbers.length, equals(2));
      expect(donor.allPhoneNumbers, contains('777000000'));
      expect(donor.allPhoneNumbers, contains('711000000'));
    });

    test('يُرجع قائمة برقم واحد إذا لم يكن هناك أرقام إضافية', () {
      final donor = _makeAvailableDonor();
      expect(donor.allPhoneNumbers.length, equals(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — copyWith', () {
    test('ينسخ النموذج مع تعديل بعض الحقول فقط', () {
      final original = _makeAvailableDonor();
      final copy = original.copyWith(name: 'عمر أحمد', age: 32);

      // الحقول المعدّلة
      expect(copy.name, equals('عمر أحمد'));
      expect(copy.age, equals(32));

      // بقية الحقول لم تتغير
      expect(copy.id, equals(original.id));
      expect(copy.bloodType, equals(original.bloodType));
      expect(copy.phoneNumber, equals(original.phoneNumber));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorModel — daysUntilCanDonate', () {
    test('يُرجع 0 إذا كان يمكنه التبرع الآن', () {
      final donor = _makeAvailableDonor();
      expect(donor.daysUntilCanDonate, equals(0));
    });

    test('يُرجع عدداً موجباً إذا كان موقوفاً', () {
      final future = now.add(const Duration(days: 30));
      final donor = DonorModel(
        id: 'x',
        name: '...',
        phoneNumber: '777000005',
        bloodType: 'A-',
        district: 'منعر',
        age: 28,
        gender: 'male',
        createdAt: now,
        updatedAt: now,
        suspendedUntil: future,
        isAvailable: false,
      );
      expect(donor.daysUntilCanDonate, greaterThan(0));
      expect(donor.daysUntilCanDonate, lessThanOrEqualTo(30));
    });
  });
}
