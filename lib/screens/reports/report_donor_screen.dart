import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/report_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_handler.dart';

/// صفحة الإبلاغ عن رقم متبرع غير صالح
class ReportDonorScreen extends StatefulWidget {
  const ReportDonorScreen({super.key});

  @override
  State<ReportDonorScreen> createState() => _ReportDonorScreenState();
}

class _ReportDonorScreenState extends State<ReportDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _reportService = ReportService();
  final _donorService = DonorService();

  String? _selectedReason;
  bool _isLoading = false;

  // أسباب البلاغ
  final Map<String, String> _reportReasons = {
    'number_not_working': AppStrings.numberNotWorking,
    'wrong_number': AppStrings.wrongNumber,
    'refuses_to_donate': AppStrings.refusesToDonate,
    'number_busy': AppStrings.numberBusy,
    'no_answer': AppStrings.noAnswer,
    'deceased': AppStrings.deceased,
    'moved_away': AppStrings.movedAway,
    'health_issues': AppStrings.healthIssues,
    'other': AppStrings.other,
  };

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reportTitle)),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري إرسال البلاغ...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // معلومات توضيحية
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ساعدنا في تحسين قاعدة البيانات بالإبلاغ عن الأرقام غير الصالحة',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // رقم الهاتف
                    CustomTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف المراد الإبلاغ عنه',
                      hint: '777123456 أو +967777123456',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'رقم الهاتف مطلوب';
                        }
                        // التحقق من صحة الرقم
                        String cleanPhone = value.trim().replaceAll(
                          RegExp(r'[\s\-]'),
                          '',
                        );
                        if (cleanPhone.startsWith('+967')) {
                          cleanPhone = cleanPhone.substring(4);
                        } else if (cleanPhone.startsWith('967')) {
                          cleanPhone = cleanPhone.substring(3);
                        }
                        if (cleanPhone.length < 9) {
                          return 'رقم الهاتف غير صالح';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // سبب البلاغ
                    CustomDropdown(
                      value: _selectedReason != null
                          ? _reportReasons[_selectedReason]
                          : null,
                      items: _reportReasons.values.toList(),
                      hint: 'اختر سبب البلاغ',
                      label: AppStrings.reportReason,
                      icon: Icons.report_problem,
                      onChanged: (value) {
                        setState(() {
                          // العثور على المفتاح من القيمة
                          _selectedReason = _reportReasons.entries
                              .firstWhere((entry) => entry.value == value)
                              .key;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'سبب البلاغ مطلوب';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ملاحظات (اختياري)
                    CustomTextField(
                      controller: _notesController,
                      label: 'ملاحظات (اختياري)',
                      hint: 'أي تفاصيل إضافية',
                      icon: Icons.notes,
                      maxLines: 4,
                      maxLength: 300,
                    ),

                    const SizedBox(height: 24),

                    // معلومات مهمة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.info,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'سيتم مراجعة البلاغ من قبل إدارة التطبيق',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: AppColors.info,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'البلاغات سرية ولن يتم مشاركتها مع أحد',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر الإرسال
                    ElevatedButton.icon(
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send),
                      label: const Text(AppStrings.submit),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// إرسال البلاغ
  Future<void> _submitReport() async {
    // التحقق من صحة البيانات
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // البحث عن المتبرع بالرقم
      final donor = await _donorService.findDonorByPhone(_phoneController.text);

      if (donor == null) {
        // المتبرع غير موجود
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم الهاتف غير موجود في قاعدة البيانات'),
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // إرسال البلاغ مع معرف المتبرع الصحيح
      await _reportService.addReport(
        donorId: donor.id,
        donorPhoneNumber: _phoneController.text,
        reason: _selectedReason!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.reportSubmitted),
          backgroundColor: AppColors.success,
        ),
      );

      // العودة للصفحة السابقة
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال البلاغ: ${ErrorHandler.getArabicMessage(e)}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
