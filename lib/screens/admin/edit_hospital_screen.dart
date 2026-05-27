import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/hospital_model.dart';
import '../../services/hospital_service.dart';
import '../../utils/validators.dart';
import '../../utils/error_handler.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';

/// شاشة تعديل مستشفى
class EditHospitalScreen extends StatefulWidget {
  final HospitalModel hospital;

  const EditHospitalScreen({super.key, required this.hospital});

  @override
  State<EditHospitalScreen> createState() => _EditHospitalScreenState();
}

class _EditHospitalScreenState extends State<EditHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalService = HospitalService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  String? _selectedDistrict;

  bool _isLoading = false;
  bool _obscurePassword = false;
  bool _changePassword = false;

  // قائمة المحافظات
  final List<String> _districts = AppStrings.districts;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hospital.name);
    _emailController = TextEditingController(text: widget.hospital.email);
    _phoneController = TextEditingController(text: widget.hospital.phoneNumber);
    _passwordController = TextEditingController();
    _selectedDistrict = widget.hospital.district;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateHospital() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المديرية'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedHospital = widget.hospital.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        district: _selectedDistrict!,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      await _hospitalService.updateHospital(updatedHospital);

      // تحديث كلمة المرور إذا تم تغييرها
      if (_changePassword && _passwordController.text.trim().isNotEmpty) {
        // TODO: إضافة دالة تحديث كلمة المرور في HospitalService
        // await _hospitalService.updatePassword(widget.hospital.id, _passwordController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات المستشفى بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث البيانات: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل مستشفى'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // كارد معلومات المستشفى
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تعديل بيانات المستشفى',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.hospital.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // اسم المستشفى
                  CustomTextField(
                    controller: _nameController,
                    label: 'اسم المستشفى',
                    hint: 'أدخل اسم المستشفى',
                    icon: Icons.local_hospital,
                    validator: Validators.validateName,
                  ),

                  const SizedBox(height: 16),

                  // البريد الإلكتروني (قابل للتعديل)
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل البريد الإلكتروني',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),

                  const SizedBox(height: 16),

                  // المديرية
                  CustomDropdown(
                    label: 'المديرية',
                    hint: 'اختر المديرية',
                    value: _selectedDistrict,
                    items: _districts,
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                    icon: Icons.location_on,
                  ),

                  const SizedBox(height: 16),

                  // رقم الهاتف (اختياري)
                  CustomTextField(
                    controller: _phoneController,
                    label: '${AppStrings.phoneNumber} (${AppStrings.optional})',
                    hint: '777123456',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 24),

                  // قسم كلمة المرور
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تغيير كلمة المرور',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _changePassword,
                          onChanged: (value) {
                            setState(() {
                              _changePassword = value ?? false;
                              if (!_changePassword) {
                                _passwordController.clear();
                              }
                            });
                          },
                          title: const Text('تغيير كلمة المرور'),
                          subtitle: const Text(
                            'قم بتفعيل هذا الخيار لتعيين كلمة مرور جديدة',
                            style: TextStyle(fontSize: 12),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_changePassword) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور الجديدة',
                              hintText: 'أدخل كلمة المرور الجديدة',
                              prefixIcon: const Icon(Icons.vpn_key),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // زر إظهار/إخفاء
                                  IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    tooltip: _obscurePassword
                                        ? 'إظهار'
                                        : 'إخفاء',
                                  ),
                                  // زر النسخ
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      if (_passwordController.text.isNotEmpty) {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: _passwordController.text,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('تم نسخ كلمة المرور'),
                                            backgroundColor: AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    tooltip: 'نسخ',
                                  ),
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: _changePassword
                                ? (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'كلمة المرور مطلوبة';
                                    }
                                    if (value.length < 6) {
                                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ملاحظة: كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر التحديث
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateHospital,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تحديث البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ملاحظة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'صلاحيات الأدمن: يمكنك تعديل جميع بيانات المستشفى بما في ذلك البريد الإلكتروني وكلمة المرور.',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(message: 'جاري تحديث البيانات...'),
              ),
            ),
        ],
      ),
    );
  }
}
