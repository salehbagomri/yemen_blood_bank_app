import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../models/donor_model.dart';
import '../../../providers/donor_provider.dart';
import '../../../utils/helpers.dart';
import '../../../config/app_router.dart';

/// بطاقة متبرع محسّنة للأدمن - صلاحيات كاملة
class AdminDonorCard extends StatefulWidget {
  final DonorModel donor;

  const AdminDonorCard({super.key, required this.donor});

  @override
  State<AdminDonorCard> createState() => _AdminDonorCardState();
}

class _AdminDonorCardState extends State<AdminDonorCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.donor.isSuspended
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildDetails(),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildAdminActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // أيقونة فصيلة الدم
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getBloodTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBloodTypeColor().withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.donor.bloodType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getBloodTypeColor(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // معلومات أساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.donor.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.displayPhoneNumber(widget.donor.phoneNumber),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // شارة الحالة
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    // تحديد الحالة بالترتيب: معطل > موقوف > متاح
    String status;
    Color statusColor;
    IconData statusIcon;

    if (!widget.donor.isActive) {
      status = 'معطل';
      statusColor = AppColors.error;
      statusIcon = Icons.block;
    } else if (widget.donor.isSuspended) {
      status = 'موقوف';
      statusColor = AppColors.warning;
      statusIcon = Icons.pause_circle;
    } else {
      status = 'متاح';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أزرار التواصل السريع — الرقم الأساسي
        _buildPhoneContactRow(
          'الهاتف الأساسي',
          widget.donor.phoneNumber,
        ),
        if (widget.donor.phoneNumber2 != null) ...[
          const SizedBox(height: 8),
          _buildPhoneContactRow(
            'رقم إضافي 2',
            widget.donor.phoneNumber2!,
          ),
        ],
        if (widget.donor.phoneNumber3 != null) ...[
          const SizedBox(height: 8),
          _buildPhoneContactRow(
            'رقم إضافي 3',
            widget.donor.phoneNumber3!,
          ),
        ],

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // باقي التفاصيل
        _buildDetailRow(Icons.location_on, 'المديرية', widget.donor.district),
        const SizedBox(height: 8),
        _buildDetailRow(
          widget.donor.gender == 'male' ? Icons.male : Icons.female,
          'الجنس',
          widget.donor.gender == 'male' ? 'ذكر' : 'أنثى',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(Icons.cake, 'العمر', '${widget.donor.age} سنة'),
        if (widget.donor.lastDonationDate != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.calendar_today,
            'آخر تبرع',
            DateFormat('yyyy-MM-dd').format(widget.donor.lastDonationDate!),
          ),
        ],
        if (widget.donor.suspendedUntil != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.event_busy,
            'موقوف حتى',
            DateFormat('yyyy-MM-dd').format(widget.donor.suspendedUntil!),
          ),
        ],
        if (widget.donor.notes != null && widget.donor.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.donor.notes!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// صف رقم الهاتف مع أزرار اتصال/واتساب
  Widget _buildPhoneContactRow(String label, String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // الرقم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Helpers.displayPhoneNumber(phoneNumber),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // زر الاتصال
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(phoneNumber),
              icon: const Icon(Icons.phone, size: 14),
              label: const Text('اتصال', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
              label: const Text('واتساب', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool copyable = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () => _copyToClipboard(value),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'نسخ',
          ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات الأدمن',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // الإجراءات الأساسية
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // إيقاف/إلغاء الإيقاف
            if (!widget.donor.isSuspended)
              _buildActionChip(
                label: 'إيقاف 6 أشهر',
                icon: Icons.pause_circle,
                color: AppColors.warning,
                onTap: () => _suspendFor6Months(context),
              )
            else
              _buildActionChip(
                label: 'إلغاء الإيقاف',
                icon: Icons.play_circle,
                color: AppColors.success,
                onTap: () => _cancelSuspension(context),
              ),

            // تحديث آخر تبرع
            _buildActionChip(
              label: 'تحديث آخر تبرع',
              icon: Icons.update,
              color: AppColors.info,
              onTap: () => _updateLastDonation(context),
            ),

            // تعديل البيانات
            _buildActionChip(
              label: 'تعديل البيانات',
              icon: Icons.edit,
              color: AppColors.primary,
              onTap: () => _editDonor(context),
            ),

            // تعطيل/تفعيل الحساب
            _buildActionChip(
              label: widget.donor.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
              icon: widget.donor.isActive ? Icons.block : Icons.check_circle,
              color: widget.donor.isActive
                  ? AppColors.error
                  : AppColors.success,
              onTap: () => _toggleActiveStatus(context),
            ),

            // عرض البلاغات
            _buildActionChip(
              label: 'البلاغات',
              icon: Icons.report,
              color: AppColors.warning,
              onTap: () => _viewReports(context),
            ),

            // حذف نهائي
            _buildActionChip(
              label: 'حذف نهائي',
              icon: Icons.delete_forever,
              color: AppColors.error,
              onTap: () => _deletePermanently(context),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // إجراءات إضافية
        _buildMoreActions(),
      ],
    );
  }

  Widget _buildMoreActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // زر نسخ جميع البيانات
        OutlinedButton.icon(
          onPressed: () => _copyAllData(context),
          icon: const Icon(Icons.content_copy, size: 18),
          label: const Text('نسخ جميع البيانات'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.info,
            side: BorderSide(color: AppColors.info.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== الإجراءات ====================

  /// إيقاف المتبرع لمدة 6 أشهر
  Future<void> _suspendFor6Months(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإيقاف'),
        content: Text('هل تريد إيقاف ${widget.donor.name} لمدة 6 أشهر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('إيقاف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final suspendedUntil = DateTime.now().add(const Duration(days: 180));
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
        isAvailable: false,
        lastDonationDate: DateTime.now(),
        suspendedUntil: suspendedUntil,
        createdAt: widget.donor.createdAt,
        updatedAt: DateTime.now(),
        addedBy: widget.donor.addedBy,
        isActive: widget.donor.isActive,
      );

      final success = await context.read<DonorProvider>().updateDonor(
        updatedDonor,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إيقاف ${widget.donor.name} حتى ${DateFormat('yyyy-MM-dd').format(suspendedUntil)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// إلغاء الإيقاف
  Future<void> _cancelSuspension(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الإيقاف'),
        content: Text('هل تريد إلغاء إيقاف ${widget.donor.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
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
        isAvailable: true,
        lastDonationDate: widget.donor.lastDonationDate,
        suspendedUntil: null,
        createdAt: widget.donor.createdAt,
        updatedAt: DateTime.now(),
        addedBy: widget.donor.addedBy,
        isActive: widget.donor.isActive,
      );

      final success = await context.read<DonorProvider>().updateDonor(
        updatedDonor,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء إيقاف ${widget.donor.name}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// تحديث آخر تبرع
  Future<void> _updateLastDonation(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.donor.lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ آخر تبرع',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (pickedDate == null) return;

    final sixMonthsFromDonation = pickedDate.add(const Duration(days: 180));
    final now = DateTime.now();
    final willBeSuspended = now.isBefore(sixMonthsFromDonation);

    if (context.mounted) {
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
        isAvailable: !willBeSuspended,
        lastDonationDate: pickedDate,
        suspendedUntil: willBeSuspended ? sixMonthsFromDonation : null,
        createdAt: widget.donor.createdAt,
        updatedAt: DateTime.now(),
        addedBy: widget.donor.addedBy,
        isActive: widget.donor.isActive,
      );

      final success = await context.read<DonorProvider>().updateDonor(
        updatedDonor,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث آخر تبرع'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// تعديل بيانات المتبرع
  Future<void> _editDonor(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.adminEditDonor,
      arguments: widget.donor,
    );

    // إذا تم الحفظ بنجاح، لا حاجة لإعادة تحميل البيانات
    // Provider سيحدث تلقائياً
    if (result == true && context.mounted) {
      // يمكن إضافة أي إجراء إضافي هنا إذا لزم الأمر
    }
  }

  /// تعطيل/تفعيل الحساب
  Future<void> _toggleActiveStatus(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.donor.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب'),
        content: Text(
          widget.donor.isActive
              ? 'هل تريد تعطيل حساب ${widget.donor.name}؟\n\nالحساب المعطل لن يظهر في البحث.'
              : 'هل تريد تفعيل حساب ${widget.donor.name}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.donor.isActive
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(widget.donor.isActive ? 'تعطيل' : 'تفعيل'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
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
        isAvailable: widget.donor.isAvailable,
        lastDonationDate: widget.donor.lastDonationDate,
        suspendedUntil: widget.donor.suspendedUntil,
        createdAt: widget.donor.createdAt,
        updatedAt: DateTime.now(),
        addedBy: widget.donor.addedBy,
        isActive: !widget.donor.isActive,
      );

      final success = await context.read<DonorProvider>().updateDonor(
        updatedDonor,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.donor.isActive ? 'تم تعطيل الحساب' : 'تم تفعيل الحساب',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// عرض البلاغات
  void _viewReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('قريباً - عرض البلاغات المتعلقة بهذا المتبرع'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// حذف نهائي
  Future<void> _deletePermanently(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('حذف نهائي'),
          ],
        ),
        content: Text(
          'هل تريد حذف ${widget.donor.name} نهائياً؟\n\n⚠️ هذا الإجراء لا يمكن التراجع عنه!\n\nسيتم حذف:\n• جميع البيانات\n• السجل التاريخي\n• البلاغات المرتبطة',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<DonorProvider>().deleteDonor(
        widget.donor.id,
      );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف ${widget.donor.name} نهائياً'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// نسخ جميع البيانات
  void _copyAllData(BuildContext context) {
    // تحديد الحالة
    String status;
    if (!widget.donor.isActive) {
      status = 'معطل';
    } else if (widget.donor.isSuspended) {
      status = 'موقوف';
    } else {
      status = 'متاح';
    }

    final data =
        '''
الاسم: ${widget.donor.name}
فصيلة الدم: ${widget.donor.bloodType}
الهاتف 1: ${Helpers.displayPhoneNumber(widget.donor.phoneNumber)}
${widget.donor.phoneNumber2 != null ? 'الهاتف 2: ${Helpers.displayPhoneNumber(widget.donor.phoneNumber2!)}\n' : ''}${widget.donor.phoneNumber3 != null ? 'الهاتف 3: ${Helpers.displayPhoneNumber(widget.donor.phoneNumber3!)}\n' : ''}المديرية: ${widget.donor.district}
الجنس: ${widget.donor.gender == 'male' ? 'ذكر' : 'أنثى'}
العمر: ${widget.donor.age} سنة
الحالة: $status
${widget.donor.lastDonationDate != null ? 'آخر تبرع: ${DateFormat('yyyy-MM-dd').format(widget.donor.lastDonationDate!)}\n' : ''}${widget.donor.suspendedUntil != null ? 'موقوف حتى: ${DateFormat('yyyy-MM-dd').format(widget.donor.suspendedUntil!)}\n' : ''}${widget.donor.notes != null && widget.donor.notes!.isNotEmpty ? 'ملاحظات: ${widget.donor.notes}\n' : ''}تاريخ الإضافة: ${Helpers.formatDateTime(widget.donor.createdAt)}
''';

    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جميع البيانات'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ: $text'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getBloodTypeColor() {
    if (widget.donor.bloodType.contains('A') &&
        !widget.donor.bloodType.contains('AB')) {
      return AppColors.bloodTypeA;
    }
    if (widget.donor.bloodType.contains('B') &&
        !widget.donor.bloodType.contains('AB')) {
      return AppColors.bloodTypeB;
    }
    if (widget.donor.bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (widget.donor.bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }

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
}
