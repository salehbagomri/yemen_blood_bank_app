import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../utils/validators.dart';
import '../../utils/error_handler.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';

/// شاشة تعديل بيانات المتبرع (للأدمن فقط)
class EditDonorScreen extends StatefulWidget {
  final DonorModel donor;

  const EditDonorScreen({
    super.key,
    required this.donor,
  });

  @override
  State<EditDonorScreen> createState() => _EditDonorScreenState();
}

class _EditDonorScreenState extends State<EditDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _phone2Controller;
  late final TextEditingController _phone3Controller;
  late final TextEditingController _ageController;
  late final TextEditingController _notesController;

  // Selected values
  late String _selectedBloodType;
  String? _selectedGovernorate;
  String? _selectedSubDistrict;
  List<String> _subDistricts = [];
  late String _selectedGender;

  // Blood types
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Genders
  final List<String> _genders = ['ذكر', 'أنثى'];

  @override
  void initState() {
    super.initState();

    // تهيئة الحقول بالبيانات الحالية
    _nameController = TextEditingController(text: widget.donor.name);
    _phoneController = TextEditingController(text: widget.donor.phoneNumber);
    _phone2Controller = TextEditingController(text: widget.donor.phoneNumber2 ?? '');
    _phone3Controller = TextEditingController(text: widget.donor.phoneNumber3 ?? '');
    _ageController = TextEditingController(text: widget.donor.age.toString());
    _notesController = TextEditingController(text: widget.donor.notes ?? '');

    _selectedBloodType = widget.donor.bloodType;
    final parts = widget.donor.district.split(' - ');
    _selectedGovernorate = parts[0];
    _selectedSubDistrict = parts.length > 1 ? parts[1] : null;
    _subDistricts = _selectedGovernorate != null
        ? (AppStrings.governorateDistricts[_selectedGovernorate] ?? [])
        : [];
    // تحويل من إنجليزي إلى عربي
    _selectedGender = widget.donor.gender == 'male' ? 'ذكر' : 'أنثى';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // التحقق من وجود تغييرات
    final newGenderEnglish = _selectedGender == 'ذكر' ? 'male' : 'female';
    final hasChanges = _nameController.text.trim() != widget.donor.name ||
        _phoneController.text.trim() != widget.donor.phoneNumber ||
        (_phone2Controller.text.trim().isEmpty ? null : _phone2Controller.text.trim()) !=
            widget.donor.phoneNumber2 ||
        (_phone3Controller.text.trim().isEmpty ? null : _phone3Controller.text.trim()) !=
            widget.donor.phoneNumber3 ||
        _selectedBloodType != widget.donor.bloodType ||
        '$_selectedGovernorate${_selectedSubDistrict != null ? ' - $_selectedSubDistrict' : ''}' != widget.donor.district ||
        int.parse(_ageController.text) != widget.donor.age ||
        newGenderEnglish != widget.donor.gender ||
        (_notesController.text.trim().isEmpty ? null : _notesController.text.trim()) !=
            widget.donor.notes;

    if (!hasChanges) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم إجراء أي تغييرات'),
            backgroundColor: AppColors.info,
          ),
        );
      }
      return;
    }

    // تأكيد الحفظ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التعديل'),
        content: Text(
          'هل تريد حفظ التعديلات على بيانات ${widget.donor.name}؟',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      // إنشاء نسخة محدثة من المتبرع
      final updatedDonor = widget.donor.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        phoneNumber2: _phone2Controller.text.trim().isEmpty
            ? null
            : _phone2Controller.text.trim(),
        phoneNumber3: _phone3Controller.text.trim().isEmpty
            ? null
            : _phone3Controller.text.trim(),
        bloodType: _selectedBloodType,
        district: '$_selectedGovernorate${_selectedSubDistrict != null ? ' - $_selectedSubDistrict' : ''}',
        age: int.parse(_ageController.text),
        gender: _selectedGender == 'ذكر' ? 'male' : 'female', // تحويل إلى إنجليزي
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // حفظ التعديلات
      final success = await context.read<DonorProvider>().updateDonor(updatedDonor);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم تحديث بيانات المتبرع بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true); // العودة مع نتيجة نجاح
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل تحديث البيانات'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المتبرع'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'حفظ التعديلات',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري حفظ التعديلات...')
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
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'قم بتعديل البيانات المطلوبة ثم اضغط حفظ. التعديلات ستظهر فوراً.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // الاسم
                    CustomTextField(
                      controller: _nameController,
                      label: AppStrings.donorName,
                      hint: 'أدخل الاسم الكامل',
                      icon: Icons.person,
                      validator: Validators.validateName,
                    ),

                    const SizedBox(height: 16),

                    // رقم الهاتف الرئيسي
                    CustomTextField(
                      controller: _phoneController,
                      label: '${AppStrings.phoneNumber} (رئيسي)',
                      hint: '777123456',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      validator: Validators.validatePhoneNumber,
                    ),

                    const SizedBox(height: 16),

                    // رقم الهاتف الإضافي 1
                    CustomTextField(
                      controller: _phone2Controller,
                      label: '${AppStrings.phoneNumber} 2 (${AppStrings.optional})',
                      hint: '777123456',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // رقم الهاتف الإضافي 2
                    CustomTextField(
                      controller: _phone3Controller,
                      label: '${AppStrings.phoneNumber} 3 (${AppStrings.optional})',
                      hint: '777123456',
                      icon: Icons.phone_iphone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // فصيلة الدم
                    CustomDropdown(
                      value: _selectedBloodType,
                      items: _bloodTypes,
                      hint: AppStrings.selectBloodType,
                      label: AppStrings.bloodType,
                      icon: Icons.bloodtype,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value!;
                        });
                      },
                      validator: (value) => Validators.validateNotEmpty(
                        value,
                        AppStrings.bloodType,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // المحافظة
                    CustomDropdown(
                      value: _selectedGovernorate,
                      items: AppStrings.districts,
                      hint: 'اختر المحافظة',
                      label: 'المحافظة',
                      icon: Icons.map,
                      onChanged: (value) {
                        setState(() {
                          _selectedGovernorate = value;
                          _selectedSubDistrict = null;
                          _subDistricts = value != null
                              ? (AppStrings.governorateDistricts[value] ?? [])
                              : [];
                        });
                      },
                      validator: (value) => Validators.validateNotEmpty(
                        value,
                        'المحافظة',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // المديرية
                    CustomDropdown(
                      value: _selectedSubDistrict,
                      items: _subDistricts,
                      hint: _selectedGovernorate == null
                          ? 'اختر المحافظة أولاً'
                          : 'اختر المديرية',
                      label: 'المديرية',
                      icon: Icons.location_on,
                      onChanged: (value) {
                        setState(() {
                          _selectedSubDistrict = value;
                        });
                      },
                      validator: (value) => Validators.validateNotEmpty(
                        value,
                        'المديرية',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // العمر
                    CustomTextField(
                      controller: _ageController,
                      label: AppStrings.age,
                      hint: 'مثال: 25',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: Validators.validateAge,
                    ),

                    const SizedBox(height: 16),

                    // الجنس
                    CustomDropdown(
                      value: _selectedGender,
                      items: _genders,
                      hint: 'اختر الجنس',
                      label: AppStrings.gender,
                      icon: Icons.wc,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      validator: (value) => Validators.validateNotEmpty(
                        value,
                        AppStrings.gender,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // الملاحظات
                    CustomTextField(
                      controller: _notesController,
                      label: '${AppStrings.notes} (${AppStrings.optional})',
                      hint: 'ملاحظات إضافية عن المتبرع...',
                      icon: Icons.note,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),

                    // زر الحفظ
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ التعديلات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // زر الإلغاء
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.error),
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
