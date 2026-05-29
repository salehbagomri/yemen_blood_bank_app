import 'package:get_it/get_it.dart';
import '../services/donor_service.dart';
import '../services/export_service.dart';
import '../services/hospital_service.dart';
import '../services/report_service.dart';
import '../services/statistics_service.dart';
import '../services/supabase_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core Services
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
  getIt.registerLazySingleton<CacheService>(() => CacheService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Feature Services
  getIt.registerLazySingleton<DonorService>(() => DonorService());
  getIt.registerLazySingleton<ExportService>(() => ExportService());
  getIt.registerLazySingleton<HospitalService>(() => HospitalService());
  getIt.registerLazySingleton<ReportService>(() => ReportService());
  getIt.registerLazySingleton<StatisticsService>(() => StatisticsService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
}
