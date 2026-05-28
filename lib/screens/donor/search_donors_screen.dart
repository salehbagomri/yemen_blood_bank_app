import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/expandable_donor_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';

/// صفحة البحث عن المتبرعين
class SearchDonorsScreen extends StatefulWidget {
  const SearchDonorsScreen({super.key});

  @override
  State<SearchDonorsScreen> createState() => _SearchDonorsScreenState();
}

class _SearchDonorsScreenState extends State<SearchDonorsScreen>
    with SingleTickerProviderStateMixin {
  // حالة البحث
  String? _selectedBloodType;
  String? _selectedGovernorate;
  String? _selectedSubDistrict;
  List<String> _subDistricts = [];
  String? _selectedGender;
  String _sortBy = 'name'; // name | district | blood_type
  bool _hasSearched = false;

  // فصائل الدم الـ 8
  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // ألوان فصائل الدم
  static const Map<String, Color> _bloodTypeColors = {
    'A+': Color(0xFFE53935),
    'A-': Color(0xFFEF5350),
    'B+': Color(0xFF1E88E5),
    'B-': Color(0xFF42A5F5),
    'AB+': Color(0xFF8E24AA),
    'AB-': Color(0xFFAB47BC),
    'O+': Color(0xFF43A047),
    'O-': Color(0xFF66BB6A),
  };

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ==================== منطق البحث ====================

  /// تنفيذ البحث تلقائياً عند تغيير أي فلتر
  void _performSearch() {
    if (_selectedBloodType == null && _selectedGovernorate == null) {
      // لا يوجد معيار بحث — امسح النتائج
      setState(() => _hasSearched = false);
      context.read<DonorProvider>().clearSearchResults();
      return;
    }

    setState(() => _hasSearched = true);
    
    // إنشاء نص الفرز الجغرافي
    final searchQueryLocation = _selectedGovernorate != null
        ? (_selectedSubDistrict != null ? '$_selectedGovernorate - $_selectedSubDistrict' : _selectedGovernorate)
        : null;

    context.read<DonorProvider>().searchDonors(
      bloodType: _selectedBloodType,
      district: searchQueryLocation,
      availableOnly: true, // دائماً يُظهر المتاحين فقط
    );
    _animController
      ..reset()
      ..forward();
  }

  /// اختيار فصيلة الدم (ضغطة واحدة)
  void _onBloodTypeChipTap(String bloodType) {
    setState(() {
      _selectedBloodType = _selectedBloodType == bloodType ? null : bloodType;
    });
    _performSearch();
  }



  /// مسح كل شيء
  void _clearAll() {
    setState(() {
      _selectedBloodType = null;
      _selectedGovernorate = null;
      _selectedSubDistrict = null;
      _subDistricts = [];
      _selectedGender = null;
      _sortBy = 'name';
      _hasSearched = false;
    });
    context.read<DonorProvider>().clearSearchResults();
  }

  // ==================== الفلترة المحلية ====================

  List _filteredResults(List donors) {
    var list = List.from(donors);
    if (_selectedGender != null) {
      list = list.where((d) => d.gender == _selectedGender).toList();
    }
    switch (_sortBy) {
      case 'district':
        list.sort((a, b) => a.district.compareTo(b.district));
        break;
      case 'blood_type':
        list.sort((a, b) => a.bloodType.compareTo(b.bloodType));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.searchForDonors),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'مسح الكل',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // ==================== قسم الفلاتر ====================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- 1. المحافظة ----
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
                    _performSearch();
                  },
                ),

                const SizedBox(height: 14),

                // ---- 2. المديرية ----
                CustomDropdown(
                  value: _selectedSubDistrict,
                  items: _subDistricts,
                  hint: _selectedGovernorate == null
                      ? 'اختر المحافظة أولاً'
                      : 'اختر المديرية (اختياري)',
                  label: 'المديرية',
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubDistrict = value;
                    });
                    _performSearch();
                  },
                ),

                const SizedBox(height: 14),

                // ---- 2. فصيلة الدم ----
                Row(
                  children: [
                    const Icon(
                      Icons.bloodtype,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'فصيلة الدم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    if (_selectedBloodType != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _onBloodTypeChipTap(_selectedBloodType!),
                        child: Text(
                          'مسح',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // ---- الـ 8 Chips لفصائل الدم ----
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _bloodTypes.map((bt) {
                    final isSelected = _selectedBloodType == bt;
                    final color = _bloodTypeColors[bt] ?? AppColors.primary;
                    return GestureDetector(
                      onTap: () => _onBloodTypeChipTap(bt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          bt,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // ---- 3. فلاتر إضافية (جنس + ترتيب) ----
                _buildAdvancedFilters(),
              ],
            ),
          ),

          // ==================== النتائج ====================
          Expanded(
            child: Consumer<DonorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const DonorListShimmer(count: 5);
                }

                if (provider.hasError && _hasSearched) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'حدث خطأ',
                    message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
                    actionLabel: 'إعادة المحاولة',
                    onAction: _performSearch,
                  );
                }

                if (!_hasSearched) {
                  return _buildInitialHint();
                }

                final raw = provider.searchResults;
                final results = _filteredResults(raw);

                if (results.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: AppStrings.noDonorsFound,
                    message: AppStrings.noDonorsMessage,
                    actionLabel: 'مسح البحث',
                    onAction: _clearAll,
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      _buildResultsHeader(results.length),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: results.length,
                          itemBuilder: (context, index) => ExpandableDonorCard(
                            donor: results[index],
                            showManagementActions: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Widgets مساعدة ====================

  /// فلاتر إضافية قابلة للطي (جنس + ترتيب فقط)
  Widget _buildAdvancedFilters() {
    return ExpansionTile(
      key: const Key('advanced_filters'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Row(
        children: [
          Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'فلاتر إضافية',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedGender != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      children: [
        const SizedBox(height: 4),

        // جنس + ترتيب في صف واحد
        Row(
          children: [
            // فلتر الجنس
            Expanded(
              child: _buildSegmentedControl(
                label: 'الجنس',
                icon: Icons.wc,
                options: const {'الكل': null, 'ذكر': 'male', 'أنثى': 'female'},
                selected: _selectedGender,
                onSelect: (v) {
                  setState(() => _selectedGender = v);
                },
              ),
            ),
            const SizedBox(width: 12),
            // ترتيب النتائج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'الترتيب',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('الاسم')),
                      DropdownMenuItem(
                        value: 'district',
                        child: Text('المديرية'),
                      ),
                      DropdownMenuItem(
                        value: 'blood_type',
                        child: Text('الفصيلة'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Segmented control بسيط للجنس
  Widget _buildSegmentedControl({
    required String label,
    required IconData icon,
    required Map<String, String?> options,
    required String? selected,
    required Function(String?) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: options.entries.map((e) {
              final isActive = e.value == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(isActive ? null : e.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      e.key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// رأس النتائج
  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 5),
                Text(
                  '$count متبرع',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // مؤشر الأوفلاين
          Consumer<DonorProvider>(
            builder: (_, p, __) => p.isOffline
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'بيانات محفوظة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// الشاشة الأولية (قبل أي بحث)
  Widget _buildInitialHint() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.manage_search,
            size: 72,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث عن متبرع',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر المديرية أو فصيلة الدم للبحث\nالنتائج تظهر تلقائياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildTip(Icons.location_on, 'اختر المديرية للبحث بالموقع'),
          const SizedBox(height: 10),
          _buildTip(Icons.touch_app, 'اضغط فصيلة الدم للبحث الفوري'),
          const SizedBox(height: 10),
          _buildTip(Icons.tune, 'استخدم الفلاتر الإضافية للتخصيص'),
          const SizedBox(height: 10),
          _buildTip(Icons.wifi_off, 'يعمل بدون إنترنت بالبيانات المحفوظة'),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
