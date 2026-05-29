import 'package:flutter/material.dart';
import '../models/donor_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/helpers.dart';

/// بطاقة عرض معلومات المتبرع
class DonorCard extends Widget {
  final DonorModel donor;
  final VoidCallback? onTap;
  final bool showActions; // عرض أزرار الاتصال وواتساب

  const DonorCard({
    super.key,
    required this.donor,
    this.onTap,
    this.showActions = true,
  });

  @override
  Element createElement() => _DonorCardElement(this);
}

class _DonorCardElement extends ComponentElement {
  _DonorCardElement(DonorCard super.widget);

  @override
  DonorCard get widget => super.widget as DonorCard;

  @override
  Widget build() {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: الاسم وفصيلة الدم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.donor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // فصيلة الدم
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getBloodTypeColor(widget.donor.bloodType),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.donor.bloodType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // المعلومات الأساسية
              Row(
                children: [
                  // العمر
                  _InfoChip(
                    icon: Icons.cake_outlined,
                    label: '${widget.donor.age} سنة',
                  ),
                  const SizedBox(width: 8),
                  // الجنس
                  _InfoChip(
                    icon: widget.donor.gender == 'male'
                        ? Icons.male
                        : Icons.female,
                    label: Helpers.genderToArabic(widget.donor.gender),
                  ),
                  const SizedBox(width: 8),
                  // المديرية
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: widget.donor.district,
                  ),
                ],
              ),
              
              // الملاحظات (إذا وُجدت)
              if (widget.donor.notes != null && widget.donor.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.donor.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // أزرار الإجراءات
              if (widget.showActions) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // عرض جميع الأرقام مع أزرار الاتصال
                ...widget.donor.allPhoneNumbers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final phone = entry.value;
                  final label = index == 0 
                      ? 'رقم رئيسي' 
                      : 'رقم ${index + 1}';
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < widget.donor.allPhoneNumbers.length - 1 ? 8 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عرض الرقم مع التسمية
                        Row(
                          children: [
                            Icon(
                              index == 0 ? Icons.phone : Icons.phone_android,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$label: ${Helpers.displayPhoneNumber(phone)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // أزرار الإجراءات لهذا الرقم
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _makeCall(phone),
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text(AppStrings.call, style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openWhatsApp(phone),
                                icon: const Icon(Icons.message, size: 16),
                                label: const Text(AppStrings.whatsapp, style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A')) return AppColors.bloodTypeA;
    if (bloodType.contains('B')) return AppColors.bloodTypeB;
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }

  void _makeCall(String phoneNumber) {
    Helpers.makePhoneCall(phoneNumber);
  }

  void _openWhatsApp(String phoneNumber) {
    Helpers.openWhatsApp(
      phoneNumber,
      message: AppStrings.whatsappDefaultMessage,
    );
  }
}

/// شريحة معلومات صغيرة
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
      ),
    );
  }
}

