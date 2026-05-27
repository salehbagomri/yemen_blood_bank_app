import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';

/// شاشة تواصل معنا
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا'),
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
        child: Column(
          children: [
            // Header
            Container(
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
                  const Icon(
                    Icons.support_agent,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'نسعد بتواصلكم',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لأي استفسار أو اقتراح لا تتردد في التواصل معنا',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // وسائل التواصل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'وسائل التواصل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // البريد الإلكتروني
                  _buildContactCard(
                    context,
                    icon: Icons.email,
                    title: 'البريد الإلكتروني',
                    subtitle: 's.bagomri@gmail.com',
                    onTap: () => _sendEmail(context, 's.bagomri@gmail.com'),
                    color: Colors.red,
                  ),

                  const SizedBox(height: 12),

                  // الموقع الإلكتروني
                  _buildContactCard(
                    context,
                    icon: Icons.language,
                    title: 'الموقع الإلكتروني',
                    subtitle: 'www.bagomri.com',
                    onTap: () => _openWebsite('https://www.bagomri.com'),
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  // واتساب
                  _buildContactCard(
                    context,
                    icon: Icons.phone,
                    title: 'واتساب',
                    subtitle: 'تواصل عبر واتساب',
                    onTap: () => _openWhatsApp(context),
                    color: Colors.green,
                  ),

                  const SizedBox(height: 24),

                  // معلومات إضافية
                  const Text(
                    'معلومات إضافية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    icon: Icons.location_on,
                    title: 'الموقع',
                    content: 'حضرموت، اليمن',
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    icon: Icons.code,
                    title: 'المطور',
                    content: 'صالح باقمري\nSaleh Bagomri',
                  ),

                  const SizedBox(height: 24),

                  // رسالة ختامية
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primaryDark.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: AppColors.error,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'شكراً لاستخدامكم بنك دم اليمن',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'نسعى دائماً لتقديم أفضل خدمة لكم',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    // تحضير موضوع وجسم الرسالة
    const String subject = 'استفسار عن تطبيق بنك دم اليمن';
    const String body = '''مرحباً،

أود الاستفسار عن تطبيق بنك دم اليمن.

الموضوع:

الرجاء كتابة استفساركم هنا...


مع التحية،''';

    // إنشاء رابط mailto بسيط أولاً
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      // محاولة فتح تطبيق البريد مباشرة
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (e) {
      // إذا فشل، نحاول مع وضع externalApplication
      try {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e2) {
        // في حالة الفشل النهائي، نعرض رسالة للمستخدم
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('الرجاء تثبيت تطبيق Gmail أو أي تطبيق بريد إلكتروني'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'حسناً',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    // رقم الواتساب مع كود الدولة اليمن (+967)
    const String phoneNumber = '967735325614';
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح واتساب'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
