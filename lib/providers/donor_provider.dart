import 'package:flutter/foundation.dart';
import '../models/donor_model.dart';
import '../services/donor_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../utils/error_handler.dart';
import '../config/service_locator.dart';

/// Provider لإدارة حالة المتبرعين مع دعم Offline Mode
class DonorProvider with ChangeNotifier {
  final DonorService _donorService = getIt<DonorService>();
  final CacheService _cacheService = getIt<CacheService>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  List<DonorModel> _donors = [];
  List<DonorModel> _searchResults = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;

  DateTime? _lastFetchTime;
  final Duration _memCacheDuration = const Duration(minutes: 5);

  // Getters
  List<DonorModel> get donors => _donors;
  List<DonorModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// البحث عن متبرعين (مع كاش البحث)
  Future<void> searchDonors({
    String? bloodType,
    String? governorate,
    String? district,
    bool availableOnly = true,
  }) async {
    // مفتاح الكاش المستند إلى معاملات البحث
    final cacheKey =
        'search_${bloodType ?? 'all'}_${governorate ?? 'all'}_${district ?? 'all'}_$availableOnly';

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // إذا لا يوجد اتصال، نستخدم الكاش المحلي
    if (!_connectivityService.isConnected) {
      _isOffline = true;
      final cached = _cacheService.getCachedSearchResults(cacheKey);
      if (cached != null) {
        _searchResults = cached;
        _isLoading = false;
        notifyListeners();
        return;
      }
      // لا يوجد كاش → نفلتر محلياً من قائمة المتبرعين المحفوظة
      _searchResults = _filterLocalDonors(
        bloodType: bloodType,
        governorate: governorate,
        district: district,
        availableOnly: availableOnly,
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isOffline = false;
    try {
      _searchResults = await _donorService.searchDonors(
        bloodType: bloodType,
        governorate: governorate,
        district: district,
        availableOnly: availableOnly,
      );
      // حفظ نتيجة البحث في الكاش
      await _cacheService.saveSearchResults(cacheKey, _searchResults);
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      // في حالة الفشل، نحاول الكاش
      final cached = _cacheService.getCachedSearchResults(cacheKey);
      if (cached != null) {
        _searchResults = cached;
        _errorMessage = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تصفية محلية من الـ cache
  List<DonorModel> _filterLocalDonors({
    String? bloodType,
    String? governorate,
    String? district,
    bool availableOnly = true,
  }) {
    var list = _donors.where((d) => d.isActive).toList();
    if (availableOnly) list = list.where((d) => !d.isSuspended).toList();
    if (bloodType != null) {
      list = list.where((d) => d.bloodType == bloodType).toList();
    }
    if (governorate != null) {
      list = list.where((d) => d.governorate == governorate).toList();
    }
    if (district != null) {
      // مطابقة المحافظة الكاملة (district == "محافظة") أو مديرية محددة ("محافظة - مديرية")
      list = list
          .where((d) =>
              d.district == district || d.district.startsWith('$district - '))
          .toList();
    }
    return list;
  }

  /// إضافة متبرع جديد
  Future<bool> addDonor(DonorModel donor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newDonor = await _donorService.addDonor(donor);
      _donors.insert(0, newDonor);
      // تحديث الكاش بعد الإضافة
      await _cacheService.saveDonors(_donors);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث بيانات متبرع
  Future<bool> updateDonor(DonorModel donor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedDonor = await _donorService.updateDonor(donor);

      // تحديث في القائمة الرئيسية
      final index = _donors.indexWhere((d) => d.id == updatedDonor.id);
      if (index != -1) {
        _donors[index] = updatedDonor;
      }

      // تحديث في نتائج البحث
      final searchIndex = _searchResults.indexWhere(
        (d) => d.id == updatedDonor.id,
      );
      if (searchIndex != -1) {
        _searchResults[searchIndex] = updatedDonor;
      }

      // تحديث الكاش
      await _cacheService.saveDonors(_donors);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف متبرع
  Future<bool> deleteDonor(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _donorService.deleteDonor(id);
      _donors.removeWhere((d) => d.id == id);
      _searchResults.removeWhere((d) => d.id == id);
      // تحديث الكاش
      await _cacheService.saveDonors(_donors);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إيقاف متبرع لمدة 6 أشهر
  Future<bool> suspendDonorFor6Months(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedDonor = await _donorService.suspendDonorFor6Months(id);

      final index = _donors.indexWhere((d) => d.id == updatedDonor.id);
      if (index != -1) {
        _donors[index] = updatedDonor;
      }
      await _cacheService.saveDonors(_donors);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// الحصول على جميع المتبرعين - Cache First, Network Second
  Future<void> loadDonors({bool forceRefresh = false}) async {
    // 1) إذا في الذاكرة وحديث → استخدمه مباشرة
    if (!forceRefresh && _donors.isNotEmpty && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _memCacheDuration) {
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 2) إذا لا يوجد اتصال → استخدم Hive cache
    if (!_connectivityService.isConnected) {
      _isOffline = true;
      final cached = _cacheService.getCachedDonors();
      if (cached != null && cached.isNotEmpty) {
        _donors = cached;
        _isLoading = false;
        notifyListeners();
        return;
      }
      // لا يوجد كاش أصلاً
      _errorMessage = 'لا يوجد اتصال بالإنترنت ولا يوجد بيانات محفوظة';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isOffline = false;

    // 3) عرض Hive cache فوراً أثناء الاستعلام من الشبكة
    if (!forceRefresh && _donors.isEmpty) {
      final cached = _cacheService.getCachedDonors();
      if (cached != null && cached.isNotEmpty) {
        _donors = cached;
        notifyListeners(); // عرض بيانات قديمة فوراً
      }
    }

    try {
      // 4) جلب من الشبكة
      _donors = await _donorService.getAllDonors();
      _lastFetchTime = DateTime.now();
      // 5) حفظ في Hive
      await _cacheService.saveDonors(_donors);
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
      // عند الفشل استخدم ما عندنا (من الخطوة 3)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// الحصول على جميع المتبرعين (بدون تحديث الحالة - للتصدير)
  Future<List<DonorModel>> loadAllDonors() async {
    try {
      return await _donorService.getAllDonors();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      throw Exception(ErrorHandler.getArabicMessage(e));
    }
  }

  /// البحث بالاسم أو رقم الهاتف
  Future<void> searchByNameOrPhone(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // إذا لا يوجد اتصال → بحث محلي
    if (!_connectivityService.isConnected) {
      _isOffline = true;
      final lq = query.toLowerCase();
      _searchResults = _donors
          .where(
            (d) =>
                d.isActive &&
                (d.name.toLowerCase().contains(lq) ||
                    d.phoneNumber.contains(query) ||
                    (d.phoneNumber2?.contains(query) ?? false) ||
                    (d.phoneNumber3?.contains(query) ?? false)),
          )
          .toList();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isOffline = false;
    try {
      _searchResults = await _donorService.searchByNameOrPhone(query);
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مسح نتائج البحث
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
