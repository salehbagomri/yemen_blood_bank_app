import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';
import '../../../models/banner_model.dart';
import '../../../providers/banner_provider.dart';
import '../../../providers/statistics_provider.dart';

/// ويدجت السلايدر الاحترافي للبانرات الديناميكية في الصفحة الرئيسية (يدعم الصوري والنصي)
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  Timer? _resumeTimer;
  int _currentPage = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // تحميل البانرات النشطة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().loadActiveBanners();
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _resumeTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    if (_isUserInteracting) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final provider = context.read<BannerProvider>();
      final bannerCount = provider.activeBanners.isNotEmpty 
          ? provider.activeBanners.length 
          : 5; // 5 default slides

      if (_pageController.hasClients && bannerCount > 1) {
        final nextPage = (_currentPage + 1) % bannerCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _stopAutoPlay();
    _resumeTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _resumeTimer?.cancel();
    // استئناف التشغيل التلقائي بعد 3 ثوانٍ من انتهاء التفاعل
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      _isUserInteracting = false;
      _startAutoPlay();
    });
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    if (banner.actionType == 'internal_route' && banner.actionValue != null) {
      Navigator.of(context).pushNamed(banner.actionValue!);
    } else if (banner.actionType == 'external_url' && banner.actionValue != null) {
      final url = Uri.parse(banner.actionValue!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BannerProvider, StatisticsProvider>(
      builder: (context, bannerProvider, statsProvider, _) {
        if (bannerProvider.isLoading && bannerProvider.activeBanners.isEmpty) {
          return _buildShimmerLoading();
        }

        final banners = bannerProvider.activeBanners;
        final totalDonors = statsProvider.statistics?.totalDonors ?? 0;

        // إذا لم يكن هناك بانرات نشطة في السيرفر أو الكاش، نعرض الشرائح الافتراضية
        final bool showDefaults = banners.isEmpty;
        final int itemCount = showDefaults ? 5 : banners.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Stack(
                children: [
                  // السلايدر الذكي
                  GestureDetector(
                    onPanDown: (_) => _onUserInteractionStart(),
                    onPanCancel: () => _onUserInteractionEnd(),
                    onPanEnd: (_) => _onUserInteractionEnd(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200, // ارتفاع أنظف وأكثر حداثة
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: itemCount,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            if (showDefaults) {
                              return _buildDefaultSlide(index, totalDonors);
                            }
                            final banner = banners[index];
                            return _buildBannerSlide(banner, totalDonors);
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // النقاط التفاعلية (مؤشر حديث ExpandingDots)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AnimatedSmoothIndicator(
                          activeIndex: _currentPage,
                          count: itemCount,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            expansionFactor: 4,
                            spacing: 6,
                            activeDotColor: Colors.white,
                            dotColor: Colors.white60,
                          ),
                          onDotClicked: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// بناء البانر الديناميكي (يدعم النصي والصوري)
  Widget _buildBannerSlide(BannerModel banner, int totalDonors) {
    if (banner.isTextBanner) {
      // استبدال متغيرات الإحصائيات في النص إذا وُجدت
      String? description = banner.subtitle;
      if (description != null && description.contains('{{total_donors}}')) {
        description = description.replaceAll('{{total_donors}}', totalDonors.toString());
      }
      
      return _buildTextCard(
        icon: _getIcon(banner.iconName),
        title: banner.title,
        description: description ?? '',
        gradient: _getGradient(banner.bgGradient),
        onTap: () => _handleBannerTap(banner),
        hasAction: banner.actionType != 'none',
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleBannerTap(banner),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // صورة الخلفية مع التخزين المؤقت وتأثير التحميل
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.divider,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 50, color: AppColors.textHint),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildShimmerLoading();
              },
            ),
            
            // تدرج لوني أسود لحماية النصوص
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            
            // النصوص والتحفيز
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 4),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      banner.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        shadows: const [
                          Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 3),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // مؤشر صغير تفاعلي إذا كان للبانر إجراء
                  if (banner.actionType != 'none') ...[
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اضغط للمتابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء الشرائح الافتراضية
  Widget _buildDefaultSlide(int index, int totalDonors) {
    switch (index) {
      case 0:
        return _buildTextCard(
          icon: Icons.favorite,
          title: 'التبرع بالدم ينقذ الأرواح',
          description: 'كل تبرع بالدم يمكن أن ينقذ حياة ثلاثة أشخاص',
          gradient: _getGradient('red'),
        );
      case 1:
        return _buildTextCard(
          icon: Icons.health_and_safety,
          title: 'فوائد التبرع بالدم',
          description: 'التبرع بالدم يحسن صحتك ويجدد خلايا الدم ويحفز الدورة الدموية',
          gradient: _getGradient('green'),
        );
      case 2:
        return _buildTextCard(
          icon: Icons.timer,
          title: 'كل 3 ثواني',
          description: 'يحتاج شخص ما إلى نقل دم في مكان ما كل ثلاث ثوانٍ فقط',
          gradient: _getGradient('orange'),
        );
      case 3:
        return _buildTextCard(
          icon: Icons.people,
          title: 'كن بطلاً ومتبرعاً',
          description: 'انضم لآلاف الأبطال المتبرعين بالدم في اليمن واصنع فرقاً حقيقياً',
          gradient: _getGradient('blue'),
        );
      case 4:
        return _buildTextCard(
          icon: Icons.military_tech,
          title: 'أبطال اليمن',
          description: 'هناك $totalDonors بطل تبرع بدمه لينقذ الأرواح في مجتمعنا',
          gradient: _getGradient('crimson'),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    VoidCallback? onTap,
    bool hasAction = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasAction) ...[
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'اضغط للمتابعة',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white70, size: 10),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// الحصول على الأيقونة بناءً على الاسم المسجل
  IconData _getIcon(String? name) {
    switch (name) {
      case 'favorite':
        return Icons.favorite;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'timer':
        return Icons.timer;
      case 'people':
        return Icons.people;
      case 'military_tech':
        return Icons.military_tech;
      default:
        return Icons.info_outline;
    }
  }

  /// الحصول على التدرج اللوني بناءً على الاسم المسجل
  Gradient _getGradient(String? name) {
    switch (name) {
      case 'red':
        return const LinearGradient(
          colors: [Color(0xFFE63946), Color(0xFFD62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'green':
        return const LinearGradient(
          colors: [Color(0xFF2A9D8F), Color(0xFF264653)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'orange':
        return const LinearGradient(
          colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'blue':
        return const LinearGradient(
          colors: [Color(0xFF457B9D), Color(0xFF1D3557)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'crimson':
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E0018), Color(0xFFB8262F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// وميض التحميل (Shimmer)
  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 200,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
