/// نموذج بيانات الأدمن
class AdminModel {
  final String id;
  final String name;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من JSON إلى Model
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool? ?? true,
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
      'name': name,
      'email': email,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديل بعض الحقول
  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

