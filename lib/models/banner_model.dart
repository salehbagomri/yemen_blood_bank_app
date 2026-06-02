import '../services/supabase_service.dart';

/// نموذج بيانات البانر الدعائي / الإعلاني
class BannerModel {
  final String id;
  final String title;
  final String? subtitle;
  final String imagePath; // المسار في Storage (مثال: banners/image.png)
  final String actionType; // none | internal_route | external_url
  final String? actionValue; // مسار الشاشة أو الرابط الخارجي
  final int sortOrder;
  final bool isActive;
  final DateTime? startsAt; // تاريخ بدء التفعيل (اختياري)
  final DateTime? endsAt; // تاريخ انتهاء التفعيل (اختياري)
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imagePath,
    required this.actionType,
    this.actionValue,
    this.sortOrder = 0,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// الحصول على رابط الصورة المباشر من Supabase Storage
  String get imageUrl {
    try {
      return SupabaseService().client.storage.from('banners').getPublicUrl(imagePath);
    } catch (_) {
      // إرجاع مسار فارغ في حالة حدوث خطأ أثناء التشغيل المبكر أو الاختبار
      return '';
    }
  }

  /// التحقق من أن البانر فعال ومدرج ضمن الوقت الحالي
  bool get isCurrentlyVisible {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  /// تحويل من JSON إلى Model
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imagePath: json['image_path'] as String,
      actionType: json['action_type'] as String? ?? 'none',
      actionValue: json['action_value'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startsAt: json['starts_at'] != null ? DateTime.parse(json['starts_at'] as String) : null,
      endsAt: json['ends_at'] != null ? DateTime.parse(json['ends_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_path': imagePath,
      'action_type': actionType,
      'action_value': actionValue,
      'sort_order': sortOrder,
      'is_active': isActive,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديل بعض الحقول (Sentinel Pattern للحقول الاختيارية)
  BannerModel copyWith({
    String? id,
    String? title,
    String? Function()? subtitle,
    String? imagePath,
    String? actionType,
    String? Function()? actionValue,
    int? sortOrder,
    bool? isActive,
    DateTime? Function()? startsAt,
    DateTime? Function()? endsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle != null ? subtitle() : this.subtitle,
      imagePath: imagePath ?? this.imagePath,
      actionType: actionType ?? this.actionType,
      actionValue: actionValue != null ? actionValue() : this.actionValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      startsAt: startsAt != null ? startsAt() : this.startsAt,
      endsAt: endsAt != null ? endsAt() : this.endsAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
