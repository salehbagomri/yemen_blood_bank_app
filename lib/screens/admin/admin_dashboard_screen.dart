import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';
import '../../services/hospital_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'widgets/admin_dashboard_header.dart';
import 'widgets/admin_statistics_grid.dart';
import 'widgets/admin_action_card.dart';
import '../../config/app_router.dart';

/// لوحة تحكم الأدمن المحسّنة
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _reportService = ReportService();
  final _hospitalService = HospitalService();
  final _donorService = DonorService();

  int _pendingReportsCount = 0;
  int _totalDonors = 0;
  int _availableDonors = 0;
  int _totalHospitals = 0;
  int _activeHospitals = 0;
  int _suspendedDonors = 0;
  int _inactiveDonors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // تأجيل التحميل لما بعد بناء الواجهة
    Future.microtask(() => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحميل جميع البيانات بالتوازي
      final results = await Future.wait([
        _reportService.getPendingReportsCount(),
        _hospitalService.getAllHospitals(),
        _donorService.getAllDonors(),
        _donorService.getSuspendedDonors(),
      ]);

      if (mounted) {
        final hospitals = results[1] as List;
        final allDonors = results[2] as List;
        final suspended = results[3] as List;

        setState(() {
          _pendingReportsCount = results[0] as int;
          _totalHospitals = hospitals.length;
          _activeHospitals = hospitals.where((h) => h.isActive).length;
          _totalDonors = allDonors.length;
          // المتاحين = النشطين وغير الموقوفين
          _availableDonors = allDonors
              .where((d) => d.isActive && !d.isSuspended)
              .length;
          _suspendedDonors = suspended.length;
          _inactiveDonors = allDonors.where((d) => !d.isActive).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل البيانات: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('لوحة تحكم الأدمن'),
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
          onPressed: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل لوحة التحكم...');
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        message: _errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadDashboardData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            const AdminDashboardHeader(),
            const SizedBox(height: 20),

            // 2. الإحصائيات
            AdminStatisticsGrid(
              totalDonors: _totalDonors,
              totalHospitals: _totalHospitals,
              activeHospitals: _activeHospitals,
              pendingReports: _pendingReportsCount,
              suspendedDonors: _suspendedDonors,
              availableDonors: _availableDonors,
            ),
            const SizedBox(height: 24),

            // 3. الأقسام الرئيسية
            _buildMainSections(),
            const SizedBox(height: 24),

            // 4. أقسام إضافية
            _buildAdditionalSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإدارة الرئيسية',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // مراجعة البلاغات
        AdminActionCard(
          title: 'مراجعة البلاغات',
          subtitle: 'إدارة البلاغات الواردة من المستخدمين',
          icon: Icons.report_problem,
          color: _pendingReportsCount > 0
              ? AppColors.warning
              : AppColors.success,
          badgeCount: _pendingReportsCount,
          isUrgent: _pendingReportsCount > 5,
          onTap: () => _navigateTo(AppRouter.adminReviewReports),
        ),
        const SizedBox(height: 12),

        // إدارة المستشفيات
        AdminActionCard(
          title: 'إدارة المستشفيات',
          subtitle: '$_activeHospitals مستشفى نشط من أصل $_totalHospitals',
          icon: Icons.local_hospital,
          color: AppColors.info,
          onTap: () => _navigateTo(AppRouter.adminManageHospitals),
        ),
        const SizedBox(height: 12),

        // إدارة المتبرعين
        AdminActionCard(
          title: 'إدارة المتبرعين',
          subtitle:
              '$_availableDonors متاح • $_suspendedDonors موقوف • $_inactiveDonors معطل',
          icon: Icons.people,
          color: AppColors.primary,
          badgeCount: _suspendedDonors,
          onTap: () => _navigateTo(AppRouter.adminManageDonors),
        ),
        const SizedBox(height: 12),

        // نظرة عامة على النظام
        AdminActionCard(
          title: 'نظرة عامة على النظام',
          subtitle: 'إحصائيات وتحليلات شاملة',
          icon: Icons.analytics,
          color: AppColors.success,
          onTap: () => _navigateTo(AppRouter.adminSystemOverview),
        ),
        const SizedBox(height: 12),

        // إدارة المناطق
        AdminActionCard(
          title: 'إدارة المناطق',
          subtitle: 'تفعيل/إيقاف المحافظات وإدارة المديريات',
          icon: Icons.map,
          color: AppColors.info,
          onTap: () => _navigateTo(AppRouter.adminManageLocations),
        ),
      ],
    );
  }

  Widget _buildAdditionalSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات متقدمة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // إحصائيات متقدمة
        _buildSettingCard(
          title: 'التقارير والتحليلات',
          subtitle: 'تقارير مفصلة ورسوم بيانية',
          icon: Icons.bar_chart,
          color: AppColors.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('قريباً - التقارير والتحليلات المتقدمة'),
                backgroundColor: AppColors.info,
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // سجل النشاط
        _buildSettingCard(
          title: 'سجل النشاط',
          subtitle: 'عرض آخر العمليات والأحداث',
          icon: Icons.history,
          color: AppColors.info,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('قريباً - سجل النشاط'),
                backgroundColor: AppColors.info,
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // إعدادات النظام
        _buildSettingCard(
          title: 'إعدادات النظام',
          subtitle: 'تخصيص وضبط إعدادات التطبيق',
          icon: Icons.settings,
          color: AppColors.textSecondary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('قريباً - إعدادات النظام'),
                backgroundColor: AppColors.info,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _navigateTo(String routeName) {
    Navigator.of(
      context,
    ).pushNamed(routeName).then((_) => _loadDashboardData());
  }

  Future<void> _showLogoutDialog() async {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
  }
}
