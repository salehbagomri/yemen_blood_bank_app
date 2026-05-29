import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../config/app_router.dart';
import 'widgets/admin_donor_card.dart';

/// شاشة إدارة المتبرعين المحسّنة للأدمن - مطابقة لشاشة المستشفى
class ManageDonorsScreen extends StatefulWidget {
  const ManageDonorsScreen({super.key});

  @override
  State<ManageDonorsScreen> createState() => _ManageDonorsScreenState();
}

class _ManageDonorsScreenState extends State<ManageDonorsScreen> {
  final _searchController = TextEditingController();

  // الفلاتر
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  String? _selectedStatus; // 'all', 'available', 'suspended'
  String _sortBy = 'name'; // 'name', 'date', 'bloodType'

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DonorProvider>().loadDonors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageDonors),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // زر الفلاتر
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _hasActiveFilters() ? AppColors.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث (ثابت)
          _buildSearchBar(),

          // باقي المحتوى (قابل للتمرير)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // الفلاتر (قابلة للطي)
                  if (_showFilters) _buildFilters(),

                  // الإحصائيات السريعة
                  _buildQuickStats(),

                  // القائمة
                  _buildDonorsList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(AppRouter.addDonor)
              .then((_) => context.read<DonorProvider>().loadDonors());
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة متبرع'),
      ),
    );
  }

  /// شريط البحث المحسّن
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (query) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الفلاتر
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفلاتر',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_hasActiveFilters())
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('مسح الكل'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // فصيلة الدم
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'الكل',
                isSelected: _selectedBloodType == null,
                onTap: () => setState(() => _selectedBloodType = null),
              ),
              ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(
                (type) => _buildFilterChip(
                  label: type,
                  isSelected: _selectedBloodType == type,
                  color: _getBloodTypeColor(type),
                  onTap: () => setState(() => _selectedBloodType = type),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // المديرية والجنس والحالة
          Row(
            children: [
              // المديرية
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'المحافظة',
                    prefixIcon: const Icon(Icons.location_city, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...context.watch<LocationProvider>().activeGovernorates.map(
                      (d) => DropdownMenuItem(value: d, child: Text(d)),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedDistrict = value),
                ),
              ),
              const SizedBox(width: 8),

              // الجنس
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'الجنس',
                    prefixIcon: const Icon(Icons.person, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('الكل')),
                    DropdownMenuItem(value: 'male', child: Text('ذكر')),
                    DropdownMenuItem(value: 'female', child: Text('أنثى')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // الحالة والترتيب
          Row(
            children: [
              // الحالة
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus ?? 'all',
                  decoration: InputDecoration(
                    labelText: 'الحالة',
                    prefixIcon: const Icon(Icons.check_circle, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الكل')),
                    DropdownMenuItem(value: 'available', child: Text('متاح')),
                    DropdownMenuItem(value: 'suspended', child: Text('موقوف')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
              const SizedBox(width: 8),

              // الترتيب
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'ترتيب حسب',
                    prefixIcon: const Icon(Icons.sort, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('الاسم')),
                    DropdownMenuItem(value: 'date', child: Text('التاريخ')),
                    DropdownMenuItem(
                      value: 'bloodType',
                      child: Text('الفصيلة'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _sortBy = value ?? 'name'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// إحصائيات سريعة
  Widget _buildQuickStats() {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const SizedBox.shrink();

        final filteredDonors = _applyFilters(provider.donors);
        final availableCount = filteredDonors
            .where((d) => d.isActive && !d.isSuspended)
            .length;
        final suspendedCount = filteredDonors
            .where((d) => d.isActive && d.isSuspended)
            .length;
        final inactiveCount = filteredDonors.where((d) => !d.isActive).length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.people,
                label: 'الإجمالي',
                value: '${filteredDonors.length}',
                color: AppColors.primary,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'متاح',
                value: '$availableCount',
                color: AppColors.success,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _buildStatItem(
                icon: Icons.pause_circle,
                label: 'موقوف',
                value: '$suspendedCount',
                color: AppColors.warning,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _buildStatItem(
                icon: Icons.block,
                label: 'معطل',
                value: '$inactiveCount',
                color: AppColors.error,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// قائمة المتبرعين
  Widget _buildDonorsList() {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.donors.isEmpty) {
          return const LoadingWidget(message: 'جاري تحميل المتبرعين...');
        }

        if (provider.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'حدث خطأ',
            message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
            actionLabel: 'إعادة المحاولة',
            onAction: () => provider.loadDonors(),
          );
        }

        final filteredDonors = _applyFilters(provider.donors);

        if (filteredDonors.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            message: _hasActiveFilters() || _searchController.text.isNotEmpty
                ? 'لم يتم العثور على متبرعين بهذه المواصفات'
                : 'لم يتم إضافة أي متبرع بعد',
            actionLabel: _hasActiveFilters() ? 'مسح الفلاتر' : null,
            onAction: _hasActiveFilters() ? _clearFilters : null,
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredDonors.length,
          itemBuilder: (context, index) {
            final donor = filteredDonors[index];
            return AdminDonorCard(donor: donor);
          },
        );
      },
    );
  }

  /// chip الفلتر
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// تطبيق الفلاتر
  List<DonorModel> _applyFilters(List<DonorModel> donors) {
    var filtered = donors;

    // البحث النصي
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (d) =>
                d.name.toLowerCase().contains(query) ||
                d.phoneNumber.contains(query) ||
                (d.phoneNumber2?.contains(query) ?? false) ||
                (d.phoneNumber3?.contains(query) ?? false),
          )
          .toList();
    }

    // فصيلة الدم
    if (_selectedBloodType != null) {
      filtered = filtered
          .where((d) => d.bloodType == _selectedBloodType)
          .toList();
    }

    // المديرية
    if (_selectedDistrict != null) {
      filtered = filtered
          .where((d) => d.district == _selectedDistrict || d.district.startsWith('$_selectedDistrict - '))
          .toList();
    }

    // الجنس
    if (_selectedGender != null) {
      filtered = filtered.where((d) => d.gender == _selectedGender).toList();
    }

    // الحالة
    if (_selectedStatus != null && _selectedStatus != 'all') {
      if (_selectedStatus == 'available') {
        filtered = filtered.where((d) => !d.isSuspended).toList();
      } else if (_selectedStatus == 'suspended') {
        filtered = filtered.where((d) => d.isSuspended).toList();
      }
    }

    // الترتيب
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) {
          final dateA = a.lastDonationDate ?? DateTime(2000);
          final dateB = b.lastDonationDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case 'bloodType':
        filtered.sort((a, b) => a.bloodType.compareTo(b.bloodType));
        break;
    }

    return filtered;
  }

  /// التحقق من وجود فلاتر نشطة
  bool _hasActiveFilters() {
    return _selectedBloodType != null ||
        _selectedDistrict != null ||
        _selectedGender != null ||
        (_selectedStatus != null && _selectedStatus != 'all');
  }

  /// مسح جميع الفلاتر
  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _selectedStatus = 'all';
      _searchController.clear();
    });
  }

  /// لون فصيلة الدم
  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeA;
    }
    if (bloodType.contains('B') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeB;
    }
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}
