import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donor_model.dart';
import 'supabase_service.dart';
import '../utils/retry_helper.dart';

/// خدمة إدارة المتبرعين
class DonorService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// البحث عن متبرعين
  ///
  /// [bloodType] - فصيلة الدم المطلوبة
  /// [governorate] - المحافظة المطلوبة (تُرجع كل مديرياتها)
  /// [district] - المديرية المطلوبة (تطابق دقيق اختياري)
  /// [availableOnly] - البحث عن المتبرعين المتاحين فقط
  Future<List<DonorModel>> searchDonors({
    String? bloodType,
    String? governorate,
    String? district,
    bool availableOnly = true,
  }) async {
    return RetryHelper.retryWithTimeout(
      () async {
        try {
          // استخدام الدالة المخصصة search_donors
          final response = await _client
              .rpc(
                'search_donors',
                params: {
                  'p_blood_type': bloodType,
                  'p_district': district,
                  'p_available_only': availableOnly,
                  'p_governorate': governorate,
                },
              )
              .select();

          return (response as List)
              .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw Exception('فشل البحث عن المتبرعين: ${e.toString()}');
        }
      },
      timeout: const Duration(seconds: 30),
      maxRetries: 2,
    );
  }

  /// الحصول على متبرع واحد حسب المعرف
  Future<DonorModel?> getDonorById(String id) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل الحصول على بيانات المتبرع: ${e.toString()}');
    }
  }

  /// إضافة متبرع جديد
  Future<DonorModel> addDonor(DonorModel donor) async {
    try {
      final response = await _client
          .from('donors')
          .insert({
            'name': donor.name,
            'phone_number': donor.phoneNumber,
            'phone_number_2': donor.phoneNumber2,
            'phone_number_3': donor.phoneNumber3,
            'blood_type': donor.bloodType,
            'district': donor.district,
            'governorate': donor.governorate,
            'age': donor.age,
            'gender': donor.gender,
            'notes': donor.notes,
            'added_by': _supabaseService.currentUserId,
          })
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('رقم الهاتف مسجل بالفعل');
      }
      throw Exception('فشل إضافة المتبرع: ${e.toString()}');
    }
  }

  /// تحديث بيانات متبرع
  Future<DonorModel> updateDonor(DonorModel donor) async {
    try {
      final response = await _client
          .from('donors')
          .update({
            'name': donor.name,
            'phone_number': donor.phoneNumber,
            'phone_number_2': donor.phoneNumber2,
            'phone_number_3': donor.phoneNumber3,
            'blood_type': donor.bloodType,
            'district': donor.district,
            'governorate': donor.governorate,
            'age': donor.age,
            'gender': donor.gender,
            'notes': donor.notes,
            'is_available': donor.isAvailable,
            'last_donation_date': donor.lastDonationDate?.toIso8601String(),
            'suspended_until': donor.suspendedUntil?.toIso8601String(),
            'is_active': donor.isActive,
          })
          .eq('id', donor.id)
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث بيانات المتبرع: ${e.toString()}');
    }
  }

  /// البحث عن متبرع برقم الهاتف (يدعم مع/بدون الرمز الدولي + أرقام متعددة)
  /// ملاحظة: إذا وُجد أكثر من متبرع بنفس الرقم، يُرجع الأول (الأحدث)
  Future<DonorModel?> findDonorByPhone(String phoneNumber) async {
    try {
      // تنظيف الرقم
      String cleanPhone = phoneNumber.trim();

      // إزالة المسافات والشرطات
      cleanPhone = cleanPhone.replaceAll(RegExp(r'[\s\-]'), '');

      // إذا كان الرقم يبدأ بـ +967، نحذف الرمز الدولي
      if (cleanPhone.startsWith('+967')) {
        cleanPhone = cleanPhone.substring(4);
      } else if (cleanPhone.startsWith('967')) {
        cleanPhone = cleanPhone.substring(3);
      } else if (cleanPhone.startsWith('00967')) {
        cleanPhone = cleanPhone.substring(5);
      }

      // البحث في جميع الأرقام (الرئيسي والإضافية)
      // استخدام limit(1) بدلاً من maybeSingle() للتعامل مع الأرقام المتكررة
      var response = await _client
          .from('donors')
          .select()
          .or(
            'phone_number.eq.$cleanPhone,'
            'phone_number.eq.+967$cleanPhone,'
            'phone_number_2.eq.$cleanPhone,'
            'phone_number_2.eq.+967$cleanPhone,'
            'phone_number_3.eq.$cleanPhone,'
            'phone_number_3.eq.+967$cleanPhone',
          )
          .order('created_at', ascending: false) // الأحدث أولاً
          .limit(1);

      // إذا لم نجد، نحاول بدون صفر أول
      if (response.isEmpty && cleanPhone.startsWith('0')) {
        final phoneWithoutZero = cleanPhone.substring(1);
        response = await _client
            .from('donors')
            .select()
            .or(
              'phone_number.eq.$phoneWithoutZero,'
              'phone_number.eq.+967$phoneWithoutZero,'
              'phone_number_2.eq.$phoneWithoutZero,'
              'phone_number_2.eq.+967$phoneWithoutZero,'
              'phone_number_3.eq.$phoneWithoutZero,'
              'phone_number_3.eq.+967$phoneWithoutZero',
            )
            .order('created_at', ascending: false)
            .limit(1);
      }

      if (response.isEmpty) {
        return null;
      }

      return DonorModel.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  /// حذف متبرع (الأدمن فقط)
  Future<void> deleteDonor(String id) async {
    try {
      await _client.from('donors').delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف المتبرع: ${e.toString()}');
    }
  }

  /// إيقاف متبرع لمدة 6 أشهر
  Future<DonorModel> suspendDonorFor6Months(String id) async {
    try {
      final suspendedUntil = DateTime.now().add(const Duration(days: 180));

      final response = await _client
          .from('donors')
          .update({
            'suspended_until': suspendedUntil.toIso8601String(),
            'last_donation_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل إيقاف المتبرع: ${e.toString()}');
    }
  }

  /// الحصول على المتبرعين الموقوفين
  Future<List<DonorModel>> getSuspendedDonors() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('donors')
          .select()
          .not('suspended_until', 'is', null)
          .gt('suspended_until', now)
          .order('suspended_until', ascending: true);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المتبرعين الموقوفين: ${e.toString()}');
    }
  }

  /// الحصول على عدد الحسابات المعطلة
  Future<int> getInactiveDonorsCount() async {
    try {
      final response = await _client
          .from('donors')
          .select('id')
          .eq('is_active', false);

      return (response as List).length;
    } catch (e) {
      throw Exception('فشل الحصول على عدد الحسابات المعطلة: ${e.toString()}');
    }
  }

  /// الحصول على جميع المتبرعين (للمستشفى والأدمن)
  Future<List<DonorModel>> getAllDonors({int? limit, int? offset}) async {
    try {
      var query = _client
          .from('donors')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المتبرعين: ${e.toString()}');
    }
  }

  /// الحصول على متبرعي محافظة معينة (لعرض إدارة المستشفى)
  Future<List<DonorModel>> getDonorsByGovernorate(
    String governorate, {
    int? limit,
  }) async {
    try {
      var query = _client
          .from('donors')
          .select()
          .eq('governorate', governorate)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على متبرعي المحافظة: ${e.toString()}');
    }
  }

  /// إحصائيات مجمّعة حسب المحافظة (خادمياً عبر RPC بدل الجلب الكامل)
  /// [governorate] = null → كل المحافظات (للأدمن)؛ محافظة محددة → صف واحد
  /// تُرجع قائمة: {governorate, total, available, suspended}
  Future<List<Map<String, dynamic>>> getGovernorateStats({
    String? governorate,
  }) async {
    try {
      final response = await _client.rpc(
        'get_governorate_stats',
        params: {'p_governorate': governorate},
      );

      return (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على إحصائيات المحافظات: ${e.toString()}');
    }
  }

  /// البحث بالاسم أو رقم الهاتف (يدعم البحث في جميع الأرقام)
  Future<List<DonorModel>> searchByNameOrPhone(String query) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .or(
            'name.ilike.%$query%,'
            'phone_number.ilike.%$query%,'
            'phone_number_2.ilike.%$query%,'
            'phone_number_3.ilike.%$query%',
          )
          .eq('is_active', true)
          .order('name')
          .limit(50);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل البحث: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين حسب فصيلة الدم (تجميع خادمي GROUP BY)
  Future<Map<String, int>> getDonorCountByBloodType() async {
    try {
      final rows = await _client.rpc('get_bloodtype_stats') as List;
      return {
        for (var row in rows)
          row['blood_type'] as String: (row['cnt'] as num).toInt(),
      };
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين حسب المديرية (تجميع خادمي GROUP BY)
  Future<Map<String, int>> getDonorCountByDistrict() async {
    try {
      final rows = await _client.rpc('get_district_stats') as List;
      return {
        for (var row in rows)
          row['district'] as String: (row['cnt'] as num).toInt(),
      };
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين المتاحين للتبرع الآن
  /// المتاحين = is_active = true AND (suspended_until IS NULL OR suspended_until < NOW())
  Future<int> getAvailableDonorsCount() async {
    try {
      final now = DateTime.now().toIso8601String();

      // فلترة على مستوى قاعدة البيانات بدلاً من جلب كل البيانات
      final response = await _client
          .from('donors')
          .select('id')
          .eq('is_active', true)
          .or('suspended_until.is.null,suspended_until.lt.$now');

      return (response as List).length;
    } catch (e) {
      throw Exception('فشل الحصول على عدد المتاحين: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين الجدد هذا الشهر
  /// الشرط: created_at >= بداية الشهر الحالي
  Future<int> getNewDonorsThisMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

      // جلب id فقط بدلاً من كل البيانات
      final response = await _client
          .from('donors')
          .select('id')
          .gte('created_at', startOfMonth);

      return (response as List).length;
    } catch (e) {
      throw Exception('فشل الحصول على عدد المتبرعين الجدد: ${e.toString()}');
    }
  }

  /// الحصول على عدد المناطق المغطاة (distinct districts) عبر التجميع الخادمي
  Future<int> getCoveredDistrictsCount() async {
    try {
      final rows = await _client.rpc('get_district_stats') as List;
      return rows.length;
    } catch (e) {
      throw Exception('فشل الحصول على عدد المناطق: ${e.toString()}');
    }
  }

  /// الحصول على آخر المتبرعين المضافين
  Future<List<DonorModel>> getRecentDonors({int limit = 5}) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المتبرعين الجدد: ${e.toString()}');
    }
  }

  /// الحصول على آخر عمليات التبرع
  /// المتبرعين الذين last_donation_date ليس null، مرتبين حسب last_donation_date DESC
  Future<List<DonorModel>> getRecentDonations({int limit = 5}) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .not('last_donation_date', 'is', null)
          .order('last_donation_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على آخر التبرعات: ${e.toString()}');
    }
  }
}
