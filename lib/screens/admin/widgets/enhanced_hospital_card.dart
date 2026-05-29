import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/helpers.dart';

/// بطاقة مستشفى محسّنة قابلة للطي/الفتح (مثل بطاقة المتبرع)
class EnhancedHospitalCard extends StatefulWidget {
  final HospitalModel hospital;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EnhancedHospitalCard({
    super.key,
    required this.hospital,
    required this.onTap,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EnhancedHospitalCard> createState() => _EnhancedHospitalCardState();
}

class _EnhancedHospitalCardState extends State<EnhancedHospitalCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.hospital.isActive
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
          width: _isExpanded ? 2 : 1,
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
              // الهيدر — ظاهر دائماً
              _buildHeader(context),

              // التفاصيل والإجراءات — تظهر عند الفتح
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildDetails(context),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// الهيدر: أيقونة + اسم + المديرية + شارة الحالة + سهم الطي
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // أيقونة المستشفى
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.hospital.isActive
                  ? [AppColors.primary, AppColors.primaryDark]
                  : [AppColors.textSecondary, AppColors.textSecondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 24,
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
                      widget.hospital.name,
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
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.hospital.district,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  /// التفاصيل: البريد، الهاتف، المديرية، تاريخ الإنشاء
  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context,
          Icons.email,
          'البريد الإلكتروني',
          widget.hospital.email,
          onCopy: () => _copyToClipboard(context, widget.hospital.email),
        ),
        if (widget.hospital.phoneNumber != null) ...[
          const SizedBox(height: 10),
          _buildInfoRow(
            context,
            Icons.phone,
            'رقم الهاتف',
            Helpers.displayPhoneNumber(widget.hospital.phoneNumber!),
            onCopy: () => _copyToClipboard(
              context,
              Helpers.displayPhoneNumber(widget.hospital.phoneNumber!),
            ),
          ),
        ],
        const SizedBox(height: 10),
        _buildInfoRow(
          context,
          Icons.location_on,
          'المديرية',
          widget.hospital.district,
        ),
        const SizedBox(height: 10),
        _buildInfoRow(
          context,
          Icons.calendar_today,
          'تاريخ الإنشاء',
          Helpers.formatDateTime(widget.hospital.createdAt),
        ),
      ],
    );
  }

  /// إجراءات الأدمن
  Widget _buildActions(BuildContext context) {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionChip(
              context,
              label: 'تعديل',
              icon: Icons.edit,
              color: AppColors.info,
              onTap: widget.onEdit,
            ),
            _buildActionChip(
              context,
              label: 'حذف',
              icon: Icons.delete,
              color: AppColors.error,
              onTap: widget.onDelete,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // زر نسخ جميع البيانات
        OutlinedButton.icon(
          onPressed: () => _copyAllData(context),
          icon: const Icon(Icons.content_copy, size: 18),
          label: const Text('نسخ جميع البيانات'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.info,
            side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.hospital.isActive;
    final color = isActive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'نشط' : 'معطل',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: onCopy,
            tooltip: 'نسخ',
            color: AppColors.textSecondary,
          ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ: $text'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyAllData(BuildContext context) {
    final data = '''
الاسم: ${widget.hospital.name}
البريد: ${widget.hospital.email}
${widget.hospital.phoneNumber != null ? 'الهاتف: ${Helpers.displayPhoneNumber(widget.hospital.phoneNumber!)}\n' : ''}المديرية: ${widget.hospital.district}
تاريخ الإنشاء: ${Helpers.formatDateTime(widget.hospital.createdAt)}
''';

    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جميع البيانات'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
