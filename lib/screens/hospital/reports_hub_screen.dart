import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../../config/app_router.dart';

/// محور التقارير - الشاشة الرئيسية لجميع التقارير
class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 التقارير والإحصائيات'),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقدمة توضيحية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withValues(alpha: 0.1),
                    AppColors.info.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تقارير شاملة ومفيدة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'جميع التقارير قابلة للتصدير بصيغة PDF و Excel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // قائمة التقارير
            _buildReportsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(BuildContext context) {
    final reports = [
      _ReportItem(
        icon: Icons.bloodtype,
        title: 'تقرير فصائل الدم',
        description: 'توزيع المتبرعين حسب فصائل الدم مع النسب المئوية',
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.hospitalReportBloodTypeDetailed,
        ),
      ),
      _ReportItem(
        icon: Icons.location_on,
        title: 'تقرير المناطق الجغرافية',
        description: 'توزيع المتبرعين حسب المديريات والمناطق',
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        onTap: () =>
            Navigator.pushNamed(context, AppRouter.hospitalReportDistrict),
      ),
      _ReportItem(
        icon: Icons.check_circle,
        title: 'تقرير التوفر والإيقاف',
        description: 'المتبرعين المتاحين والموقوفين مع تفاصيل الحالة',
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        onTap: () =>
            Navigator.pushNamed(context, AppRouter.hospitalReportAvailability),
      ),
      _ReportItem(
        icon: Icons.calendar_month,
        title: 'تقرير النشاط الشهري',
        description: 'المتبرعين الجدد والنشاط خلال الشهر الحالي',
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.hospitalReportMonthlySummary,
        ),
      ),
      _ReportItem(
        icon: Icons.description,
        title: 'التقرير الشامل',
        description: 'تقرير كامل يشمل جميع الإحصائيات والبيانات',
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        onTap: () =>
            Navigator.pushNamed(context, AppRouter.hospitalReportComprehensive),
      ),
    ];

    return Column(
      children: reports
          .map((report) => _buildReportCard(context, report))
          .toList(),
    );
  }

  Widget _buildReportCard(BuildContext context, _ReportItem report) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: report.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: report.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // الأيقونة
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(report.icon, color: Colors.white, size: 28),
                  ),

                  const SizedBox(width: 16),

                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // سهم
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// عنصر تقرير
class _ReportItem {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  _ReportItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });
}
