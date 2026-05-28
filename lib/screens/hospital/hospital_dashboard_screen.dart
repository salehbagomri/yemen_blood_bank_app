import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../config/app_router.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/statistics_grid.dart';
import 'widgets/enhanced_main_card.dart';
import 'widgets/dashboard_search_bar.dart';

/// لوحة إدارة المستشفى - النسخة المحسّنة
class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الشاشة (مقيّدة بمحافظة المستشفى)
    Future.microtask(() {
      final gov = context.read<AuthProvider>().hospitalGovernorate;
      context.read<DashboardProvider>().loadDashboardData(governorate: gov);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().refreshDashboard(
              governorate: context.read<AuthProvider>().hospitalGovernorate,
            ),
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل البيانات...');
            }

            if (provider.hasError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'حدث خطأ',
                message: provider.errorMessage ?? 'فشل تحميل البيانات',
                actionLabel: 'إعادة المحاولة',
                onAction: () => provider.loadDashboardData(),
              );
            }

            final stats = provider.statistics;
            if (stats == null) {
              return const EmptyState(
                icon: Icons.dashboard,
                title: 'لا توجد بيانات',
                message: 'لا توجد بيانات لعرضها',
              );
            }

            return _buildDashboardContent(stats);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.hospitalDashboard),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        // زر تسجيل الخروج
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'تسجيل الخروج',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد تسجيل الخروج'),
                content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDashboardContent(stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header مع معلومات المستشفى
          const DashboardHeader(),
          const SizedBox(height: 20),

          // 2. شريط البحث السريع
          const DashboardSearchBar(),
          const SizedBox(height: 20),

          // 3. شبكة الإحصائيات
          StatisticsGrid(statistics: stats),
          const SizedBox(height: 20),

          // 4. الأقسام الرئيسية
          _buildMainSections(stats),
        ],
      ),
    );
  }

  Widget _buildMainSections(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأقسام الرئيسية',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            // إدارة المتبرعين
            EnhancedMainCard(
              icon: Icons.people,
              title: AppStrings.manageDonors,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              onTap: () {
                Navigator.of(context).pushNamed(AppRouter.hospitalManageDonors);
              },
            ),

            // التقارير
            EnhancedMainCard(
              icon: Icons.analytics,
              title: 'التقارير',
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
              ),
              onTap: () {
                Navigator.of(context).pushNamed(AppRouter.hospitalReportsHub);
              },
            ),
          ],
        ),
      ],
    );
  }
}
