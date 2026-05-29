import 'package:flutter/foundation.dart';
import '../constants/app_strings.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../config/service_locator.dart';

/// Provider للمناطق المفعّلة (المحافظات/المديريات) — Cache First مع احتياطي offline
class LocationProvider with ChangeNotifier {
  final LocationService _service = getIt<LocationService>();
  final CacheService _cacheService = getIt<CacheService>();
  final ConnectivityService _connectivityService =
      getIt<ConnectivityService>();

  LocationData? _data;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// المحافظات المفعّلة — احتياطي: قائمة AppStrings الكاملة إن لا بيانات/لا كاش
  List<String> get activeGovernorates =>
      _data?.governorates ?? AppStrings.districts;

  /// مديريات محافظة معيّنة — احتياطي: خريطة AppStrings
  List<String> districtsOf(String? governorate) {
    if (governorate == null || governorate.isEmpty) return const [];
    final map = _data?.districtsByGov ?? AppStrings.governorateDistricts;
    return map[governorate] ?? const [];
  }

  /// تحميل المناطق المفعّلة (Cache First, Network Second)
  Future<void> load({bool forceRefresh = false}) async {
    if (_data != null && !forceRefresh) return;

    // عرض الكاش فوراً إن وُجد
    final cached = _cacheService.getCachedLocations();
    if (cached != null) {
      _data = cached;
      notifyListeners();
    }

    if (!_connectivityService.isConnected) return;

    _isLoading = true;
    try {
      final fresh = await _service.getActiveLocations();
      _data = fresh;
      await _cacheService.saveLocations(fresh);
    } catch (e) {
      debugPrint('⚠️ LocationProvider: تعذّر تحميل المناطق — $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إعادة التحميل بعد تعديل الأدمن
  Future<void> refresh() => load(forceRefresh: true);
}
