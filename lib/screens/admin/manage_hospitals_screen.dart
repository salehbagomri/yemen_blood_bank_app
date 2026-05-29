import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/hospital_model.dart';
import '../../services/hospital_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/error_handler.dart';
import '../../config/app_router.dart';
import 'widgets/enhanced_hospital_card.dart';

/// شاشة إدارة المستشفيات المحسّنة
class ManageHospitalsScreen extends StatefulWidget {
  const ManageHospitalsScreen({super.key});

  @override
  State<ManageHospitalsScreen> createState() => _ManageHospitalsScreenState();
}

class _ManageHospitalsScreenState extends State<ManageHospitalsScreen> {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();

  List<HospitalModel> _hospitals = [];
  List<HospitalModel> _filteredHospitals = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive
  String _sortBy = 'name'; // name, date, district

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadHospitals());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hospitals = await _hospitalService.getAllHospitals();
      setState(() {
        _hospitals = hospitals;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getArabicMessage(e);
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    // تطبيق الفلتر
    _filteredHospitals = _hospitals.where((hospital) {
      // فلتر البحث
      final matchesSearch =
          _searchQuery.isEmpty ||
          hospital.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hospital.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hospital.district.toLowerCase().contains(_searchQuery.toLowerCase());

      // فلتر الحالة
      final matchesStatus =
          _filterStatus == 'all' ||
          (_filterStatus == 'active' && hospital.isActive) ||
          (_filterStatus == 'inactive' && !hospital.isActive);

      return matchesSearch && matchesStatus;
    }).toList();

    // تطبيق الترتيب
    _filteredHospitals.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'date':
          return b.createdAt.compareTo(a.createdAt);
        case 'district':
          return a.district.compareTo(b.district);
        default:
          return 0;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSort();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterStatus = filter;
      _applyFiltersAndSort();
    });
  }

  void _onSortChanged(String sort) {
    setState(() {
      _sortBy = sort;
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddHospital,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مستشفى'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('إدارة المستشفيات'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل المستشفيات...');
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        message: _errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadHospitals,
      );
    }

    if (_hospitals.isEmpty) {
      return EmptyState(
        icon: Icons.local_hospital,
        title: 'لا توجد مستشفيات',
        message: 'لم يتم إضافة أي مستشفى بعد',
        actionLabel: 'إضافة مستشفى',
        onAction: _navigateToAddHospital,
      );
    }

    return Column(
      children: [
        // إحصائيات سريعة
        _buildQuickStats(),

        // شريط البحث والفلاتر
        _buildSearchAndFilters(),

        // قائمة المستشفيات
        Expanded(child: _buildHospitalsList()),
      ],
    );
  }

  Widget _buildQuickStats() {
    final activeCount = _hospitals.where((h) => h.isActive).length;
    final inactiveCount = _hospitals.length - activeCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryDark.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'الإجمالي',
            '${_hospitals.length}',
            Icons.local_hospital,
            AppColors.primary,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            'نشط',
            '$activeCount',
            Icons.check_circle,
            AppColors.success,
          ),
          const SizedBox(width: 20),
          _buildStatItem(
            'معطل',
            '$inactiveCount',
            Icons.cancel,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'بحث عن مستشفى...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // الفلاتر
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown('الحالة', _filterStatus, {
                  'all': 'الكل',
                  'active': 'نشط',
                  'inactive': 'معطل',
                }, _onFilterChanged),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown('الترتيب', _sortBy, {
                  'name': 'الاسم',
                  'date': 'التاريخ',
                  'district': 'المديرية',
                }, _onSortChanged),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // عدد النتائج
          if (_filteredHospitals.length != _hospitals.length)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_list, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(
                    'عرض ${_filteredHospitals.length} من ${_hospitals.length} مستشفى',
                    style: TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    Map<String, String> options,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: options.entries
          .map(
            (entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  Widget _buildHospitalsList() {
    if (_filteredHospitals.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'لا توجد نتائج',
        message: 'لم يتم العثور على مستشفيات تطابق البحث',
        actionLabel: 'مسح البحث',
        onAction: () {
          _searchController.clear();
          _onSearchChanged('');
          _onFilterChanged('all');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHospitals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredHospitals.length,
        itemBuilder: (context, index) {
          final hospital = _filteredHospitals[index];
          return EnhancedHospitalCard(
            hospital: hospital,
            onTap: () => _showHospitalDetails(hospital),
            onToggleStatus: () => _toggleHospitalStatus(hospital),
            onEdit: () => _editHospital(hospital),
            onDelete: () => _deleteHospital(hospital),
          );
        },
      ),
    );
  }

  void _navigateToAddHospital() {
    Navigator.of(context).pushNamed(AppRouter.adminAddHospital).then((result) {
      if (result == true) {
        _loadHospitals();
      }
    });
  }

  void _showHospitalDetails(HospitalModel hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            _buildHospitalDetailsSheet(hospital, scrollController),
      ),
    );
  }

  Widget _buildHospitalDetailsSheet(
    HospitalModel hospital,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // العنوان
          Text(
            'تفاصيل المستشفى',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // البطاقة
          EnhancedHospitalCard(
            hospital: hospital,
            onTap: () {},
            onToggleStatus: () {
              Navigator.pop(context);
              _toggleHospitalStatus(hospital);
            },
            onEdit: () {
              Navigator.pop(context);
              _editHospital(hospital);
            },
            onDelete: () {
              Navigator.pop(context);
              _deleteHospital(hospital);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHospitalStatus(HospitalModel hospital) async {
    try {
      await _hospitalService.toggleHospitalStatus(
        hospital.id,
        !hospital.isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hospital.isActive ? 'تم تعطيل المستشفى' : 'تم تفعيل المستشفى',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadHospitals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تحديث حالة المستشفى: ${ErrorHandler.getArabicMessage(e)}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _editHospital(HospitalModel hospital) {
    Navigator.of(context)
        .pushNamed(AppRouter.adminEditHospital, arguments: hospital)
        .then((result) {
          if (result == true) {
            _loadHospitals();
          }
        });
  }

  Future<void> _deleteHospital(HospitalModel hospital) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف ${hospital.name}؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _hospitalService.deleteHospital(hospital.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المستشفى بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadHospitals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل حذف المستشفى: ${ErrorHandler.getArabicMessage(e)}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
