import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/models/hospital_model.dart';

void main() {
  final now = DateTime.now();

  HospitalModel makeHospital({
    String? id,
    String? name,
    String? email,
    String? district,
    String? governorate,
    String? phoneNumber,
    String? address,
    bool isActive = true,
  }) {
    return HospitalModel(
      id: id ?? 'test-hospital-id',
      name: name ?? 'مستشفى الأمل',
      email: email ?? 'hope@hospital.com',
      district: district ?? 'حضرموت - المكلا',
      governorate: governorate,
      phoneNumber: phoneNumber,
      address: address,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('HospitalModel — Constructor & Field Derivation', () {
    test('يُنشئ الكائن بالبيانات الممررة مباشرة', () {
      final h = makeHospital(governorate: 'حضرموت');
      expect(h.governorate, equals('حضرموت'));
    });

    test('يشتق governorate من district عندما يكون governorate فارغاً أو null', () {
      final h = makeHospital(district: 'عدن - المنصورة', governorate: null);
      expect(h.governorate, equals('عدن'));

      final hEmpty = makeHospital(district: 'تعز - القاهرة', governorate: '');
      expect(hEmpty.governorate, equals('تعز'));
    });
  });

  group('HospitalModel — fromJson / toJson', () {
    test('fromJson يُنشئ نموذجاً صحيحاً من خريطة JSON كاملة', () {
      final json = {
        'id': 'hosp-123',
        'name': 'مستشفى الثورة',
        'email': 'althawra@test.com',
        'district': 'أمانة العاصمة - السبعين',
        'governorate': 'أمانة العاصمة',
        'phone_number': '777111222',
        'address': 'شارع السبعين',
        'is_active': true,
        'created_at': '2024-01-01T10:00:00.000Z',
        'updated_at': '2024-01-02T12:00:00.000Z',
      };

      final h = HospitalModel.fromJson(json);

      expect(h.id, equals('hosp-123'));
      expect(h.name, equals('مستشفى الثورة'));
      expect(h.email, equals('althawra@test.com'));
      expect(h.district, equals('أمانة العاصمة - السبعين'));
      expect(h.governorate, equals('أمانة العاصمة'));
      expect(h.phoneNumber, equals('777111222'));
      expect(h.address, equals('شارع السبعين'));
      expect(h.isActive, isTrue);
      expect(h.createdAt.year, equals(2024));
      expect(h.updatedAt.day, equals(2));
    });

    test('fromJson يشتق governorate من district عند غيابه من JSON', () {
      final json = {
        'id': 'hosp-456',
        'name': 'مستشفى ابن سينا',
        'email': 'ibnsina@test.com',
        'district': 'حضرموت - المكلا',
        'created_at': '2024-01-01T10:00:00.000Z',
      };

      final h = HospitalModel.fromJson(json);
      expect(h.governorate, equals('حضرموت'));
    });

    test('fromJson يسقط من updated_at إلى created_at عند غيابه', () {
      final json = {
        'id': 'hosp-789',
        'name': 'مستشفى الجمهورية',
        'email': 'jamhuria@test.com',
        'district': 'عدن - خور مكسر',
        'created_at': '2024-05-01T00:00:00.000Z',
        'updated_at': null,
      };

      final h = HospitalModel.fromJson(json);
      expect(h.updatedAt, equals(h.createdAt));
    });

    test('toJson يُنتج خريطة JSON صحيحة ومطابقة', () {
      final h = makeHospital(
        id: 'h-1',
        name: 'مستشفى 1',
        phoneNumber: '711222333',
      );
      final json = h.toJson();

      expect(json['id'], equals('h-1'));
      expect(json['name'], equals('مستشفى 1'));
      expect(json['phone_number'], equals('711222333'));
      expect(json['district'], equals('حضرموت - المكلا'));
      expect(json['governorate'], equals('حضرموت'));
      expect(json['is_active'], isTrue);
    });
  });

  group('HospitalModel — copyWith', () {
    test('copyWith ينسخ النموذج مع تعديل الحقول الممررة فقط', () {
      final original = makeHospital(
        id: 'orig-id',
        name: 'المستشفى الأصلي',
        phoneNumber: '777000000',
        address: 'عنوان أصلي',
      );

      final copy = original.copyWith(
        name: 'المستشفى المعدل',
        isActive: false,
      );

      expect(copy.id, equals('orig-id'));
      expect(copy.name, equals('المستشفى المعدل'));
      expect(copy.phoneNumber, equals('777000000'));
      expect(copy.address, equals('عنوان أصلي'));
      expect(copy.isActive, isFalse);
    });

    test('copyWith يسمح بتعيين الحقول الاختيارية إلى null باستخدام sentinel', () {
      final original = makeHospital(
        phoneNumber: '777000000',
        address: 'عنوان أصلي',
      );

      final copy = original.copyWith(
        phoneNumber: null,
        address: null,
      );

      expect(copy.phoneNumber, isNull);
      expect(copy.address, isNull);
    });
  });
}
