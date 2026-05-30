import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    // وضع platformDefault هو الأفضل للـ mailto وتطبيقات النظام الداخلية
    final mode = url.startsWith('http')
        ? LaunchMode.externalApplication
        : LaunchMode.platformDefault;
    await launchUrl(uri, mode: mode);
  } catch (e) {
    debugPrint('Could not launch $url : $e');
  }
}

/// شاشة حول التطبيق
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _scrollController = ScrollController();
  final _devSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. Header مع شعار التطبيق
            _buildHeader(),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. عن التطبيق
                  _buildSectionTitle('📱 عن التطبيق'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    '''بنك دم اليمن هو تطبيق مجاني يهدف إلى ربط المتبرعين بالدم مع المحتاجين في اليمن.

التطبيق يساعد على:
• البحث السريع عن متبرعين حسب فصيلة الدم والمنطقة
• التسجيل كمتبرع وإدارة معلوماتك
• نشر الوعي حول أهمية التبرع بالدم
• توفير الوقت في حالات الطوارئ
• ربط المجتمع في عمل إنساني نبيل''',
                  ),

                  const SizedBox(height: 24),

                  // 3. الميزات
                  _buildSectionTitle('✨ الميزات'),
                  const SizedBox(height: 12),
                  _buildFeaturesCard(),

                  const SizedBox(height: 24),

                  // 4. إخلاء المسؤولية
                  _buildSectionTitle('📋 إخلاء المسؤولية'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'هذا التطبيق أداة مساعدة لتسهيل التواصل بين المتبرعين والمحتاجين، '
                    'ولا يُغني عن الاستشارة الطبية المتخصصة. '
                    'يجب التأكد من الأهلية الطبية للتبرع من خلال الجهات الصحية المختصة.',
                  ),

                  const SizedBox(height: 24),

                  // 5. التطوير والدعم الفني (قابل للطي)
                  _buildCollapsibleDeveloperSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // شعار التطبيق
          SvgPicture.asset(
            'assets/icons/logo-m.svg',
            width: 120,
            height: 120,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          const Text(
            'بنك دم اليمن',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Yemen Blood Bank',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'الإصدار 1.0.3',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem(Icons.search, 'بحث متقدم عن المتبرعين'),
          _buildFeatureItem(Icons.person_add, 'تسجيل سهل وسريع'),
          _buildFeatureItem(Icons.dashboard, 'لوحة تحكم شاملة للإدارة'),
          _buildFeatureItem(Icons.phone_android, 'تصميم عصري ومريح'),
          _buildFeatureItem(Icons.lock, 'حماية وخصوصية البيانات'),
          _buildFeatureItem(Icons.favorite, 'خدمة مجانية 100%'),
          _buildFeatureItem(Icons.wifi_off, 'يعمل بدون إنترنت'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleDeveloperSection() {
    return Container(
      key: _devSectionKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
          title: const Text(
            'التطوير والدعم الفني',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          onExpansionChanged: (expanded) {
            if (expanded) {
              // ننتظر انتهاء الانيميشن ثم نسكرول للقسم
              Future.delayed(const Duration(milliseconds: 300), () {
                final ctx = _devSectionKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    alignment: 0.1, // يظهر القسم قرب أعلى الشاشة
                  );
                }
              });
            }
          },
          children: [
            _buildDeveloperSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // عنوان فرعي
          const Text(
            'تطوير وتصميم',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // اسم المطور (عربي فقط)
          const Text(
            'صالح باقمري',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: AppColors.primary.withOpacity(0.15)),
          const SizedBox(height: 12),

          // أزرار التواصل التفاعلية
          _buildContactButton(
            icon: Icons.email_outlined,
            label: 's.bagomri@gmail.com',
            onTap: () => _launchUrl('mailto:s.bagomri@gmail.com'),
          ),
          const SizedBox(height: 10),
          _buildContactButton(
            icon: Icons.chat,
            label: '+967 770 727 055',
            subtitle: 'تواصل عبر واتساب',
            color: const Color(0xFF25D366),
            onTap: () => _launchUrl('https://wa.me/967770727055'),
            isLtr: true, // فرض اتجاه من اليسار لليمين
          ),
          const SizedBox(height: 10),
          _buildContactButton(
            icon: Icons.language,
            label: 'www.bagomri.com',
            onTap: () => _launchUrl('https://www.bagomri.com'),
            isLtr: true,
          ),
          const SizedBox(height: 10),
          _buildContactButton(
            icon: Icons.location_on_outlined,
            label: 'حضرموت، اليمن',
            onTap: null, // غير تفاعلي
          ),

          const SizedBox(height: 20),
          Divider(color: AppColors.primary.withOpacity(0.15)),
          const SizedBox(height: 12),

          // حقوق النشر
          const Text(
            'بنك دم اليمن 2026 \u00A9',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    String? subtitle,
    Color? color,
    VoidCallback? onTap,
    bool isLtr = false,
  }) {
    final isClickable = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    textDirection: isLtr ? TextDirection.ltr : null,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: color ?? AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
