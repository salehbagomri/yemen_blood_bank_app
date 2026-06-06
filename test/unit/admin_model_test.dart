import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/models/admin_model.dart';

void main() {
  final now = DateTime.now();

  AdminModel makeAdmin({
    String? id,
    String? name,
    String? email,
    bool isActive = true,
  }) {
    return AdminModel(
      id: id ?? 'test-admin-id',
      name: name ?? 'أحمد المشرف',
      email: email ?? 'admin@ybb.com',
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('AdminModel — Constructor & default values', () {
    test('يُنشئ الكائن بالقيم الافتراضية الصحيحة', () {
      final admin = makeAdmin();
      expect(admin.isActive, isTrue);
    });
  });

  group('AdminModel — fromJson / toJson', () {
    test('fromJson يُنشئ نموذجاً صحيحاً من خريطة JSON كاملة', () {
      final json = {
        'id': 'adm-999',
        'name': 'صالح باقحوم',
        'email': 'saleh@ybb.com',
        'is_active': true,
        'created_at': '2024-03-01T08:30:00.000Z',
        'updated_at': '2024-03-05T09:00:00.000Z',
      };

      final admin = AdminModel.fromJson(json);

      expect(admin.id, equals('adm-999'));
      expect(admin.name, equals('صالح باقحوم'));
      expect(admin.email, equals('saleh@ybb.com'));
      expect(admin.isActive, isTrue);
      expect(admin.createdAt.year, equals(2024));
      expect(admin.updatedAt.day, equals(5));
    });

    test('fromJson يسقط من updated_at إلى created_at عند غيابه من JSON', () {
      final json = {
        'id': 'adm-888',
        'name': 'عبد الله',
        'email': 'abdullah@ybb.com',
        'created_at': '2024-04-10T12:00:00.000Z',
        'updated_at': null,
      };

      final admin = AdminModel.fromJson(json);
      expect(admin.updatedAt, equals(admin.createdAt));
    });

    test('toJson يُنتج خريطة JSON صحيحة ومطابقة', () {
      final admin = makeAdmin(id: 'adm-001', name: 'أدمن 1');
      final json = admin.toJson();

      expect(json['id'], equals('adm-001'));
      expect(json['name'], equals('أدمن 1'));
      expect(json['email'], equals('admin@ybb.com'));
      expect(json['is_active'], isTrue);
    });
  });

  group('AdminModel — copyWith', () {
    test('copyWith ينسخ النموذج مع تعديل الحقول الممررة فقط', () {
      final original = makeAdmin(
        id: 'adm-orig',
        name: 'الأصلي',
        isActive: true,
      );

      final copy = original.copyWith(
        name: 'المعدل',
        isActive: false,
      );

      expect(copy.id, equals('adm-orig'));
      expect(copy.name, equals('المعدل'));
      expect(copy.isActive, isFalse);
    });
  });
}
