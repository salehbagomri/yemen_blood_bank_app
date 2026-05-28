import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/statistics_model.dart';
import 'supabase_service.dart';
import '../utils/error_handler.dart';

/// خدمة الإحصائيات
class StatisticsService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// الحصول على الإحصائيات العامة
  Future<StatisticsModel> getStatistics() async {
    try {
      // استخدام الدالة المخصصة get_statistics
      final response = await _client.rpc('get_statistics').single();

      return StatisticsModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// الحصول على إحصائيات بسيطة (بدون استخدام الدالة)
  Future<StatisticsModel> getSimpleStatistics() async {
    try {
      // إجمالي المتبرعين
      final totalDonorsResponse = await _client
          .from('donors')
          .select('id')
          .eq('is_active', true)
          .count();

      final totalDonors = totalDonorsResponse.count;

      // أكثر فصيلة متوفرة — تجميع خادمي (GROUP BY) بدل جلب كل الصفوف
      final bloodTypeRows = await _client.rpc('get_bloodtype_stats') as List;
      final Map<String, int> bloodTypeCount = {
        for (var row in bloodTypeRows)
          row['blood_type'] as String: (row['cnt'] as num).toInt(),
      };

      String? mostCommonBloodType;
      int mostCommonBloodTypeCount = 0;
      if (bloodTypeCount.isNotEmpty) {
        // الصفوف مرتبة تنازلياً خادمياً، فالأول هو الأكثر
        final maxEntry = bloodTypeCount.entries.first;
        mostCommonBloodType = maxEntry.key;
        mostCommonBloodTypeCount = maxEntry.value;
      }

      // أكثر مديرية نشاطاً — تجميع خادمي (GROUP BY)
      final districtRows = await _client.rpc('get_district_stats') as List;
      final Map<String, int> districtCount = {
        for (var row in districtRows)
          row['district'] as String: (row['cnt'] as num).toInt(),
      };

      String? mostActiveDistrict;
      int mostActiveDistrictCount = 0;
      if (districtCount.isNotEmpty) {
        final maxEntry = districtCount.entries.first;
        mostActiveDistrict = maxEntry.key;
        mostActiveDistrictCount = maxEntry.value;
      }

      // أحدث متبرع
      final latestDonorResponse = await _client
          .from('donors')
          .select('name, created_at')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      String? latestDonorName;
      DateTime? latestDonorDate;
      if (latestDonorResponse != null) {
        latestDonorName = latestDonorResponse['name'] as String;
        latestDonorDate = DateTime.parse(latestDonorResponse['created_at'] as String);
      }

      return StatisticsModel(
        totalDonors: totalDonors,
        mostCommonBloodType: mostCommonBloodType,
        mostCommonBloodTypeCount: mostCommonBloodTypeCount,
        mostActiveDistrict: mostActiveDistrict,
        mostActiveDistrictCount: mostActiveDistrictCount,
        latestDonorName: latestDonorName,
        latestDonorDate: latestDonorDate,
        bloodTypeDistribution: bloodTypeCount,
        districtDistribution: districtCount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }
}

