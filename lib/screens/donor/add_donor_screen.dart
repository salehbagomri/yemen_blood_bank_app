import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';

/// صفحة إضافة متبرع جديد
class AddDonorScreen extends StatefulWidget {
  const AddDonorScreen({super.key});

  @override
  State<AddDonorScreen> createState() => _AddDonorScreenState();
}

class _AddDonorScreenState extends State<AddDonorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _phone3Controller = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Selected values
  String? _selectedBloodType;
  String? _selectedGovernorate;
  String? _selectedSubDistrict;
  List<String> _subDistricts = [];
  String? _selectedGender;
  DateTime? _lastDonationDate; // تاريخ آخر تبرع (اختياري)
  
  // Blood types
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];
  
  // Genders
  final List<String> _genders = ['ذكر', 'أنثى'];

  // إذا كان المُضيف مستشفى، تُثبَّت المحافظة على محافظتها
  bool _governorateLocked = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final gov = auth.hospitalGovernorate;
    if (auth.isHospital && gov != null && gov.isNotEmpty) {
      _selectedGovernorate = gov;
      _subDistricts = AppStrings.governorateDistricts[gov] ?? [];
      _governorateLocked = true;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addDonor),
      ),
      body: Consumer<DonorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'جاري إضافة المتبرع...');
          }

          return SingleChildScrollView(
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
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'املأ جميع البيانات المطلوبة. سيظهر المتبرع فوراً في نتائج البحث.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.info,
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
                    prefixText: '+967 ',
                    helperText: 'أدخل 9 أرقام تبدأ بـ 7 (بدون 00967)',
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
                    prefixText: '+967 ',
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
                    prefixText: '+967 ',
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
                        _selectedBloodType = value;
                      });
                    },
                    validator: (value) => Validators.validateNotEmpty(
                      value,
                      AppStrings.bloodType,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // المحافظة (مثبّتة لحساب المستشفى على محافظته)
                  CustomDropdown(
                    value: _selectedGovernorate,
                    items: AppStrings.districts,
                    hint: 'اختر المحافظة',
                    label: _governorateLocked
                        ? 'المحافظة (محافظة مستشفاك)'
                        : 'المحافظة',
                    icon: Icons.map,
                    enabled: !_governorateLocked,
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
                  
                  // صف العمر والجنس
                  Row(
                    children: [
                      // العمر
                      Expanded(
                        child: CustomTextField(
                          controller: _ageController,
                          label: AppStrings.age,
                          hint: '25',
                          icon: Icons.cake,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: Validators.validateAge,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // الجنس
                      Expanded(
                        child: CustomDropdown(
                          value: _selectedGender,
                          items: _genders,
                          hint: 'اختر الجنس',
                          label: AppStrings.gender,
                          icon: Icons.people,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) => Validators.validateNotEmpty(
                            value,
                            AppStrings.gender,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // تاريخ آخر تبرع (اختياري)
                  GestureDetector(
                    onTap: _selectLastDonationDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'تاريخ آخر تبرع (${AppStrings.optional})',
                          hintText: 'اضغط لاختيار التاريخ',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                          ),
                          suffixIcon: _lastDonationDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _lastDonationDate = null;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.divider,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        controller: TextEditingController(
                          text: _lastDonationDate != null
                              ? DateFormat('yyyy-MM-dd').format(_lastDonationDate!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                  
                  // ملاحظة توضيحية
                  if (_lastDonationDate != null) ...[
                    const SizedBox(height: 8),
                    _buildDonationDateNote(),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // الملاحظات (اختياري)
                  CustomTextField(
                    controller: _notesController,
                    label: '${AppStrings.notes} (${AppStrings.optional})',
                    hint: 'أي ملاحظات إضافية',
                    icon: Icons.notes,
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // زر الحفظ
                  ElevatedButton.icon(
                    onPressed: _saveDonor,
                    icon: const Icon(Icons.save),
                    label: const Text(AppStrings.save),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// اختيار تاريخ آخر تبرع
  Future<void> _selectLastDonationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    if (picked != null) {
      setState(() {
        _lastDonationDate = picked;
      });
    }
  }

  /// ملاحظة توضيحية لتاريخ التبرع
  Widget _buildDonationDateNote() {
    if (_lastDonationDate == null) return const SizedBox.shrink();

    // حساب الفرق بين آخر تبرع والآن
    final now = DateTime.now();
    final sixMonthsFromDonation = _lastDonationDate!.add(
      const Duration(days: 180),
    );
    final daysSinceDonation = now.difference(_lastDonationDate!).inDays;
    final daysUntilAvailable = sixMonthsFromDonation.difference(now).inDays;

    // تحديد الحالة
    final bool willBeSuspended = daysUntilAvailable > 0;
    final Color noteColor = willBeSuspended ? AppColors.warning : AppColors.success;
    final IconData noteIcon = willBeSuspended ? Icons.pause_circle : Icons.check_circle;
    
    String noteText;
    if (willBeSuspended) {
      noteText = 'سيتم إيقاف المتبرع تلقائياً لمدة $daysUntilAvailable يوم (${(daysUntilAvailable / 30).round()} شهر تقريباً)';
    } else {
      noteText = 'المتبرع متاح للتبرع (مر ${(daysSinceDonation / 30).round()} شهر من آخر تبرع)';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: noteColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: noteColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(noteIcon, color: noteColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              noteText,
              style: TextStyle(
                color: noteColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// حفظ المتبرع
  Future<void> _saveDonor() async {
    // التحقق من صحة البيانات
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // تنسيق أرقام الهواتف
    final formattedPhone = Helpers.formatPhoneNumber(_phoneController.text);
    final formattedPhone2 = _phone2Controller.text.trim().isEmpty
        ? null
        : Helpers.formatPhoneNumber(_phone2Controller.text);
    final formattedPhone3 = _phone3Controller.text.trim().isEmpty
        ? null
        : Helpers.formatPhoneNumber(_phone3Controller.text);

    // حساب حالة الإيقاف بناءً على تاريخ آخر تبرع
    DateTime? suspendedUntil;
    bool isAvailable = true;
    
    if (_lastDonationDate != null) {
      final sixMonthsFromDonation = _lastDonationDate!.add(
        const Duration(days: 180),
      );
      final now = DateTime.now();
      
      // إذا لم تمر 6 أشهر بعد، يكون المتبرع موقوفاً
      if (now.isBefore(sixMonthsFromDonation)) {
        suspendedUntil = sixMonthsFromDonation;
        isAvailable = false; // غير متاح لأنه موقوف
      }
    }

    // إنشاء كائن المتبرع
    final donor = DonorModel(
      id: '', // سيتم إنشاؤه تلقائياً في قاعدة البيانات
      name: _nameController.text.trim(),
      phoneNumber: formattedPhone,
      phoneNumber2: formattedPhone2,
      phoneNumber3: formattedPhone3,
      bloodType: _selectedBloodType!,
      district: '$_selectedGovernorate${_selectedSubDistrict != null ? ' - $_selectedSubDistrict' : ''}',
      age: int.parse(_ageController.text),
      gender: Helpers.arabicToGender(_selectedGender!),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      lastDonationDate: _lastDonationDate,
      suspendedUntil: suspendedUntil,
      isAvailable: isAvailable,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // حفظ المتبرع
    final success = await context.read<DonorProvider>().addDonor(donor);

    if (!mounted) return;

    if (success) {
      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            donor.isSuspended
                ? 'تم إضافة المتبرع بنجاح (موقوف حتى ${DateFormat('yyyy-MM-dd').format(donor.suspendedUntil!)})'
                : AppStrings.donorAddedSuccessfully,
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );

      // العودة للصفحة السابقة
      Navigator.of(context).pop();
    } else {
      // عرض رسالة خطأ
      final errorMessage = context.read<DonorProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? AppStrings.errorOccurred),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

