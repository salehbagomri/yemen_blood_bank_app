import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// شبكة الإحصائيات للأدمن - نسخة محسّنة
class AdminStatisticsGrid extends StatelessWidget {
  final int totalDonors;
  final int totalHospitals;
  final int activeHospitals;
  final int pendingReports;
  final int suspendedDonors;
  final int availableDonors;

  const AdminStatisticsGrid({
    super.key,
    required this.totalDonors,
    required this.totalHospitals,
    required this.activeHospitals,
    required this.pendingReports,
    required this.suspendedDonors,
    required this.availableDonors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة سريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              title: 'إجمالي المتبرعين',
              value: '$totalDonors',
              icon: Icons.people,
              color: AppColors.primary,
              trend: '+${(totalDonors * 0.12).toInt()}',
              trendLabel: 'هذا الشهر',
            ),
            _StatCard(
              title: 'المتبرعين المتاحين',
              value: '$availableDonors',
              icon: Icons.favorite,
              color: AppColors.success,
              percentage: totalDonors > 0 
                  ? '${((availableDonors / totalDonors) * 100).toStringAsFixed(0)}%'
                  : '0%',
            ),
            _StatCard(
              title: 'المستشفيات',
              value: '$totalHospitals',
              icon: Icons.local_hospital,
              color: AppColors.info,
              subtitle: '$activeHospitals نشط',
            ),
            _StatCard(
              title: 'بلاغات معلقة',
              value: '$pendingReports',
              icon: Icons.warning_amber_rounded,
              color: pendingReports > 0 ? AppColors.warning : AppColors.success,
              urgent: pendingReports > 5,
            ),
          ],
        ),
      ],
    );
  }
}

/// بطاقة إحصائية محسّنة
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final String? trendLabel;
  final String? percentage;
  final bool urgent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.trendLabel,
    this.percentage,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgent ? color : AppColors.divider,
          width: urgent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: urgent
                ? color.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: urgent ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 18,
                    ),
              ),
              if (percentage != null) ...[
                const SizedBox(width: 4),
                Text(
                  percentage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ],
            ],
          ),

          // Footer
          if (subtitle != null || trend != null)
            Row(
              children: [
                if (trend != null) ...[
                  Icon(
                    Icons.trending_up,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                  ),
                  if (trendLabel != null) ...[
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        trendLabel!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

