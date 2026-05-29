import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/helpers.dart';

/// بطاقة مستشفى محسّنة واحترافية
class EnhancedHospitalCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hospital.isActive
              ? AppColors.success.withOpacity(0.2)
              : AppColors.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // أيقونة المستشفى
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hospital.isActive
                            ? [AppColors.primary, AppColors.primaryDark]
                            : [
                                AppColors.textSecondary,
                                AppColors.textSecondary,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // معلومات أساسية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hospital.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'منذ ${Helpers.formatDateTime(hospital.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // معلومات الاتصال
              _buildInfoRow(
                context,
                Icons.email,
                'البريد الإلكتروني',
                hospital.email,
                onCopy: () => _copyToClipboard(context, hospital.email),
              ),
              if (hospital.phoneNumber != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  Icons.phone,
                  'رقم الهاتف',
                  Helpers.displayPhoneNumber(hospital.phoneNumber!),
                  onCopy: () => _copyToClipboard(
                    context,
                    Helpers.displayPhoneNumber(hospital.phoneNumber!),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.location_on,
                'المديرية',
                hospital.district,
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // الإجراءات
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionChip(
                    context,
                    label: hospital.isActive ? 'تعطيل' : 'تفعيل',
                    icon: hospital.isActive ? Icons.block : Icons.check_circle,
                    color: hospital.isActive
                        ? AppColors.warning
                        : AppColors.success,
                    onTap: onToggleStatus,
                  ),
                  _buildActionChip(
                    context,
                    label: 'تعديل',
                    icon: Icons.edit,
                    color: AppColors.info,
                    onTap: onEdit,
                  ),
                  _buildActionChip(
                    context,
                    label: 'حذف',
                    icon: Icons.delete,
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hospital.isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hospital.isActive
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hospital.isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: hospital.isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            hospital.isActive ? 'نشط' : 'معطل',
            style: TextStyle(
              color: hospital.isActive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
            color: AppColors.primary.withOpacity(0.1),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
}
