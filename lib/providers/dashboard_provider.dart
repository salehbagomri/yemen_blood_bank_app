import 'package:flutter/foundation.dart';
import '../models/dashboard_statistics_model.dart';
import '../models/donor_model.dart';
import '../models/statistics_model.dart';
import '../services/donor_service.dart';
import '../services/statistics_service.dart';
import '../utils/error_handler.dart';
import '../config/service_locator.dart';

/// Provider لإدارة حالة لوحة المستشفى
class DashboardProvider with ChangeNotifier {
  final DonorService _donorService = getIt<DonorService>();
  final StatisticsService _statisticsService = getIt<StatisticsService>();

  DashboardStatisticsModel? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DashboardStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// تحميل بيانات الـ Dashboard.
  /// إذا مُرِّرت [governorate] (حساب مستشفى) تُحسب الإحصائيات لمحافظتها فقط.
  Future<void> loadDashboardData({String? governorate}) async {
    if (governorate != null && governorate.isNotEmpty) {
      await _loadScopedDashboard(governorate);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // تحميل جميع البيانات بالتوازي باستخدام Future.wait
      final results = await Future.wait([
        _statisticsService.getSimpleStatistics(), // 0
        _donorService.getAvailableDonorsCount(), // 1
        _donorService.getSuspendedDonors(), // 2
        _donorService.getNewDonorsThisMonth(), // 3
        _donorService.getCoveredDistrictsCount(), // 4
        _donorService.getRecentDonors(limit: 5), // 5
        _donorService.getRecentDonations(limit: 5), // 6
        _donorService.getInactiveDonorsCount(), // 7
      ]);

      final stats = results[0] as StatisticsModel;
      final recentDonors = results[5] as List<DonorModel>;
      final recentDonations = results[6] as List<DonorModel>;

      _statistics = DashboardStatisticsModel(
        totalDonors: stats.totalDonors,
        availableDonors: results[1] as int,
        suspendedDonors: (results[2] as List).length,
        inactiveDonors: results[7] as int,
        newDonorsThisMonth: results[3] as int,
        mostCommonBloodType: stats.mostCommonBloodType,
        mostCommonBloodTypeCount: stats.mostCommonBloodTypeCount,
        coveredDistrictsCount: results[4] as int,
        bloodTypeDistribution: stats.bloodTypeDistribution,
        districtDistribution: stats.districtDistribution,
        recentDonors: recentDonors,
        recentDonations: recentDonations,
        lastUpdated: DateTime.now(),
      );

      _errorMessage = null;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل إحصائيات محافظة واحدة (لحساب المستشفى) — استعلام واحد + حساب محلي
  Future<void> _loadScopedDashboard(String governorate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final all = await _donorService.getDonorsByGovernorate(governorate);
      final active = all.where((d) => d.isActive).toList();

      final available = active.where((d) => !d.isSuspended).length;
      final suspended = active.where((d) => d.isSuspended).length;
      final inactive = all.length - active.length;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final newThisMonth =
          active.where((d) => !d.createdAt.isBefore(startOfMonth)).length;

      final bloodTypeDistribution = <String, int>{};
      final districtDistribution = <String, int>{};
      for (final d in active) {
        bloodTypeDistribution[d.bloodType] =
            (bloodTypeDistribution[d.bloodType] ?? 0) + 1;
        districtDistribution[d.district] =
            (districtDistribution[d.district] ?? 0) + 1;
      }

      String? mostCommonBloodType;
      int mostCommonBloodTypeCount = 0;
      bloodTypeDistribution.forEach((type, count) {
        if (count > mostCommonBloodTypeCount) {
          mostCommonBloodType = type;
          mostCommonBloodTypeCount = count;
        }
      });

      final recentDonors = [...active]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentDonations =
          active.where((d) => d.lastDonationDate != null).toList()
            ..sort((a, b) =>
                b.lastDonationDate!.compareTo(a.lastDonationDate!));

      _statistics = DashboardStatisticsModel(
        totalDonors: active.length,
        availableDonors: available,
        suspendedDonors: suspended,
        inactiveDonors: inactive,
        newDonorsThisMonth: newThisMonth,
        mostCommonBloodType: mostCommonBloodType,
        mostCommonBloodTypeCount: mostCommonBloodTypeCount,
        coveredDistrictsCount: districtDistribution.length,
        bloodTypeDistribution: bloodTypeDistribution,
        districtDistribution: districtDistribution,
        recentDonors: recentDonors.take(5).toList(),
        recentDonations: recentDonations.take(5).toList(),
        lastUpdated: DateTime.now(),
      );
      _errorMessage = null;
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث البيانات (refresh)
  Future<void> refreshDashboard({String? governorate}) async {
    await loadDashboardData(governorate: governorate);
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
