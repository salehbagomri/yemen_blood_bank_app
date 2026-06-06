import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/models/banner_model.dart';

void main() {
  final now = DateTime.now();

  BannerModel makeBanner({
    String? id,
    String? title,
    String? subtitle,
    String? imagePath,
    String actionType = 'none',
    String? actionValue,
    int sortOrder = 0,
    bool isActive = true,
    String? iconName,
    String? bgGradient,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return BannerModel(
      id: id ?? 'banner-123',
      title: title ?? 'إعلان تجريبي',
      subtitle: subtitle,
      imagePath: imagePath,
      actionType: actionType,
      actionValue: actionValue,
      sortOrder: sortOrder,
      isActive: isActive,
      iconName: iconName,
      bgGradient: bgGradient,
      startsAt: startsAt,
      endsAt: endsAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('BannerModel — Banner Type (Image vs Text)', () {
    test('يُحدد البانر كبانر صوري عند وجود مسار الصورة', () {
      final banner = makeBanner(imagePath: 'storage/banner.png');
      expect(banner.isTextBanner, isFalse);
    });

    test('يُحدد البانر كبانر نصي عند غياب مسار الصورة أو كونها فارغة', () {
      final bannerNull = makeBanner(imagePath: null);
      expect(bannerNull.isTextBanner, isTrue);

      final bannerEmpty = makeBanner(imagePath: '');
      expect(bannerEmpty.isTextBanner, isTrue);
    });

    test('imageUrl يُرجع نصاً فارغاً إذا كان مسار الصورة فارغاً أو null', () {
      final banner = makeBanner(imagePath: null);
      expect(banner.imageUrl, isEmpty);
    });

    test('imageUrl يعالج استثناء SupabaseService ويُرجع نصاً فارغاً عند عدم التهيئة', () {
      final banner = makeBanner(imagePath: 'storage/banner.png');
      // بما أن الـ SupabaseService غير مهيأ في بيئة اختبار الوحدة،
      // الميثود imageUrl ستصطاد خطأ التهيئة وتُرجع '' بدلاً من الانهيار.
      expect(banner.imageUrl, isEmpty);
    });
  });

  group('BannerModel — Visibility Logic (isCurrentlyVisible)', () {
    test('يُرجع false إذا كان isActive = false', () {
      final banner = makeBanner(isActive: false);
      expect(banner.isCurrentlyVisible, isFalse);
    });

    test('يُرجع false إذا كان تاريخ البدء startsAt في المستقبل', () {
      final future = now.add(const Duration(days: 1));
      final banner = makeBanner(startsAt: future);
      expect(banner.isCurrentlyVisible, isFalse);
    });

    test('يُرجع false إذا كان تاريخ الانتهاء endsAt في الماضي', () {
      final past = now.subtract(const Duration(days: 1));
      final banner = makeBanner(endsAt: past);
      expect(banner.isCurrentlyVisible, isFalse);
    });

    test('يُرجع true إذا كان البانر نشطاً وضمن النطاق الزمني المحدد', () {
      final past = now.subtract(const Duration(days: 1));
      final future = now.add(const Duration(days: 1));
      final banner = makeBanner(startsAt: past, endsAt: future);
      expect(banner.isCurrentlyVisible, isTrue);
    });
  });

  group('BannerModel — fromJson / toJson', () {
    test('fromJson يُنشئ نموذجاً صحيحاً مع كافة الحقول الإضافية والتواريخ', () {
      final json = {
        'id': 'b-444',
        'title': 'إعلان تبرع عاجل',
        'subtitle': 'فصيلة O- مطلوبة',
        'image_path': 'banners/urg.png',
        'action_type': 'internal_route',
        'action_value': '/search',
        'sort_order': 2,
        'is_active': true,
        'icon_name': 'favorite',
        'bg_gradient': 'red',
        'starts_at': '2024-01-01T00:00:00.000Z',
        'ends_at': '2024-12-31T23:59:59.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T12:00:00.000Z',
      };

      final banner = BannerModel.fromJson(json);

      expect(banner.id, equals('b-444'));
      expect(banner.title, equals('إعلان تبرع عاجل'));
      expect(banner.subtitle, equals('فصيلة O- مطلوبة'));
      expect(banner.imagePath, equals('banners/urg.png'));
      expect(banner.actionType, equals('internal_route'));
      expect(banner.actionValue, equals('/search'));
      expect(banner.sortOrder, equals(2));
      expect(banner.isActive, isTrue);
      expect(banner.iconName, equals('favorite'));
      expect(banner.bgGradient, equals('red'));
      expect(banner.startsAt!.year, equals(2024));
      expect(banner.endsAt!.month, equals(12));
      expect(banner.createdAt.year, equals(2024));
      expect(banner.updatedAt.day, equals(2));
    });

    test('fromJson يسقط من updated_at إلى created_at عند غيابه', () {
      final json = {
        'id': 'b-555',
        'title': 'إعلان بسيط',
        'created_at': '2024-05-01T00:00:00.000Z',
        'updated_at': null,
      };

      final banner = BannerModel.fromJson(json);
      expect(banner.updatedAt, equals(banner.createdAt));
    });

    test('toJson يُنتج خريطة JSON صحيحة مطابقة للبيانات', () {
      final banner = makeBanner(
        id: 'b-1',
        title: 'تجربة',
        iconName: 'home',
        startsAt: DateTime.utc(2024, 1, 1),
      );

      final json = banner.toJson();

      expect(json['id'], equals('b-1'));
      expect(json['title'], equals('تجربة'));
      expect(json['icon_name'], equals('home'));
      expect(json['starts_at'], equals('2024-01-01T00:00:00.000Z'));
    });
  });

  group('BannerModel — copyWith', () {
    test('copyWith ينسخ مع تعديل القيم الممررة فقط', () {
      final original = makeBanner(
        id: 'b-orig',
        title: 'العنوان الأصلي',
        isActive: true,
      );

      final copy = original.copyWith(
        title: 'العنوان الجديد',
        isActive: false,
      );

      expect(copy.id, equals('b-orig'));
      expect(copy.title, equals('العنوان الجديد'));
      expect(copy.isActive, isFalse);
    });

    test('copyWith يسمح بتعيين حقول فارغة أو null باستخدام دالة التمرير', () {
      final original = makeBanner(
        subtitle: 'فرعي أصلي',
        imagePath: 'images/banner.png',
      );

      final copy = original.copyWith(
        subtitle: () => null,
        imagePath: () => null,
      );

      expect(copy.subtitle, isNull);
      expect(copy.imagePath, isNull);
    });
  });
}
