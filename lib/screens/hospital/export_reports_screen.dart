import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/donor_provider.dart';
import '../../services/export_service.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_handler.dart';

/// شاشة تصدير التقارير
class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({super.key});

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;
  String? _exportedFilePath;

  Future<void> _exportDonorsToExcel() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final donors = await context.read<DonorProvider>().loadAllDonors();

      if (donors.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد بيانات متبرعين لتصديرها'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = await _exportService.exportDonorsToExcel(donors);

      setState(() {
        _exportedFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير المتبرعين إلى Excel بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportStatisticsToExcel() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final stats = context.read<DashboardProvider>().statistics;

      if (stats == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد إحصائيات لتصديرها'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = await _exportService.exportStatisticsToExcel(stats);

      setState(() {
        _exportedFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير الإحصائيات إلى Excel بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportDonorsToPDF() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final donors = await context.read<DonorProvider>().loadAllDonors();

      if (donors.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد بيانات متبرعين لتصديرها'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = await _exportService.exportDonorsToPDF(donors);

      setState(() {
        _exportedFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير المتبرعين إلى PDF بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportStatisticsToPDF() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final stats = context.read<DashboardProvider>().statistics;

      if (stats == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد إحصائيات لتصديرها'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = await _exportService.exportStatisticsToPDF(stats);

      setState(() {
        _exportedFilePath = filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير الإحصائيات إلى PDF بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _openFile() async {
    if (_exportedFilePath == null) return;

    try {
      await _exportService.openFile(_exportedFilePath!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل فتح الملف: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    if (_exportedFilePath == null) return;

    try {
      await _exportService.shareFile(_exportedFilePath!, 'تقرير بنك دم اليمن');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل المشاركة: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصدير التقارير'),
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
      body: _isExporting
          ? const LoadingWidget(message: 'جاري تصدير التقرير...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // نص تعريفي
                  Card(
                    color: AppColors.info.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تصدير التقارير',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'يمكنك تصدير قوائم المتبرعين والإحصائيات إلى ملفات Excel أو PDF ومشاركتها',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // قسم تصدير المتبرعين
                  Text(
                    'تصدير قائمة المتبرعين',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ExportCard(
                          icon: Icons.table_chart,
                          title: 'Excel',
                          subtitle: 'ملف .xlsx',
                          color: Colors.green,
                          onTap: _exportDonorsToExcel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ExportCard(
                          icon: Icons.picture_as_pdf,
                          title: 'PDF',
                          subtitle: 'ملف .pdf',
                          color: Colors.red,
                          onTap: _exportDonorsToPDF,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // قسم تصدير الإحصائيات
                  Text(
                    'تصدير الإحصائيات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ExportCard(
                          icon: Icons.table_chart,
                          title: 'Excel',
                          subtitle: 'إحصائيات مفصلة',
                          color: Colors.blue,
                          onTap: _exportStatisticsToExcel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ExportCard(
                          icon: Icons.picture_as_pdf,
                          title: 'PDF',
                          subtitle: 'تقرير شامل',
                          color: Colors.orange,
                          onTap: _exportStatisticsToPDF,
                        ),
                      ),
                    ],
                  ),

                  // أزرار فتح ومشاركة (تظهر فقط عند وجود ملف مصدّر)
                  if (_exportedFilePath != null) ...[
                    const SizedBox(height: 24),

                    // نص نجاح التصدير
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تم حفظ الملف بنجاح!',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // صف الأزرار
                    Row(
                      children: [
                        // زر فتح الملف
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _openFile,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.open_in_new, color: Colors.white, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        'فتح الملف',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // زر مشاركة
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _shareFile,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.share, color: Colors.white, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        'مشاركة',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// بطاقة خيار التصدير
class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
