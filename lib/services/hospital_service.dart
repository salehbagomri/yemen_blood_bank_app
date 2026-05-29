import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hospital_model.dart';
import 'supabase_service.dart';
import '../utils/error_handler.dart';

/// خدمة إدارة المستشفيات (للأدمن فقط)
class HospitalService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// الحصول على جميع المستشفيات
  Future<List<HospitalModel>> getAllHospitals() async {
    try {
      final response = await _client
          .from('hospitals')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HospitalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المستشفيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// الحصول على مستشفى واحد
  Future<HospitalModel?> getHospitalById(String id) async {
    try {
      final response = await _client
          .from('hospitals')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return HospitalModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل الحصول على بيانات المستشفى: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تحديث بيانات مستشفى
  Future<HospitalModel> updateHospital(HospitalModel hospital) async {
    try {
      final response = await _client
          .from('hospitals')
          .update({
            'name': hospital.name,
            'email': hospital.email,
            'district': hospital.district,
            'governorate': hospital.governorate,
            'phone_number': hospital.phoneNumber,
            'address': hospital.address,
          })
          .eq('id', hospital.id)
          .select()
          .single();

      return HospitalModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث بيانات المستشفى: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تعطيل/تفعيل مستشفى
  /// TODO: عمود is_active غير موجود حالياً في جدول hospitals في Supabase
  /// يجب إضافته أولاً قبل تفعيل هذه الدالة
  Future<HospitalModel> toggleHospitalStatus(String id, bool isActive) async {
    throw Exception('خاصية تعطيل/تفعيل المستشفى غير متاحة حالياً');
  }

  /// حذف مستشفى (يحذف من Auth أيضاً)
  Future<void> deleteHospital(String id) async {
    try {
      // حذف من جدول hospitals
      await _client
          .from('hospitals')
          .delete()
          .eq('id', id);
      
      // ملاحظة: حذف المستخدم من Auth يجب أن يتم من Dashboard
      // أو باستخدام Service Role Key (غير آمن في التطبيق)
    } catch (e) {
      throw Exception('فشل حذف المستشفى: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// البحث عن مستشفيات
  Future<List<HospitalModel>> searchHospitals(String query) async {
    try {
      final response = await _client
          .from('hospitals')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%,district.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HospitalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل البحث عن المستشفيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// الحصول على عدد المستشفيات
  Future<int> getHospitalsCount() async {
    try {
      final response = await _client
          .from('hospitals')
          .select('id')
          .count();

      return response.count;
    } catch (e) {
      throw Exception('فشل الحصول على عدد المستشفيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// الحصول على المستشفيات النشطة فقط
  /// ملاحظة: عمود is_active غير موجود في جدول hospitals حالياً
  /// لذا نُرجع جميع المستشفيات مرتبة بالاسم
  Future<List<HospitalModel>> getActiveHospitals() async {
    try {
      final response = await _client
          .from('hospitals')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => HospitalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المستشفيات النشطة: ${ErrorHandler.getArabicMessage(e)}');
    }
  }
}

