import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../config/service_locator.dart';
import '../utils/error_handler.dart';

/// Provider لإدارة حالة البانرات والتشغيل المتصل/غير المتصل (Cache First)
class BannerProvider with ChangeNotifier {
  final BannerService _service = getIt<BannerService>();
  final CacheService _cacheService = getIt<CacheService>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  List<BannerModel> _activeBanners = [];
  List<BannerModel> _allBanners = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<BannerModel> get activeBanners => _activeBanners;
  List<BannerModel> get allBanners => _allBanners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// تحميل البانرات النشطة (الصفحة الرئيسية) - Cache First
  Future<void> loadActiveBanners({bool forceRefresh = false}) async {
    // 1. استخدام الكاش الميموري إذا كان متاحاً وموثوقاً ولم يطلب تحديث إجباري
    if (!forceRefresh && _activeBanners.isNotEmpty) {
      if (_cacheService.isBannersCacheFresh()) {
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 2. استخدام كاش Hive إذا كان غير متصل بالإنترنت
    if (!_connectivityService.isConnected) {
      final cached = _cacheService.getCachedBanners();
      if (cached != null) {
        _activeBanners = cached;
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 3. عرض الكاش فوراً قبل جلب البيانات من الشبكة لتفادي الوميض
    final cached = _cacheService.getCachedBanners();
    if (cached != null && _activeBanners.isEmpty) {
      _activeBanners = cached;
      notifyListeners();
    }

    try {
      // 4. الجلب من الخادم
      final fresh = await _service.getActiveBanners();
      _activeBanners = fresh;
      
      // 5. الحفظ في الكاش المحلي
      await _cacheService.saveBanners(fresh);
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      debugPrint('❌ BannerProvider: فشل جلب البانرات النشطة: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب جميع البانرات للأدمن (لوحة التحكم)
  Future<void> loadAllBanners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allBanners = await _service.getAllBanners();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      debugPrint('❌ BannerProvider: فشل جلب جميع البانرات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// رفع صورة بانر إلى التخزين
  Future<String> uploadBannerImage(String fileName, Uint8List fileBytes) async {
    return await _service.uploadBannerImage(fileName, fileBytes);
  }

  /// إضافة بانر جديد (للأدمن)
  Future<void> addBanner({
    required String title,
    required String? subtitle,
    required String imagePath,
    required String actionType,
    required String? actionValue,
    required int sortOrder,
    required bool isActive,
    required DateTime? startsAt,
    required DateTime? endsAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBanner = await _service.createBanner(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startsAt: startsAt,
        endsAt: endsAt,
      );

      _allBanners.add(newBanner);
      _allBanners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      // تحديث البانرات النشطة محلياً وإلغاء صلاحية الكاش
      await refreshActiveBannersSilently();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تعديل بيانات بانر (للأدمن)
  Future<void> updateBanner({
    required String id,
    required String title,
    required String? subtitle,
    required String imagePath,
    required String actionType,
    required String? actionValue,
    required int sortOrder,
    required bool isActive,
    required DateTime? startsAt,
    required DateTime? endsAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateBanner(
        id: id,
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        actionType: actionType,
        actionValue: actionValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startsAt: startsAt,
        endsAt: endsAt,
      );

      final index = _allBanners.indexWhere((b) => b.id == id);
      if (index != -index) {
        _allBanners[index] = updated;
        _allBanners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }

      await refreshActiveBannersSilently();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تفعيل/تعطيل حالة البانر (للأدمن)
  Future<void> toggleBannerStatus(String id, bool isActive) async {
    try {
      final updated = await _service.toggleBannerStatus(id, isActive);
      
      final index = _allBanners.indexWhere((b) => b.id == id);
      if (index != -1) {
        _allBanners[index] = updated;
      }
      
      await refreshActiveBannersSilently();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  /// حذف بانر بالكامل مع صورته (للأدمن)
  Future<void> deleteBanner(String id, String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteBanner(id, imagePath);
      _allBanners.removeWhere((b) => b.id == id);
      
      await refreshActiveBannersSilently();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إعادة ترتيب البانرات للأدمن
  Future<void> reorderBanners(List<String> bannerIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.reorderBanners(bannerIds);
      
      // تحديث الترتيب محلياً لتسريع الاستجابة بصرياً
      final tempBanners = <BannerModel>[];
      for (final id in bannerIds) {
        final banner = _allBanners.firstWhere((b) => b.id == id);
        tempBanners.add(banner.copyWith(sortOrder: tempBanners.length));
      }
      _allBanners = tempBanners;

      await refreshActiveBannersSilently();
    } catch (e) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث البانرات النشطة بالخلفية
  Future<void> refreshActiveBannersSilently() async {
    if (!_connectivityService.isConnected) return;
    try {
      final fresh = await _service.getActiveBanners();
      _activeBanners = fresh;
      await _cacheService.saveBanners(fresh);
    } catch (e) {
      debugPrint('⚠️ BannerProvider: فشل تحديث البانرات النشطة بصمت: $e');
    }
  }

  /// تفريغ الأخطاء
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
