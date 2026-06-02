import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/statistics_provider.dart';
import '../../config/app_router.dart';
import '../../config/service_locator.dart';
import '../../services/connectivity_service.dart';
import '../../services/update_service.dart';
import 'widgets/home_banner_slider.dart';

/// الصفحة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      if (mounted) {
        context.read<StatisticsProvider>().loadStatistics();
      }
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
              const HomeBannerSlider(),

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

                    const SizedBox(height: 12),

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
      padding: const EdgeInsets.only(top: 8, bottom: 16),
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
          const SizedBox(height: 12),

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
        ],
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
