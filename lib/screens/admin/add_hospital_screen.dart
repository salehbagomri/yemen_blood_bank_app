import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/validators.dart';
import '../../utils/error_handler.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';

/// شاشة إضافة مستشفى (للأدمن فقط)
class AddHospitalScreen extends StatefulWidget {
  const AddHospitalScreen({super.key});

  @override
  State<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends State<AddHospitalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  // Selected values
  String? _selectedDistrict;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مستشفى')),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري إنشاء حساب المستشفى...')
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
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم إنشاء حساب جديد للمستشفى في النظام',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // اسم المستشفى
                    CustomTextField(
                      controller: _nameController,
                      label: 'اسم المستشفى',
                      hint: 'مثال: مستشفى الجمهوري العام',
                      icon: Icons.local_hospital,
                      validator: (value) =>
                          Validators.validateNotEmpty(value, 'اسم المستشفى'),
                    ),

                    const SizedBox(height: 16),

                    // البريد الإلكتروني
                    CustomTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'hospital@example.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: 'أدخل كلمة مرور قوية (6 أحرف على الأقل)',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),

                    const SizedBox(height: 16),

                    // المديرية
                    CustomDropdown(
                      value: _selectedDistrict,
                      items: AppStrings.districts,
                      hint: 'اختر المديرية',
                      label: 'المديرية',
                      icon: Icons.location_city,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                      validator: (value) =>
                          Validators.validateNotEmpty(value, 'المديرية'),
                    ),

                    const SizedBox(height: 16),

                    // رقم الهاتف (اختياري)
                    CustomTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف (اختياري)',
                      hint: '771234567',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // العنوان (اختياري)
                    CustomTextField(
                      controller: _addressController,
                      label: 'العنوان (اختياري)',
                      hint: 'العنوان التفصيلي',
                      icon: Icons.location_on,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // تنبيه أمان
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'احفظ كلمة المرور وأرسلها للمستشفى بشكل آمن',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر الحفظ
                    ElevatedButton.icon(
                      onPressed: _addHospital,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة المستشفى'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addHospital() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // حفظ معرف الأدمن قبل signUp (مهم جداً!)
      final adminId = supabase.auth.currentUser!.id;

      // حفظ بيانات المستشفى للعرض لاحقاً
      final hospitalEmail = _emailController.text.trim();
      final hospitalPassword = _passwordController.text;
      final hospitalName = _nameController.text.trim();

      // 1. إنشاء المستخدم في Auth
      final authResponse = await supabase.auth.signUp(
        email: hospitalEmail,
        password: hospitalPassword,
        emailRedirectTo: null,
        data: {'role': 'hospital', 'name': hospitalName},
      );

      if (authResponse.user == null) {
        throw Exception('فشل إنشاء حساب المستخدم. تحقق من البريد الإلكتروني.');
      }

      final userId = authResponse.user!.id;

      // 2. إضافة بيانات المستشفى باستخدام دالة Postgres (تتجاوز RLS)
      await supabase.rpc(
        'add_hospital_bypassing_rls',
        params: {
          'p_admin_id': adminId,
          'p_hospital_id': userId,
          'p_name': hospitalName,
          'p_email': hospitalEmail,
          'p_district': _selectedDistrict!,
          'p_phone_number': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          'p_address': _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        },
      );

      // تسجيل خروج المستخدم الجديد
      await supabase.auth.signOut();

      if (mounted) {
        // عرض رسالة نجاح مع خيار نسخ البيانات
        await _showSuccessDialog(
          hospitalName: hospitalName,
          hospitalEmail: hospitalEmail,
          hospitalPassword: hospitalPassword,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        String errorMessage = 'فشل إضافة المستشفى';

        // تحليل الخطأ لإعطاء رسالة أوضح
        if (e is AuthException) {
          errorMessage = _getAuthErrorMessage(e);
        } else if (e is PostgrestException) {
          errorMessage = _getPostgrestErrorMessage(e);
        } else {
          final errorString = e.toString().toLowerCase();

          if (errorString.contains('email') &&
              errorString.contains('already')) {
            errorMessage = 'البريد الإلكتروني مسجل بالفعل';
          } else if (errorString.contains('400')) {
            errorMessage =
                'خطأ في البيانات المدخلة.\n'
                'تأكد من:\n'
                '• البريد الإلكتروني صحيح\n'
                '• كلمة المرور 6 أحرف على الأقل\n'
                '• لم يسبق تسجيل هذا البريد';
          } else if (errorString.contains('invalid')) {
            errorMessage = 'بيانات غير صحيحة. تحقق من البريد وكلمة المرور.';
          } else {
            errorMessage = 'فشل إضافة المستشفى:\n${ErrorHandler.getArabicMessage(e)}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'حسناً',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  /// عرض رسالة نجاح مع خيار نسخ البيانات
  Future<void> _showSuccessDialog({
    required String hospitalName,
    required String hospitalEmail,
    required String hospitalPassword,
  }) async {
    final credentials =
        'البريد: $hospitalEmail\nكلمة المرور: $hospitalPassword';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('تم بنجاح!', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تمت إضافة مستشفى "$hospitalName" بنجاح',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'بيانات تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    credentials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'سيتم تسجيل خروجك الآن. يرجى تسجيل الدخول مرة أخرى كمدير.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: credentials));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ البيانات'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('نسخ البيانات'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // العودة للصفحة الرئيسية
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  /// معالجة رسائل أخطاء Auth
  String _getAuthErrorMessage(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('email')) {
          return 'البريد الإلكتروني غير صحيح أو مسجل مسبقاً';
        }
        return 'خطأ في البيانات المدخلة. تحقق من البريد وكلمة المرور.';
      case '422':
        return 'البريد الإلكتروني مسجل بالفعل';
      default:
        return 'خطأ في المصادقة: ${e.message}';
    }
  }

  /// معالجة رسائل أخطاء Postgrest
  String _getPostgrestErrorMessage(PostgrestException e) {
    switch (e.code) {
      case '42501':
        return 'خطأ في الصلاحيات. يرجى المحاولة مرة أخرى.';
      case 'P0001':
        return e.message; // رسالة مخصصة من الدالة
      case '23505':
        return 'البريد الإلكتروني مسجل بالفعل';
      default:
        return 'خطأ في قاعدة البيانات: ${e.message}';
    }
  }
}
