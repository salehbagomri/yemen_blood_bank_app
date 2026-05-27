// =====================================================================
// Unit Tests: AppStrings و AppColors
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/constants/app_strings.dart';
import 'package:yemen_blood_bank/constants/app_colors.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════
  group('AppStrings', () {
    test('اسم التطبيق صحيح', () {
      expect(AppStrings.appName, equals('بنك دم اليمن'));
      expect(AppStrings.appNameEnglish, equals('Yemen Blood Bank'));
    });

    test('قائمة المديريات تحتوي على 9 مديريات', () {
      expect(AppStrings.districts.length, equals(9));
    });

    test('قائمة المديريات تحتوي على المديريات الصحيحة', () {
      const expectedDistricts = [
        'الغيضة',
        'سيحوت',
        'حصوين',
        'قشن',
        'حات',
        'حوف',
        'منعر',
        'المسيلة',
        'شحن',
      ];
      for (final district in expectedDistricts) {
        expect(
          AppStrings.districts,
          contains(district),
          reason: 'يجب أن تحتوي القائمة على "$district"',
        );
      }
    });

    test('النصوص الأساسية غير فارغة', () {
      expect(AppStrings.searchForDonors, isNotEmpty);
      expect(AppStrings.selectBloodType, isNotEmpty);
      expect(AppStrings.selectDistrict, isNotEmpty);
      expect(AppStrings.noDonorsFound, isNotEmpty);
      expect(AppStrings.bloodType, isNotEmpty);
      expect(AppStrings.district, isNotEmpty);
    });

    test('قيم الجنس صحيحة', () {
      expect(AppStrings.male, equals('ذكر'));
      expect(AppStrings.female, equals('أنثى'));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('AppColors', () {
    test('اللون الأساسي معرّف', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primaryDark, isNotNull);
    });

    test('ألوان النجاح والخطأ والتحذير معرّفة', () {
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
    });

    test('ألوان فصائل الدم الأربع معرّفة', () {
      expect(AppColors.bloodTypeA, isNotNull);
      expect(AppColors.bloodTypeB, isNotNull);
      expect(AppColors.bloodTypeAB, isNotNull);
      expect(AppColors.bloodTypeO, isNotNull);
    });

    test('ألوان النصوص معرّفة', () {
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.textSecondary, isNotNull);
    });

    test('لون الخلفية معرّف', () {
      expect(AppColors.background, isNotNull);
      expect(AppColors.background, isA<Color>());
    });
  });
}
