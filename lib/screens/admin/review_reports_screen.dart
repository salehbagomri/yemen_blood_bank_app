import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../../config/app_router.dart';

/// شاشة مراجعة البلاغات (للأدمن)
class ReviewReportsScreen extends StatefulWidget {
  const ReviewReportsScreen({super.key});

  @override
  State<ReviewReportsScreen> createState() => _ReviewReportsScreenState();
}

class _ReviewReportsScreenState extends State<ReviewReportsScreen> {
  final _reportService = ReportService();
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'pending'; // pending, approved, rejected, all

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = _selectedStatus == 'all'
          ? await _reportService.getAllReports()
          : await _reportService.getAllReports(status: _selectedStatus);

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getArabicMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reviewReports),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports),
        ],
      ),
      body: Column(
        children: [
          // فلتر الحالة
          _buildStatusFilter(),

          // قائمة البلاغات
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('pending', 'معلقة', AppColors.warning),
            const SizedBox(width: 8),
            _buildFilterChip('approved', 'مقبولة', AppColors.success),
            const SizedBox(width: 8),
            _buildFilterChip('rejected', 'مرفوضة', AppColors.error),
            const SizedBox(width: 8),
            _buildFilterChip('all', 'الكل', AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
        _loadReports();
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل البلاغات...');
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        message: _errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadReports,
      );
    }

    if (_reports.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: 'لا توجد بلاغات',
        message: _selectedStatus == 'pending'
            ? 'لا توجد بلاغات معلقة'
            : 'لا توجد بلاغات في هذه الفئة',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _ReportCard(
            report: report,
            onTap: () => _openReportDetail(report),
          );
        },
      ),
    );
  }

  Future<void> _openReportDetail(ReportModel report) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.adminReportDetail,
      arguments: report,
    );

    // إذا تم اتخاذ إجراء (قبول/رفض)، أعد تحميل القائمة
    if (result == true) {
      _loadReports();
    }
  }
}

/// بطاقة البلاغ
class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const _ReportCard({required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'بلاغ عن: ${report.donorPhoneNumber}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Badge الأولوية
                            if (report.priority == 'critical' ||
                                report.priority == 'high')
                              _buildPriorityBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatDateTime(report.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.report_problem,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'السبب: ${report.reasonText}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (report.notes != null && report.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // تمت إزالة الأزرار - الآن يفتح شاشة التفاصيل عند الضغط على البطاقة
              if (report.isPending) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'اضغط لعرض التفاصيل واتخاذ الإجراء',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    IconData icon;

    if (report.priority == 'critical') {
      color = AppColors.error;
      icon = Icons.warning;
    } else {
      color = Colors.orange;
      icon = Icons.priority_high;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            report.priorityText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    if (report.isPending) {
      color = AppColors.warning;
      icon = Icons.pending;
    } else if (report.isApproved) {
      color = AppColors.success;
      icon = Icons.check_circle;
    } else {
      color = AppColors.error;
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            report.statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
