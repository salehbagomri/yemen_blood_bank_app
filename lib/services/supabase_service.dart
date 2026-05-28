import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة Supabase الرئيسية
/// 
/// ملاحظة: يجب تهيئة Supabase في main.dart قبل استخدام هذه الخدمة
class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// الحصول على client من Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// التحقق من حالة الاتصال
  bool get isConnected => client.auth.currentSession != null;

  /// الحصول على المستخدم الحالي
  User? get currentUser => client.auth.currentUser;

  /// الحصول على معرف المستخدم الحالي
  String? get currentUserId => currentUser?.id;

  /// التحقق من تسجيل الدخول
  bool get isLoggedIn => currentUser != null;

  /// تهيئة Supabase
  /// يجب استدعاء هذه الدالة في main.dart
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// التحقق من نوع المستخدم (مستشفى أو أدمن)
  Future<String?> getUserType() async {
    if (!isLoggedIn) return null;

    try {
      // استخدام الدوال المساعدة بدلاً من الاستعلام المباشر
      // لتجنب مشاكل RLS recursion
      
      // التحقق من admin
      final isAdminResult = await client.rpc('is_admin');
      if (isAdminResult == true) {
        return 'admin';
      }

      // التحقق من hospital
      final isHospitalResult = await client.rpc('is_hospital');
      if (isHospitalResult == true) {
        return 'hospital';
      }

      return null;
    } catch (e) {
      // في حالة فشل الدوال، نحاول الطريقة القديمة
      // (قد يكون المستخدم لم ينفذ fix_rls_policies.sql بعد)
      try {
        final adminResponse = await client
            .from('admins')
            .select('id')
            .eq('id', currentUserId!)
            .limit(1)
            .maybeSingle();

        if (adminResponse != null) {
          return 'admin';
        }

        final hospitalResponse = await client
            .from('hospitals')
            .select('id')
            .eq('id', currentUserId!)
            .limit(1)
            .maybeSingle();

        if (hospitalResponse != null) {
          return 'hospital';
        }
      } catch (fallbackError) {
        debugPrint('Error getting user type (fallback): $fallbackError');
      }
      
      return null;
    }
  }

  /// محافظة حساب المستشفى الحالي (للتقييد الجغرافي على مستوى التطبيق)
  /// دفاعي: يعتمد عمود governorate، وإن كان فارغاً يشتقه من district.
  Future<String?> getCurrentHospitalGovernorate() async {
    if (!isLoggedIn) return null;
    try {
      final res = await client
          .from('hospitals')
          .select('governorate, district')
          .eq('id', currentUserId!)
          .maybeSingle();
      if (res == null) return null;
      final gov = res['governorate'] as String?;
      if (gov != null && gov.isNotEmpty) return gov;
      final district = res['district'] as String?;
      if (district != null && district.isNotEmpty) {
        return district.split(' - ').first;
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في تحميل محافظة المستشفى: $e');
      return null;
    }
  }

  /// الاستماع لتغييرات حالة المصادقة
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

