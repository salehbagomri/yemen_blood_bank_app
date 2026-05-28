/// نموذج بيانات المتبرع
class DonorModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? phoneNumber2; // رقم هاتف إضافي 1
  final String? phoneNumber3; // رقم هاتف إضافي 2
  final String bloodType;
  final String district;
  final String governorate; // المحافظة — تُشتق من district إن لم تُمرَّر
  final int age;
  final String gender; // male or female
  final String? notes;
  final bool isAvailable; // هل المتبرع متاح للتبرع؟
  final DateTime? lastDonationDate; // آخر تاريخ تبرع
  final DateTime? suspendedUntil; // موقوف حتى (إذا كان موقوفاً)
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? addedBy; // معرف المستشفى أو الأدمن الذي أضاف المتبرع
  final bool isActive; // حساب نشط أم معطل

  DonorModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.phoneNumber2,
    this.phoneNumber3,
    required this.bloodType,
    required String district,
    String? governorate,
    required this.age,
    required this.gender,
    this.notes,
    this.isAvailable = true,
    this.lastDonationDate,
    this.suspendedUntil,
    required this.createdAt,
    required this.updatedAt,
    this.addedBy,
    this.isActive = true,
  })  : district = district,
        governorate = (governorate != null && governorate.isNotEmpty)
            ? governorate
            : district.split(' - ').first;

  /// تحويل من JSON إلى Model
  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      phoneNumber2: json['phone_number_2'] as String?,
      phoneNumber3: json['phone_number_3'] as String?,
      bloodType: json['blood_type'] as String,
      district: json['district'] as String,
      governorate: json['governorate'] as String?,
      age: json['age'] as int,
      gender: json['gender'] as String,
      notes: json['notes'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'] as String)
          : null,
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.parse(json['suspended_until'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
      addedBy: json['added_by'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'phone_number_2': phoneNumber2,
      'phone_number_3': phoneNumber3,
      'blood_type': bloodType,
      'district': district,
      'governorate': governorate,
      'age': age,
      'gender': gender,
      'notes': notes,
      'is_available': isAvailable,
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'suspended_until': suspendedUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'added_by': addedBy,
      'is_active': isActive,
    };
  }

  /// الحصول على قائمة بجميع الأرقام (غير الفارغة)
  List<String> get allPhoneNumbers {
    final numbers = <String>[phoneNumber];
    if (phoneNumber2 != null && phoneNumber2!.isNotEmpty) {
      numbers.add(phoneNumber2!);
    }
    if (phoneNumber3 != null && phoneNumber3!.isNotEmpty) {
      numbers.add(phoneNumber3!);
    }
    return numbers;
  }

  /// نسخ مع تعديل بعض الحقول
  DonorModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? phoneNumber2,
    String? phoneNumber3,
    String? bloodType,
    String? district,
    String? governorate,
    int? age,
    String? gender,
    String? notes,
    bool? isAvailable,
    DateTime? lastDonationDate,
    DateTime? suspendedUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? addedBy,
    bool? isActive,
  }) {
    return DonorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      phoneNumber3: phoneNumber3 ?? this.phoneNumber3,
      bloodType: bloodType ?? this.bloodType,
      district: district ?? this.district,
      governorate: governorate ?? this.governorate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addedBy: addedBy ?? this.addedBy,
      isActive: isActive ?? this.isActive,
    );
  }

  /// هل المتبرع موقوف حالياً؟
  bool get isSuspended {
    if (suspendedUntil == null) return false;
    return DateTime.now().isBefore(suspendedUntil!);
  }

  /// هل يمكن للمتبرع التبرع الآن؟
  bool get canDonateNow {
    if (!isAvailable || !isActive) return false;
    if (isSuspended) return false;
    
    // التحقق من مرور 6 أشهر على آخر تبرع
    if (lastDonationDate != null) {
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      return lastDonationDate!.isBefore(sixMonthsAgo);
    }
    
    return true;
  }

  /// عدد الأيام المتبقية حتى يمكن التبرع
  int? get daysUntilCanDonate {
    if (canDonateNow) return 0;
    
    if (isSuspended && suspendedUntil != null) {
      return suspendedUntil!.difference(DateTime.now()).inDays;
    }
    
    if (lastDonationDate != null) {
      final sixMonthsFromLast = lastDonationDate!.add(const Duration(days: 180));
      if (DateTime.now().isBefore(sixMonthsFromLast)) {
        return sixMonthsFromLast.difference(DateTime.now()).inDays;
      }
    }
    
    return null;
  }
}

