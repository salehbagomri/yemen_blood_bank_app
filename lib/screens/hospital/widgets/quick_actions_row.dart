import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../config/app_router.dart';

/// صف الإجراءات السريعة (3 أزرار)
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // إضافة متبرع
            Expanded(
              child: _QuickActionButton(
                icon: Icons.person_add,
                label: 'إضافة متبرع',
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withValues(alpha: 0.7),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.addDonor);
                },
              ),
            ),

            const SizedBox(width: 12),

            // بحث سريع
            Expanded(
              child: _QuickActionButton(
                icon: Icons.search,
                label: 'بحث متقدم',
                gradient: LinearGradient(
                  colors: [AppColors.info, AppColors.info.withValues(alpha: 0.7)],
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.hospitalAdvancedSearch);
                },
              ),
            ),

            const SizedBox(width: 12),

            // التقارير
            Expanded(
              child: _QuickActionButton(
                icon: Icons.file_download,
                label: 'تصدير',
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.hospitalExportReports);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// زر إجراء سريع
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
