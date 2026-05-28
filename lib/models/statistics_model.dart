/// نموذج بيانات الإحصائيات العامة
class StatisticsModel {
  final int totalDonors;
  final String? mostCommonBloodType;
  final int mostCommonBloodTypeCount;
  final String? mostActiveDistrict;
  final int mostActiveDistrictCount;
  final String? latestDonorName;
  final DateTime? latestDonorDate;
  final Map<String, int> bloodTypeDistribution; // توزيع الفصائل
  final Map<String, int> districtDistribution; // توزيع المديريات
  final DateTime lastUpdated;

  StatisticsModel({
    required this.totalDonors,
    this.mostCommonBloodType,
    this.mostCommonBloodTypeCount = 0,
    this.mostActiveDistrict,
    this.mostActiveDistrictCount = 0,
    this.latestDonorName,
    this.latestDonorDate,
    this.bloodTypeDistribution = const {},
    this.districtDistribution = const {},
    required this.lastUpdated,
  });

  /// توزيع المتبرعين مجمَّعاً حسب المحافظة (يطوي مفاتيح "المحافظة - المديرية")
  /// أوضح من عرض 224 مديرية في النظرة الوطنية.
  Map<String, int> get governorateDistribution {
    final result = <String, int>{};
    districtDistribution.forEach((key, count) {
      final gov = key.split(' - ').first;
      result[gov] = (result[gov] ?? 0) + count;
    });
    return result;
  }

  /// تحويل من JSON إلى Model
  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalDonors: json['total_donors'] as int,
      mostCommonBloodType: json['most_common_blood_type'] as String?,
      mostCommonBloodTypeCount: json['most_common_blood_type_count'] as int? ?? 0,
      mostActiveDistrict: json['most_active_district'] as String?,
      mostActiveDistrictCount: json['most_active_district_count'] as int? ?? 0,
      latestDonorName: json['latest_donor_name'] as String?,
      latestDonorDate: json['latest_donor_date'] != null
          ? DateTime.parse(json['latest_donor_date'] as String)
          : null,
      bloodTypeDistribution: json['blood_type_distribution'] != null
          ? Map<String, int>.from(json['blood_type_distribution'] as Map)
          : {},
      districtDistribution: json['district_distribution'] != null
          ? Map<String, int>.from(json['district_distribution'] as Map)
          : {},
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'total_donors': totalDonors,
      'most_common_blood_type': mostCommonBloodType,
      'most_common_blood_type_count': mostCommonBloodTypeCount,
      'most_active_district': mostActiveDistrict,
      'most_active_district_count': mostActiveDistrictCount,
      'latest_donor_name': latestDonorName,
      'latest_donor_date': latestDonorDate?.toIso8601String(),
      'blood_type_distribution': bloodTypeDistribution,
      'district_distribution': districtDistribution,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// نسخ مع تعديل بعض الحقول
  StatisticsModel copyWith({
    int? totalDonors,
    String? mostCommonBloodType,
    int? mostCommonBloodTypeCount,
    String? mostActiveDistrict,
    int? mostActiveDistrictCount,
    String? latestDonorName,
    DateTime? latestDonorDate,
    Map<String, int>? bloodTypeDistribution,
    Map<String, int>? districtDistribution,
    DateTime? lastUpdated,
  }) {
    return StatisticsModel(
      totalDonors: totalDonors ?? this.totalDonors,
      mostCommonBloodType: mostCommonBloodType ?? this.mostCommonBloodType,
      mostCommonBloodTypeCount: mostCommonBloodTypeCount ?? this.mostCommonBloodTypeCount,
      mostActiveDistrict: mostActiveDistrict ?? this.mostActiveDistrict,
      mostActiveDistrictCount: mostActiveDistrictCount ?? this.mostActiveDistrictCount,
      latestDonorName: latestDonorName ?? this.latestDonorName,
      latestDonorDate: latestDonorDate ?? this.latestDonorDate,
      bloodTypeDistribution: bloodTypeDistribution ?? this.bloodTypeDistribution,
      districtDistribution: districtDistribution ?? this.districtDistribution,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

