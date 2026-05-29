import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/statistics_provider.dart';
import '../../config/app_router.dart';
import '../../config/service_locator.dart';
import '../../services/connectivity_service.dart';
import '../../services/update_service.dart';
import 'package:share_plus/share_plus.dart';

/// الصفحة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSlideIndex = 0;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    // 🔄 التحقق من وجود تحديث إجباري (In-App Update)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate(context);
    });

    // تحميل الإحصائيات عند فتح التطبيق
    Future.microtask(() {
      context.read<StatisticsProvider>().loadStatistics();
    });

    // مراقبة حالة الاتصال
    _isOffline = !getIt<ConnectivityService>().isConnected;
    getIt<ConnectivityService>().onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() => _isOffline = !isConnected);
        if (isConnected) {
          // عند عودة الاتصال، نحدث الإحصائيات
          context.read<StatisticsProvider>().refreshStatistics();
        }
      }
    });

    // Auto-play
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % 5;
      });
      _startAutoPlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // أزرار في AppBar
        actions: [
          // زر دخول الإدارة
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 8),
            child: _buildAdminButton(context),
          ),
          // قائمة المزيد
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: Colors.white),
              onSelected: (value) => _handleMenuSelection(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('حول التطبيق'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'contact',
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('تواصل معنا'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'rate',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, color: Colors.amber),
                      SizedBox(width: 12),
                      Text('قيّم التطبيق'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, color: AppColors.success),
                      SizedBox(width: 12),
                      Text('شارك التطبيق'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'privacy',
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: AppColors.info),
                      SizedBox(width: 12),
                      Text('سياسة الخصوصية'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'terms',
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined, color: AppColors.info),
                      SizedBox(width: 12),
                      Text('شروط الاستخدام'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<StatisticsProvider>().refreshStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // بانر عدم الاتصال
              if (_isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange.shade700,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'لا يوجد اتصال — يتم عرض البيانات المحفوظة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // سلايدر التوعية
              _buildAwarenessSlider(),

              const SizedBox(height: 24),

              // الأزرار الرئيسية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // زر البحث عن متبرعين
                    _MainActionButton(
                      icon: Icons.search,
                      title: AppStrings.searchForDonors,
                      subtitle: 'ابحث عن متبرعين حسب الفصيلة والمديرية',
                      color: AppColors.primary,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.searchDonors);
                      },
                    ),

                    const SizedBox(height: 16),

                    // زر إضافة متبرع
                    _MainActionButton(
                      icon: Icons.person_add,
                      title: AppStrings.addDonor,
                      subtitle: 'أضف نفسك أو شخص آخر كمتبرع',
                      color: AppColors.success,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.7),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.addDonor);
                      },
                    ),

                    const SizedBox(height: 16),

                    // صف الأزرار الصغيرة
                    Row(
                      children: [
                        // زر التوعية
                        Expanded(
                          child: _SecondaryActionButton(
                            icon: Icons.school,
                            title: AppStrings.awareness,
                            color: AppColors.info,
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRouter.awareness);
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // زر الإبلاغ
                        Expanded(
                          child: _SecondaryActionButton(
                            icon: Icons.report,
                            title: AppStrings.reportDonor,
                            color: AppColors.warning,
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRouter.reportDonor);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Footer - معلومات المطور
                    _buildDeveloperFooter(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// معالجة اختيار عنصر من قائمة المزيد
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'about':
        Navigator.of(context).pushNamed(AppRouter.infoAbout);
        break;
      case 'contact':
        Navigator.of(context).pushNamed(AppRouter.infoContact);
        break;
      case 'rate':
        _rateApp();
        break;
      case 'share':
        _shareApp();
        break;
      case 'privacy':
        _openPrivacyPolicy();
        break;
      case 'terms':
        _openTermsOfUse();
        break;
    }
  }

  /// فتح صفحة تقييم التطبيق على Play Store
  Future<void> _rateApp() async {
    final packageName = 'com.bagomri.yemenbloodbank';
    final Uri playStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    if (await canLaunchUrl(playStoreUri)) {
      await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سيتم إضافة التطبيق على Play Store قريباً'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// مشاركة التطبيق
  Future<void> _shareApp() async {
    const String appName = 'بنك دم اليمن';
    const String packageName = 'com.bagomri.yemenbloodbank';
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=$packageName';

    const String shareText =
        '''
🩸 $appName - تطبيق ينقذ الأرواح!

التطبيق يساعد على:
• البحث السريع عن متبرعين بالدم
• ربط المتبرعين مع المحتاجين
• نشر الوعي حول أهمية التبرع

📥 حمّل التطبيق الآن:
$playStoreUrl

💙 معاً ننقذ الأرواح في اليمن''';

    await Share.share(shareText);
  }

  /// فتح سياسة الخصوصية
  Future<void> _openPrivacyPolicy() async {
    final Uri privacyUrl = Uri.parse(
      'https://salehbagomri.github.io/yemen-blood-bank-privacy/',
    );

    if (await canLaunchUrl(privacyUrl)) {
      await launchUrl(privacyUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// فتح شروط الاستخدام
  Future<void> _openTermsOfUse() async {
    final Uri termsUrl = Uri.parse(
      'https://salehbagomri.github.io/yemen-blood-bank-privacy/terms.html',
    );

    if (await canLaunchUrl(termsUrl)) {
      await launchUrl(termsUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// زر دخول الإدارة الصغير في AppBar (أيقونة فقط)
  Widget _buildAdminButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamed(AppRouter.login);
      },
      icon: const Icon(
        Icons.admin_panel_settings,
        color: Colors.white,
        size: 28,
      ),
      tooltip: 'دخول الإدارة',
    );
  }

  /// Footer - معلومات المطور (بدون مربع)
  Widget _buildDeveloperFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // خط فاصل صغير
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // النص الرئيسي: صنع بحب ❤️ لأهالي اليمن
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'صُنع بحب',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Text(
                'لأهالي اليمن',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // اسم المطور مع الرابط (بدون خط ووزن عادي)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'بواسطة',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _launchURL('https://www.bagomri.com'),
                child: Text(
                  'Saleh Bagomri',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// فتح رابط الموقع
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// سلايدر التوعية
  Widget _buildAwarenessSlider() {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, _) {
        final totalDonors = provider.statistics?.totalDonors ?? 0;

        final slides = [
          _AwarenessSlide(
            icon: Icons.favorite,
            title: 'التبرع بالدم ينقذ الأرواح',
            description: 'كل تبرع بالدم يمكن أن ينقذ حياة ثلاثة أشخاص',
            color: Colors.red.shade600,
          ),
          _AwarenessSlide(
            icon: Icons.health_and_safety,
            title: 'فوائد التبرع بالدم',
            description: 'التبرع بالدم يحسن صحتك ويجدد خلايا الدم',
            color: Colors.green.shade600,
          ),
          _AwarenessSlide(
            icon: Icons.timer,
            title: 'كل 3 ثواني',
            description: 'يحتاج شخص ما إلى نقل دم كل 3 ثواني',
            color: Colors.orange.shade600,
          ),
          _AwarenessSlide(
            icon: Icons.people,
            title: 'كن بطلاً',
            description: 'انضم لآلاف المتبرعين واصنع الفرق',
            color: Colors.blue.shade600,
          ),
          _StatisticsSlide(totalDonors: totalDonors),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              // السلايدر مع fade transition
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 240,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: Container(
                      key: ValueKey<int>(_currentSlideIndex),
                      child: slides[_currentSlideIndex],
                    ),
                  ),
                ),
              ),
              // النقاط ملتصقة بالحافة السفلية
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedSmoothIndicator(
                      activeIndex: _currentSlideIndex,
                      count: slides.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 6,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.5),
                      ),
                      onDotClicked: (index) {
                        setState(() {
                          _currentSlideIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// شريحة توعية
class _AwarenessSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _AwarenessSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // الأيقونة مع تأثير
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            // العنوان
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // الوصف
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// شريحة الإحصائيات
class _StatisticsSlide extends StatelessWidget {
  final int totalDonors;

  const _StatisticsSlide({required this.totalDonors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // أيقونة الوسام
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.military_tech,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            // العنوان الرئيسي
            const Text(
              'أبطال اليمن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // الوصف مع العدد
            Text(
              'هناك $totalDonors بطل تبرع بدمه لينقذ حياة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// زر إجراء رئيسي
class _MainActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MainActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // الأيقونة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),

                const SizedBox(width: 16),

                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // سهم
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// زر إجراء ثانوي
class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
