import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/banner_model.dart';
import 'supabase_service.dart';
import '../utils/error_handler.dart';

/// خدمة إدارة البانرات الدعائية والإعلانية
class BannerService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// الحصول على البانرات النشطة
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final list = (response as List)
          .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // فلترة البانرات لتضمين البانرات التي تقع ضمن النطاق الزمني الحالي فقط في Dart
      return list.where((banner) => banner.isCurrentlyVisible).toList();
    } catch (e) {
      throw Exception('فشل الحصول على البانرات النشطة: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// الحصول على جميع البانرات للأدمن
  Future<List<BannerModel>> getAllBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على البانرات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// رفع صورة بانر إلى Supabase Storage
  Future<String> uploadBannerImage(String fileName, Uint8List fileBytes) async {
    try {
      final uniqueName = 'banner_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      // رفع الملف إلى bucket البانرات
      await _client.storage.from('banners').uploadBinary(
            uniqueName,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return uniqueName; // نُرجع مسار الملف النسبي داخل الـ bucket
    } catch (e) {
      throw Exception('فشل رفع صورة البانر: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// حذف صورة البانر من Storage
  Future<void> deleteBannerImage(String imagePath) async {
    try {
      await _client.storage.from('banners').remove([imagePath]);
    } catch (e) {
      // نتجاهل الخطأ في الحذف لتجنب تعطيل العملية الرئيسية، ونقوم بتسجيله فقط
      debugPrint('فشل حذف الصورة من التخزين: $imagePath. الخطأ: $e');
    }
  }

  /// إنشاء بانر جديد
  Future<BannerModel> createBanner({
    required String title,
    required String? subtitle,
    required String? imagePath,
    required String actionType,
    required String? actionValue,
    required int sortOrder,
    required bool isActive,
    required String? iconName,
    required String? bgGradient,
    required DateTime? startsAt,
    required DateTime? endsAt,
  }) async {
    try {
      final response = await _client
          .from('banners')
          .insert({
            'title': title,
            'subtitle': subtitle,
            'image_path': imagePath,
            'action_type': actionType,
            'action_value': actionValue,
            'sort_order': sortOrder,
            'is_active': isActive,
            'icon_name': iconName,
            'bg_gradient': bgGradient,
            'starts_at': startsAt?.toIso8601String(),
            'ends_at': endsAt?.toIso8601String(),
          })
          .select()
          .single();

      return BannerModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل إنشاء البانر: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تحديث بيانات بانر موجود
  Future<BannerModel> updateBanner({
    required String id,
    required String title,
    required String? subtitle,
    required String? imagePath,
    required String actionType,
    required String? actionValue,
    required int sortOrder,
    required bool isActive,
    required String? iconName,
    required String? bgGradient,
    required DateTime? startsAt,
    required DateTime? endsAt,
  }) async {
    try {
      final response = await _client
          .from('banners')
          .update({
            'title': title,
            'subtitle': subtitle,
            'image_path': imagePath,
            'action_type': actionType,
            'action_value': actionValue,
            'sort_order': sortOrder,
            'is_active': isActive,
            'icon_name': iconName,
            'bg_gradient': bgGradient,
            'starts_at': startsAt?.toIso8601String(),
            'ends_at': endsAt?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return BannerModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث البانر: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تغيير حالة البانر (نشط/غير نشط)
  Future<BannerModel> toggleBannerStatus(String id, bool isActive) async {
    try {
      final response = await _client
          .from('banners')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return BannerModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل تغيير حالة البانر: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// حذف بانر (يحذفه ويحذف صورته)
  Future<void> deleteBanner(String id, String? imagePath) async {
    try {
      // 1. حذف السجل من قاعدة البيانات أولاً
      await _client.from('banners').delete().eq('id', id);

      // 2. حذف الصورة المصاحبة من التخزين (إن وُجدت)
      if (imagePath != null && imagePath.isNotEmpty) {
        await deleteBannerImage(imagePath);
      }
    } catch (e) {
      throw Exception('فشل حذف البانر: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// إعادة ترتيب البانرات دفعة واحدة (ذرّياً عبر RPC)
  Future<void> reorderBanners(List<String> bannerIds) async {
    try {
      await _client.rpc(
        'reorder_banners',
        params: {'p_ids': bannerIds},
      );
    } catch (e) {
      throw Exception('فشل إعادة ترتيب البانرات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }
}
