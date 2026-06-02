import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

import '../../constants/app_colors.dart';
import '../../models/banner_model.dart';
import '../../providers/banner_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_text_field.dart';

/// شاشة إدارة البانرات (للأدمن)
class ManageBannersScreen extends StatefulWidget {
  const ManageBannersScreen({super.key});

  @override
  State<ManageBannersScreen> createState() => _ManageBannersScreenState();
}

class _ManageBannersScreenState extends State<ManageBannersScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // تحميل البانرات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().loadAllBanners();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteBanner(BannerModel banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف البانر'),
        content: Text('هل تريد حذف البانر "${banner.title}" نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (!mounted) return;
        await context.read<BannerProvider>().deleteBanner(banner.id, banner.imagePath);
        _showSuccess('تم حذف البانر بنجاح');
      } catch (e) {
        _showError('فشل حذف البانر: $e');
      }
    }
  }

  Future<void> _toggleStatus(BannerModel banner, bool value) async {
    try {
      await context.read<BannerProvider>().toggleBannerStatus(banner.id, value);
      _showSuccess(value ? 'تم تفعيل البانر' : 'تم إيقاف البانر');
    } catch (e) {
      _showError('فشل تغيير حالة البانر: $e');
    }
  }

  Future<void> _moveBanner(int index, int direction) async {
    final provider = context.read<BannerProvider>();
    final banners = List<BannerModel>.from(provider.allBanners);
    
    if (index + direction < 0 || index + direction >= banners.length) return;

    // تبديل البانرات
    final temp = banners[index];
    banners[index] = banners[index + direction];
    banners[index + direction] = temp;

    try {
      final ids = banners.map((b) => b.id).toList();
      await provider.reorderBanners(ids);
      _showSuccess('تم تحديث الترتيب');
    } catch (e) {
      _showError('فشل إعادة الترتيب: $e');
    }
  }

  void _openBannerForm([BannerModel? banner]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BannerFormSheet(
        banner: banner,
        picker: _picker,
        onSuccess: (msg) {
          Navigator.pop(context);
          _showSuccess(msg);
        },
        onError: (msg) {
          _showError(msg);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة البانرات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة بانر',
            onPressed: () => _openBannerForm(),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<BannerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allBanners.isEmpty) {
            return const LoadingWidget(message: 'جاري تحميل البانرات...');
          }

          if (provider.allBanners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا يوجد بانرات حالياً',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'أضف بانرات إعلانية وتوعوية لتظهر في الرئيسية',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openBannerForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة البانر الأول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllBanners(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // صندوق الإرشادات
                Card(
                  elevation: 0,
                  color: AppColors.info.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info),
                            SizedBox(width: 8),
                            Text(
                              'إرشادات صور البانرات:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• الأبعاد المثالية: 1200 × 600 بكسل (نسبة 2:1).\n'
                          '• الحجم الأقصى للصورة: 2 ميجابايت.\n'
                          '• الصيغ المدعومة: PNG, JPG, WebP.\n'
                          '• الترتيب: اسحب أو استخدم الأسهم لتغيير ترتيب العرض في الرئيسية.',
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // قائمة البانرات
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.allBanners.length,
                  itemBuilder: (context, index) {
                    final banner = provider.allBanners[index];
                    return _buildBannerCard(banner, index, provider.allBanners.length);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner, int index, int totalCount) {
    final dateFormat = intl.DateFormat('yyyy/MM/dd');
    String dateRange = 'دائم';
    if (banner.startsAt != null || banner.endsAt != null) {
      final start = banner.startsAt != null ? dateFormat.format(banner.startsAt!) : 'البداية';
      final end = banner.endsAt != null ? dateFormat.format(banner.endsAt!) : 'النهاية';
      dateRange = '$start - $end';
    }

    String actionDesc = 'بدون إجراء';
    if (banner.actionType == 'internal_route') {
      actionDesc = 'شاشة: ${_getRouteNameAr(banner.actionValue)}';
    } else if (banner.actionType == 'external_url') {
      actionDesc = 'رابط: ${banner.actionValue}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معاينة الصورة
          Stack(
            children: [
              Image.network(
                banner.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: AppColors.divider,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 50, color: AppColors.textHint),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    color: AppColors.divider,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الترتيب: ${banner.sortOrder + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (!banner.isCurrentlyVisible && banner.isActive)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'خارج النطاق الزمني',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        banner.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Switch(
                      value: banner.isActive,
                      activeColor: AppColors.success,
                      onChanged: (val) => _toggleStatus(banner, val),
                    ),
                  ],
                ),
                if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      actionDesc,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // إعادة الترتيب
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      tooltip: 'نقل لأعلى',
                      onPressed: index > 0 ? () => _moveBanner(index, -1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      tooltip: 'نقل لأسفل',
                      onPressed: index < totalCount - 1 ? () => _moveBanner(index, 1) : null,
                    ),
                    const Spacer(),
                    // تعديل وحذف
                    TextButton.icon(
                      onPressed: () => _openBannerForm(banner),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('تعديل'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteBanner(banner),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('حذف'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRouteNameAr(String? route) {
    switch (route) {
      case '/donor/search':
        return 'البحث عن متبرع';
      case '/donor/add':
        return 'تسجيل متبرع جديد';
      case '/awareness':
        return 'التثقيف الصحي';
      case '/report_donor':
        return 'البلاغات والتقارير';
      case '/info/about':
        return 'حول التطبيق';
      case '/info/contact':
        return 'اتصل بنا';
      default:
        return route ?? 'غير معروف';
    }
  }
}

/// ويدجت النموذج لإضافة وتعديل البانر
class BannerFormSheet extends StatefulWidget {
  final BannerModel? banner;
  final ImagePicker picker;
  final Function(String) onSuccess;
  final Function(String) onError;

  const BannerFormSheet({
    super.key,
    this.banner,
    required this.picker,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<BannerFormSheet> createState() => _BannerFormSheetState();
}

class _BannerFormSheetState extends State<BannerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _actionValueController;

  String _actionType = 'none';
  bool _isActive = true;
  DateTime? _startsAt;
  DateTime? _endsAt;

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  final List<Map<String, String>> _internalRoutes = [
    {'value': '/donor/search', 'label': 'البحث عن متبرعين'},
    {'value': '/donor/add', 'label': 'إضافة متبرع جديد'},
    {'value': '/awareness', 'label': 'قسم التوعية والتثقيف'},
    {'value': '/report_donor', 'label': 'الإبلاغ عن متبرع'},
    {'value': '/info/about', 'label': 'حول التطبيق'},
    {'value': '/info/contact', 'label': 'تواصل معنا'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title);
    _subtitleController = TextEditingController(text: widget.banner?.subtitle);
    
    _actionType = widget.banner?.actionType ?? 'none';
    
    // إذا كان الإجراء رابط خارجي، نعبئ الحقل بالنص المباشر
    _actionValueController = TextEditingController(
      text: _actionType == 'external_url' ? widget.banner?.actionValue : '',
    );

    // إذا كان الإجراء شاشة داخلية، نتحقق ونحفظ القيمة الافتراضية
    if (_actionType == 'internal_route') {
      _actionValueController.text = widget.banner?.actionValue ?? '/donor/search';
    }

    _isActive = widget.banner?.isActive ?? true;
    _startsAt = widget.banner?.startsAt;
    _endsAt = widget.banner?.endsAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _actionValueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await widget.picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        // التحقق من حجم الملف (الحد الأقصى 2 ميجابايت)
        final bytes = await image.readAsBytes();
        if (bytes.lengthInBytes > 2 * 1024 * 1024) {
          widget.onError('حجم الصورة كبير جداً! يجب أن لا يتجاوز 2 ميجابايت.');
          return;
        }

        setState(() {
          _imageBytes = bytes;
          _imageName = image.name;
        });
      }
    } catch (e) {
      widget.onError('فشل اختيار الصورة: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initial = isStart 
        ? (_startsAt ?? now) 
        : (_endsAt ?? (_startsAt ?? now).add(const Duration(days: 7)));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startsAt = picked;
          // التحقق من تعارض التواريخ
          if (_endsAt != null && _startsAt!.isAfter(_endsAt!)) {
            _endsAt = _startsAt!.add(const Duration(days: 1));
          }
        } else {
          _endsAt = picked;
          if (_startsAt != null && _endsAt!.isBefore(_startsAt!)) {
            _startsAt = _endsAt!.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // التحقق من وجود الصورة في حال إضافة بانر جديد
    if (widget.banner == null && _imageBytes == null) {
      widget.onError('يرجى اختيار صورة للبانر أولاً');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<BannerProvider>();
      String imagePath = widget.banner?.imagePath ?? '';

      // 1. رفع الصورة الجديدة إن وُجدت
      if (_imageBytes != null && _imageName != null) {
        setState(() => _isUploadingImage = true);
        imagePath = await provider.uploadBannerImage(_imageName!, _imageBytes!);
        setState(() => _isUploadingImage = false);

        // حذف الصورة القديمة إذا كان تعديلاً
        if (widget.banner != null) {
          await provider.refreshActiveBannersSilently(); // تحديث صامت
        }
      }

      // القيمة الخاصة بالإجراء
      String? actionVal;
      if (_actionType != 'none') {
        actionVal = _actionValueController.text.trim();
        if (actionVal.isEmpty) {
          widget.onError('يرجى تحديد قيمة الإجراء');
          setState(() => _isSaving = false);
          return;
        }
      }

      // 2. الحفظ في قاعدة البيانات
      if (widget.banner == null) {
        // إضافة بانر جديد
        await provider.addBanner(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(),
          imagePath: imagePath,
          actionType: _actionType,
          actionValue: actionVal,
          sortOrder: provider.allBanners.length, // يضاف في النهاية
          isActive: _isActive,
          startsAt: _startsAt,
          endsAt: _endsAt,
        );
        widget.onSuccess('تم إضافة البانر بنجاح');
      } else {
        // تعديل بانر موجود
        await provider.updateBanner(
          id: widget.banner!.id,
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(),
          imagePath: imagePath,
          actionType: _actionType,
          actionValue: actionVal,
          sortOrder: widget.banner!.sortOrder,
          isActive: _isActive,
          startsAt: _startsAt,
          endsAt: _endsAt,
        );
        widget.onSuccess('تم تعديل البانر بنجاح');
      }
    } catch (e) {
      widget.onError('فشل حفظ البيانات: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final dateFormat = intl.DateFormat('yyyy/MM/dd');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الهيدر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.banner == null ? 'إضافة بانر جديد' : 'تعديل البانر',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // حقل العنوان
              CustomTextField(
                controller: _titleController,
                label: 'عنوان البانر *',
                hint: 'أدخل العنوان الرئيسي المعروض على البانر',
                icon: Icons.title,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'العنوان مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // حقل الوصف
              CustomTextField(
                controller: _subtitleController,
                label: 'الوصف أو النص المساعد (اختياري)',
                hint: 'نص إرشادي إضافي يظهر تحت العنوان',
                icon: Icons.subtitles,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // اختيار ومعاينة الصورة
              const Text(
                'صورة البانر *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isSaving ? null : _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.background,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imageBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                              ),
                            ),
                          ],
                        )
                      : widget.banner != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(widget.banner!.imageUrl, fit: BoxFit.cover),
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textHint),
                                SizedBox(height: 8),
                                Text(
                                  'اختر صورة من الاستوديو',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Text(
                                  'النسبة المفضلة 2:1 (مثل: 1200×600 بكسل)',
                                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),

              // نوع الإجراء عند الضغط
              const Text(
                'الإجراء عند الضغط على البانر:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('لا شيء', style: TextStyle(fontSize: 13)),
                      value: 'none',
                      groupValue: _actionType,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _actionType = val!;
                          _actionValueController.clear();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('فتح شاشة', style: TextStyle(fontSize: 13)),
                      value: 'internal_route',
                      groupValue: _actionType,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _actionType = val!;
                          _actionValueController.text = '/donor/search';
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('رابط خارجي', style: TextStyle(fontSize: 13)),
                      value: 'external_url',
                      groupValue: _actionType,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _actionType = val!;
                          _actionValueController.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              // تفاصيل الإجراء بناءً على النوع
              if (_actionType == 'internal_route') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _actionValueController.text.isEmpty ? '/donor/search' : _actionValueController.text,
                  decoration: InputDecoration(
                    labelText: 'اختر الشاشة المراد فتحها',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: _internalRoutes.map((route) {
                    return DropdownMenuItem<String>(
                      value: route['value'],
                      child: Text(route['label']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _actionValueController.text = val;
                    }
                  },
                ),
              ] else if (_actionType == 'external_url') ...[
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _actionValueController,
                  label: 'الرابط الخارجي (URL) *',
                  hint: 'https://example.com',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  validator: (val) {
                    if (_actionType == 'external_url' && (val == null || val.trim().isEmpty)) {
                      return 'الرابط مطلوب';
                    }
                    if (val != null && val.isNotEmpty && !val.startsWith('http')) {
                      return 'يجب أن يبدأ الرابط بـ http:// أو https://';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),

              // جدولة زمنية
              const Text(
                'جدولة العرض (اختياري):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, true),
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        _startsAt == null ? 'تاريخ البدء' : dateFormat.format(_startsAt!),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, false),
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        _endsAt == null ? 'تاريخ الانتهاء' : dateFormat.format(_endsAt!),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_startsAt != null || _endsAt != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.error),
                      tooltip: 'إزالة الجدولة',
                      onPressed: () {
                        setState(() {
                          _startsAt = null;
                          _endsAt = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // حالة البانر (نشط/معطل)
              SwitchListTile(
                title: const Text('البانر نشط للعرض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('إذا كان معطلاً لن يظهر للمستخدمين حتى لو كان ضمن الجدولة', style: TextStyle(fontSize: 12)),
                value: _isActive,
                activeColor: AppColors.success,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() => _isActive = val);
                },
              ),
              const SizedBox(height: 24),

              // أزرار الحفظ والإلغاء
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                                const SizedBox(width: 10),
                                Text(_isUploadingImage ? 'جاري رفع الصورة...' : 'جاري الحفظ...'),
                              ],
                            )
                          : const Text('حفظ البانر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
