import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import 'supabase_service.dart';

/// خدمة إدارة المناطق (المحافظات والمديريات) من قاعدة البيانات
class LocationService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// المناطق المفعّلة فقط (للقوائم المنسدلة العامة)
  Future<LocationData> getActiveLocations() async {
    final govs = await _client
        .from('governorates')
        .select('name')
        .eq('is_active', true)
        .order('sort_order');

    final dists = await _client
        .from('districts')
        .select('governorate, name')
        .eq('is_active', true)
        .order('name');

    final govNames =
        (govs as List).map((e) => e['name'] as String).toList();

    final map = <String, List<String>>{};
    for (final d in dists as List) {
      final g = d['governorate'] as String;
      final n = d['name'] as String;
      (map[g] ??= []).add(n);
    }

    return LocationData(governorates: govNames, districtsByGov: map);
  }

  /// كل المحافظات (مفعّلة وموقوفة) — للوحة الأدمن
  Future<List<GovernorateModel>> getAllGovernorates() async {
    final res = await _client
        .from('governorates')
        .select()
        .order('sort_order');
    return (res as List)
        .map((e) => GovernorateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// كل مديريات محافظة (مفعّلة وموقوفة) — للوحة الأدمن
  Future<List<DistrictModel>> getDistrictsOf(String governorate) async {
    final res = await _client
        .from('districts')
        .select()
        .eq('governorate', governorate)
        .order('name');
    return (res as List)
        .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// تفعيل/إيقاف محافظة
  Future<void> setGovernorateActive(String name, bool isActive) async {
    await _client
        .from('governorates')
        .update({'is_active': isActive})
        .eq('name', name);
  }

  /// تفعيل/إيقاف مديرية
  Future<void> setDistrictActive(String id, bool isActive) async {
    await _client
        .from('districts')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  /// إضافة مديرية جديدة
  Future<DistrictModel> addDistrict(String governorate, String name) async {
    try {
      final res = await _client
          .from('districts')
          .insert({'governorate': governorate, 'name': name})
          .select()
          .single();
      return DistrictModel.fromJson(res);
    } catch (e) {
      if (e.toString().contains('duplicate') ||
          e.toString().contains('23505')) {
        throw Exception('هذه المديرية موجودة بالفعل في $governorate');
      }
      throw Exception('فشل إضافة المديرية: ${e.toString()}');
    }
  }

  /// هل توجد سجلات متبرعين في هذه المديرية؟
  Future<bool> isDistrictInUse(String governorate, String name) async {
    final res = await _client.rpc(
      'district_in_use',
      params: {'p_governorate': governorate, 'p_name': name},
    );
    return res == true;
  }

  /// تعديل اسم مديرية — مرفوض إن كانت مستخدمة (يكسر حقل donors.district)
  Future<void> updateDistrict(
    String id,
    String governorate,
    String oldName,
    String newName,
  ) async {
    if (await isDistrictInUse(governorate, oldName)) {
      throw Exception('لا يمكن تعديل المديرية: توجد سجلات متبرعين مرتبطة بها');
    }
    await _client
        .from('districts')
        .update({'name': newName})
        .eq('id', id);
  }

  /// حذف مديرية — مرفوض إن كانت مستخدمة
  Future<void> deleteDistrict(
    String id,
    String governorate,
    String name,
  ) async {
    if (await isDistrictInUse(governorate, name)) {
      throw Exception('لا يمكن حذف المديرية: توجد سجلات متبرعين مرتبطة بها');
    }
    await _client.from('districts').delete().eq('id', id);
  }
}
