import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'config/supabase_config.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/dashboard_provider.dart';
import 'utils/firebase_error_logger.dart';
import 'config/app_router.dart';
import 'config/service_locator.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Services (Dependency Injection)
  setupServiceLocator();

  // تهيئة Hive للتخزين المحلي (Offline Mode)
  await CacheService.initialize();

  // بدء مراقبة الاتصال بالإنترنت (بدون blocking)
  try {
    await getIt<ConnectivityService>().initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('⚠️ ConnectivityService: timeout — سيُستكمل لاحقاً');
      },
    );
  } catch (e) {
    debugPrint('⚠️ ConnectivityService: فشل التهيئة — $e');
  }

  // تهيئة Firebase (ستحتاج لإضافة google-services.json/GoogleService-Info.plist)
  try {
    await Firebase.initializeApp();
    await FirebaseErrorLogger.initialize();
    debugPrint('✅ تم تهيئة Firebase Crashlytics بنجاح');
  } catch (e) {
    debugPrint('⚠️ تحذير: لم يتم تهيئة Firebase - سيعمل التطبيق بدونه');
    debugPrint(
      'لتفعيل Crashlytics، أضف google-services.json للـ Android و GoogleService-Info.plist للـ iOS',
    );
  }

  // تثبيت اتجاه الشاشة (عمودي فقط)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Supabase
  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize(
      url: SupabaseConfig.activeSupabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } else {
    debugPrint('⚠️ تحذير: لم يتم تكوين Supabase بعد!');
    debugPrint('يرجى تحديث lib/config/supabase_config.dart بمفاتيح مشروعك');
  }

  runApp(const YemenBloodBankApp());
}

class YemenBloodBankApp extends StatelessWidget {
  const YemenBloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DonorProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // السمة
        theme: AppTheme.lightTheme,

        // اللغة والاتجاه
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],

        // Localization delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // اتجاه النص (من اليمين لليسار)
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },

        // تحديد المولد المركزي للمسارات
        onGenerateRoute: AppRouter.generateRoute,

        // المسار الافتراضي (Splash)
        initialRoute: '/splash',
      ),
    );
  }
}

/// شاشة البداية (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // انتظار قليلاً لعرض شاشة البداية
    await Future.delayed(const Duration(seconds: 2));

    // التحقق من تكوين Supabase
    if (!SupabaseConfig.isConfigured) {
      if (mounted) {
        _showConfigurationError();
      }
      return;
    }

    // الانتقال إلى الصفحة الرئيسية
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  void _showConfigurationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في الإعدادات'),
        content: const Text(
          'لم يتم تكوين Supabase بعد!\n\n'
          'يرجى تحديث ملف:\n'
          'lib/config/supabase_config.dart\n\n'
          'بمفاتيح مشروعك من Supabase Dashboard',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التطبيق
              SvgPicture.asset(
                'assets/icons/logo-m.svg',
                width: 150,
                height: 150,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),

              const SizedBox(height: 30),

              // اسم التطبيق
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                AppStrings.appNameEnglish,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 50),

              // مؤشر التحميل
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
