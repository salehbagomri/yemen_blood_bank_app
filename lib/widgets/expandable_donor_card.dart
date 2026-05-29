import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/donor_model.dart';
import '../providers/donor_provider.dart';
import '../utils/helpers.dart';

/// كارد متبرع قابل للطي والتوسع - احترافي
class ExpandableDonorCard extends StatefulWidget {
  final DonorModel donor;
  final bool showManagementActions; // إظهار أزرار الإدارة (إيقاف، تحديث)

  const ExpandableDonorCard({
    super.key,
    required this.donor,
    this.showManagementActions = false,
  });

  @override
  State<ExpandableDonorCard> createState() => _ExpandableDonorCardState();
}

class _ExpandableDonorCardState extends State<ExpandableDonorCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : AppColors.divider,
          width: _isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isExpanded ? 0.08 : 0.04),
            blurRadius: _isExpanded ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الجزء المرئي دائماً (مطوي)
                _buildCollapsedContent(),

                // الجزء القابل للتوسع
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildExpandedContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// المحتوى المطوي (يظهر دائماً)
  Widget _buildCollapsedContent() {
    return Row(
      children: [
        // فصيلة الدم
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getBloodTypeColor(widget.donor.bloodType),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              widget.donor.bloodType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // المعلومات الأساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم
              Text(
                widget.donor.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              // العمر والجنس والمديرية
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    Icons.cake_outlined,
                    '${widget.donor.age} سنة',
                  ),
                  _buildInfoChip(
                    widget.donor.gender == 'male' ? Icons.male : Icons.female,
                    widget.donor.gender == 'male' ? 'ذكر' : 'أنثى',
                  ),
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    widget.donor.district,
                  ),
                ],
              ),
            ],
          ),
        ),

        // سهم التوسع ومؤشر الحالة
        Column(
          children: [
            // مؤشر الحالة
            if (widget.donor.isSuspended)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'موقوف',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'متاح',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // سهم التوسع
            Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ],
    );
  }

  /// المحتوى الموسع (يظهر عند الفتح)
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أرقام الهواتف مع أزرار الإجراءات
        _buildPhoneNumberRow(
          'رقم الهاتف الأساسي',
          widget.donor.phoneNumber,
        ),

        if (widget.donor.phoneNumber2 != null &&
            widget.donor.phoneNumber2!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPhoneNumberRow(
            'رقم إضافي 2',
            widget.donor.phoneNumber2!,
          ),
        ],

        if (widget.donor.phoneNumber3 != null &&
            widget.donor.phoneNumber3!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildPhoneNumberRow(
            'رقم إضافي 3',
            widget.donor.phoneNumber3!,
          ),
        ],

        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // معلومات إضافية
        // آخر تبرع
        if (widget.donor.lastDonationDate != null) ...[
          _buildDetailRow(
            Icons.history,
            'آخر تبرع',
            _formatDate(widget.donor.lastDonationDate!),
          ),
          const SizedBox(height: 8),
        ],

        // تاريخ الإيقاف
        if (widget.donor.isSuspended && widget.donor.suspendedUntil != null) ...[
          _buildDetailRow(
            Icons.pause_circle,
            'موقوف حتى',
            _formatDate(widget.donor.suspendedUntil!),
            valueColor: AppColors.warning,
          ),
          const SizedBox(height: 8),
        ],

        // الملاحظات
        if (widget.donor.notes != null && widget.donor.notes!.isNotEmpty) ...[
          _buildDetailRow(
            Icons.notes,
            'ملاحظات',
            widget.donor.notes!,
          ),
          const SizedBox(height: 8),
        ],

        // أزرار الإدارة (فقط للمستشفيات)
        if (widget.showManagementActions) ...[
          const SizedBox(height: 16),
          _buildManagementActions(),
        ],
      ],
    );
  }

  /// معلومة صغيرة (chip)
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// صف معلومات مفصل
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// صف رقم الهاتف مع أزرار الإجراءات
  Widget _buildPhoneNumberRow(String label, String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // الرقم والأزرار
          Row(
            children: [
              // الرقم
              Expanded(
                child: Text(
                  Helpers.displayPhoneNumber(phoneNumber),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // زر الاتصال
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(phoneNumber),
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text(
                    'اتصال',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // زر واتساب
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(phoneNumber),
                  icon: const Icon(Icons.chat, size: 14),
                  label: const Text(
                    'واتساب',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// أزرار الإدارة (إيقاف وتحديث) - للمستشفيات فقط
  Widget _buildManagementActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // زر إيقاف
        if (!widget.donor.isSuspended)
          ElevatedButton.icon(
            onPressed: () => _suspendDonor(context),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('إيقاف 6 أشهر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),

        // زر تحديث آخر تبرع
        ElevatedButton.icon(
          onPressed: () => _updateLastDonation(context),
          icon: const Icon(Icons.update, size: 16),
          label: const Text('تحديث آخر تبرع'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════

  /// الاتصال برقم الهاتف
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// فتح واتساب
  void _openWhatsApp(String phoneNumber) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+967$formattedNumber';
    }

    final message = Uri.encodeComponent(
      'السلام عليكم ورحمة الله وبركاته\n'
      'نأمل منكم التبرع بالدم لإنقاذ حياة إنسان\n'
      'جزاكم الله خيراً',
    );

    final Uri whatsappUri =
        Uri.parse('https://wa.me/$formattedNumber?text=$message');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  /// إيقاف المتبرع
  Future<void> _suspendDonor(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيقاف المتبرع'),
        content: Text(
          'هل تريد إيقاف ${widget.donor.name} لمدة 6 أشهر؟\n\n'
          'سيتم تسجيل هذا كآخر تبرع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context
          .read<DonorProvider>()
          .suspendDonorFor6Months(widget.donor.id);

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف المتبرع لمدة 6 أشهر'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// تحديث آخر تبرع
  Future<void> _updateLastDonation(BuildContext context) async {
    // 1. اختيار التاريخ من المستخدم
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.donor.lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ آخر تبرع',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    // إذا لم يختر تاريخ، نلغي العملية
    if (selectedDate == null) return;

    // 2. حساب التواريخ والحالة
    final sixMonthsFromDonation = selectedDate.add(const Duration(days: 180));
    final now = DateTime.now();
    final willBeSuspended = now.isBefore(sixMonthsFromDonation);
    
    final daysUntilAvailable = willBeSuspended 
        ? sixMonthsFromDonation.difference(now).inDays
        : 0;

    // 3. عرض مربع تأكيد مع التفاصيل
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تحديث آخر تبرع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المتبرع: ${widget.donor.name}'),
            const SizedBox(height: 12),
            Text('تاريخ آخر تبرع: ${_formatDate(selectedDate)}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: willBeSuspended 
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: willBeSuspended 
                      ? AppColors.warning.withOpacity(0.3)
                      : AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        willBeSuspended ? Icons.pause_circle : Icons.check_circle,
                        color: willBeSuspended ? AppColors.warning : AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        willBeSuspended ? 'سيتم الإيقاف' : 'متاح للتبرع',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: willBeSuspended ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (willBeSuspended) ...[
                    const SizedBox(height: 8),
                    Text(
                      'موقوف حتى: ${_formatDate(sixMonthsFromDonation)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'المدة المتبقية: $daysUntilAvailable يوم',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'مر أكثر من 6 أشهر، المتبرع متاح',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('تأكيد التحديث'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // 4. تحديث البيانات بشكل صريح
    // ملاحظة: copyWith لا يدعم null بشكل صحيح، لذلك نستخدم constructor مباشرة
    final updatedDonor = DonorModel(
      id: widget.donor.id,
      name: widget.donor.name,
      phoneNumber: widget.donor.phoneNumber,
      phoneNumber2: widget.donor.phoneNumber2,
      phoneNumber3: widget.donor.phoneNumber3,
      bloodType: widget.donor.bloodType,
      district: widget.donor.district,
      age: widget.donor.age,
      gender: widget.donor.gender,
      notes: widget.donor.notes,
      lastDonationDate: selectedDate, // التاريخ الجديد
      suspendedUntil: willBeSuspended ? sixMonthsFromDonation : null, // null إذا متاح
      isAvailable: !willBeSuspended, // الحالة الجديدة
      createdAt: widget.donor.createdAt,
      updatedAt: DateTime.now(),
      addedBy: widget.donor.addedBy,
      isActive: widget.donor.isActive,
    );

    final success =
        await context.read<DonorProvider>().updateDonor(updatedDonor);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            willBeSuspended
                ? 'تم التحديث - موقوف حتى ${_formatDate(sixMonthsFromDonation)}'
                : 'تم التحديث - المتبرع متاح للتبرع',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// لون فصيلة الدم
  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeA;
    }
    if (bloodType.contains('B') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeB;
    }
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}

