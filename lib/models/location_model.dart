// نماذج المناطق (المحافظات والمديريات) المُدارة من قاعدة البيانات

class GovernorateModel {
  final String name;
  final bool isActive;
  final int sortOrder;

  GovernorateModel({
    required this.name,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class DistrictModel {
  final String id;
  final String governorate;
  final String name;
  final bool isActive;

  DistrictModel({
    required this.id,
    required this.governorate,
    required this.name,
    this.isActive = true,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String,
      governorate: json['governorate'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// حزمة المناطق المفعّلة المستخدمة في القوائم المنسدلة
class LocationData {
  final List<String> governorates; // محافظات مفعّلة (مرتبة)
  final Map<String, List<String>> districtsByGov; // مديريات مفعّلة لكل محافظة

  const LocationData({
    required this.governorates,
    required this.districtsByGov,
  });

  Map<String, dynamic> toJson() => {
        'governorates': governorates,
        'districtsByGov': districtsByGov,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final govs = (json['governorates'] as List).map((e) => e as String).toList();
    final raw = (json['districtsByGov'] as Map);
    final map = <String, List<String>>{};
    raw.forEach((key, value) {
      map[key as String] =
          (value as List).map((e) => e as String).toList();
    });
    return LocationData(governorates: govs, districtsByGov: map);
  }

  bool get isEmpty => governorates.isEmpty;
}
