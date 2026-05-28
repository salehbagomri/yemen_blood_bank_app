/// نموذج بيانات المستشفى
class HospitalModel {
  final String id;
  final String name;
  final String email;
  final String district;
  final String? phoneNumber;
  final String? address;
  final bool isActive; // حساب نشط أم معطل
  final DateTime createdAt;
  final DateTime updatedAt;

  HospitalModel({
    required this.id,
    required this.name,
    required this.email,
    required this.district,
    this.phoneNumber,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من JSON إلى Model
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      district: json['district'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
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
      'district': district,
      'phone_number': phoneNumber,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديل بعض الحقول
  HospitalModel copyWith({
    String? id,
    String? name,
    String? email,
    String? district,
    String? phoneNumber,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      district: district ?? this.district,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

