import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/donor_model.dart';
import '../models/statistics_model.dart';
import '../models/location_model.dart';

/// خدمة التخزين المحلي باستخدام Hive
/// استراتيجية: Cache First, Network Second
class CacheService {
  static const String _donorsBoxName = 'donors_cache';
  static const String _statsBoxName = 'statistics_cache';
  static const String _searchBoxName = 'search_cache';
  static const String _locationsBoxName = 'locations_cache';

  static const String _locationsKey = 'active_locations';

  static const String _donorsKey = 'all_donors';
  static const String _donorsTimestampKey = 'donors_timestamp';
  static const String _statsKey = 'statistics';
  static const String _statsTimestampKey = 'stats_timestamp';

  /// تهيئة Hive (تُستدعى من main.dart)
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_donorsBoxName);
    await Hive.openBox<String>(_statsBoxName);
    await Hive.openBox<String>(_searchBoxName);
    await Hive.openBox<String>(_locationsBoxName);
    debugPrint('✅ CacheService: Hive initialized');
  }

  // ==================== Donors Cache ====================

  /// حفظ قائمة المتبرعين محلياً
  Future<void> saveDonors(List<DonorModel> donors) async {
    try {
      final box = Hive.box<String>(_donorsBoxName);
      final jsonList = donors.map((d) => jsonEncode(d.toJson())).toList();
      await box.put(_donorsKey, jsonEncode(jsonList));
      await box.put(_donorsTimestampKey, DateTime.now().toIso8601String());
      debugPrint('💾 CacheService: Saved ${donors.length} donors');
    } catch (e) {
      debugPrint('❌ CacheService: Error saving donors: $e');
    }
  }

  /// جلب قائمة المتبرعين من الكاش
  List<DonorModel>? getCachedDonors() {
    try {
      final box = Hive.box<String>(_donorsBoxName);
      final jsonString = box.get(_donorsKey);
      if (jsonString == null) return null;

      final jsonList = (jsonDecode(jsonString) as List)
          .map((e) => e as String)
          .toList();

      return jsonList
          .map(
            (s) => DonorModel.fromJson(jsonDecode(s) as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ CacheService: Error reading donors: $e');
      return null;
    }
  }

  /// هل بيانات المتبرعين حديثة؟ (أقل من X دقيقة)
  bool isDonorsCacheFresh({Duration maxAge = const Duration(minutes: 15)}) {
    try {
      final box = Hive.box<String>(_donorsBoxName);
      final timestampStr = box.get(_donorsTimestampKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      return DateTime.now().difference(timestamp) < maxAge;
    } catch (e) {
      return false;
    }
  }

  // ==================== Statistics Cache ====================

  /// حفظ الإحصائيات محلياً
  Future<void> saveStatistics(StatisticsModel stats) async {
    try {
      final box = Hive.box<String>(_statsBoxName);
      await box.put(_statsKey, jsonEncode(stats.toJson()));
      await box.put(_statsTimestampKey, DateTime.now().toIso8601String());
      debugPrint('💾 CacheService: Statistics saved');
    } catch (e) {
      debugPrint('❌ CacheService: Error saving statistics: $e');
    }
  }

  /// جلب الإحصائيات من الكاش
  StatisticsModel? getCachedStatistics() {
    try {
      final box = Hive.box<String>(_statsBoxName);
      final jsonString = box.get(_statsKey);
      if (jsonString == null) return null;

      return StatisticsModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('❌ CacheService: Error reading statistics: $e');
      return null;
    }
  }

  /// هل الإحصائيات حديثة؟
  bool isStatisticsCacheFresh({Duration maxAge = const Duration(minutes: 30)}) {
    try {
      final box = Hive.box<String>(_statsBoxName);
      final timestampStr = box.get(_statsTimestampKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      return DateTime.now().difference(timestamp) < maxAge;
    } catch (e) {
      return false;
    }
  }

  // ==================== Search Cache ====================

  /// حفظ نتيجة بحث
  Future<void> saveSearchResults(
    String searchKey,
    List<DonorModel> results,
  ) async {
    try {
      final box = Hive.box<String>(_searchBoxName);
      final jsonList = results.map((d) => jsonEncode(d.toJson())).toList();
      final entry = jsonEncode({
        'results': jsonList,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await box.put(searchKey, entry);
    } catch (e) {
      debugPrint('❌ CacheService: Error saving search results: $e');
    }
  }

  /// جلب نتيجة بحث محفوظة (صالحة لمدة 5 دقائق فقط)
  List<DonorModel>? getCachedSearchResults(String searchKey) {
    try {
      final box = Hive.box<String>(_searchBoxName);
      final jsonString = box.get(searchKey);
      if (jsonString == null) return null;

      final entry = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(entry['timestamp'] as String);

      // نتائج البحث صالحة 5 دقائق فقط
      if (DateTime.now().difference(timestamp) > const Duration(minutes: 5)) {
        return null;
      }

      final jsonList = (entry['results'] as List)
          .map((e) => e as String)
          .toList();
      return jsonList
          .map(
            (s) => DonorModel.fromJson(jsonDecode(s) as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ CacheService: Error reading search results: $e');
      return null;
    }
  }

  // ==================== Locations Cache ====================

  /// حفظ المناطق المفعّلة محلياً
  Future<void> saveLocations(LocationData data) async {
    try {
      final box = Hive.box<String>(_locationsBoxName);
      await box.put(_locationsKey, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('❌ CacheService: Error saving locations: $e');
    }
  }

  /// جلب المناطق المفعّلة من الكاش
  LocationData? getCachedLocations() {
    try {
      final box = Hive.box<String>(_locationsBoxName);
      final jsonString = box.get(_locationsKey);
      if (jsonString == null) return null;
      return LocationData.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('❌ CacheService: Error reading locations: $e');
      return null;
    }
  }

  // ==================== General ====================

  /// مسح كل الكاش
  Future<void> clearAll() async {
    try {
      await Hive.box<String>(_donorsBoxName).clear();
      await Hive.box<String>(_statsBoxName).clear();
      await Hive.box<String>(_searchBoxName).clear();
      debugPrint('🗑️ CacheService: All cache cleared');
    } catch (e) {
      debugPrint('❌ CacheService: Error clearing cache: $e');
    }
  }

  /// مسح كاش المتبرعين فقط
  Future<void> clearDonorsCache() async {
    try {
      await Hive.box<String>(_donorsBoxName).clear();
    } catch (e) {
      debugPrint('❌ CacheService: Error clearing donors cache: $e');
    }
  }
}
