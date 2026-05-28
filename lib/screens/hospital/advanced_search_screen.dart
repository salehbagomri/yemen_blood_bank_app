import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/donor_card.dart';
import '../../utils/error_handler.dart';

/// شاشة البحث المتقدم للمستشفى
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  bool _includeAvailable = true;
  bool _includeSuspended = false;
  
  List<DonorModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.advancedSearch),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // الفلاتر
          _buildFilters(),
          
          // النتائج
          Expanded(child: _buildResults()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _performSearch,
        icon: const Icon(Icons.search),
        label: const Text('بحث'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفلاتر',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // فصيلة الدم
          DropdownButtonFormField<String>(
            initialValue: _selectedBloodType,
            decoration: const InputDecoration(
              labelText: 'فصيلة الدم',
              prefixIcon: Icon(Icons.bloodtype),
            ),
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedBloodType = value),
          ),
          
          const SizedBox(height: 12),
          
          // المديرية
          DropdownButtonFormField<String>(
            initialValue: _selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'المديرية',
              prefixIcon: Icon(Icons.location_city),
            ),
            items: AppStrings.districts
                .map((district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedDistrict = value),
          ),
          
          const SizedBox(height: 12),
          
          // الجنس
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'الجنس',
              prefixIcon: Icon(Icons.person),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('ذكر')),
              DropdownMenuItem(value: 'female', child: Text('أنثى')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          
          const SizedBox(height: 16),
          
          // الحالة
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('المتاحين'),
                  value: _includeAvailable,
                  onChanged: (value) => setState(() => _includeAvailable = value ?? true),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('الموقوفين'),
                  value: _includeSuspended,
                  onChanged: (value) => setState(() => _includeSuspended = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return EmptyState(
        icon: Icons.search,
        title: 'ابدأ البحث',
        message: 'اختر الفلاتر واضغط على زر البحث',
      );
    }

    if (_isSearching) {
      return const LoadingWidget(message: 'جاري البحث...');
    }

    if (_searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'لا توجد نتائج',
        message: 'لم يتم العثور على متبرعين بهذه المواصفات',
        actionLabel: 'مسح الفلاتر',
        onAction: _clearFilters,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final donor = _searchResults[index];
        return DonorCard(
          donor: donor,
          showActions: true,
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _includeAvailable = true;
      _includeSuspended = false;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final provider = context.read<DonorProvider>();
      await provider.loadDonors();
      
      var results = provider.donors;

      // تطبيق الفلاتر
      if (_selectedBloodType != null) {
        results = results.where((d) => d.bloodType == _selectedBloodType).toList();
      }

      if (_selectedDistrict != null) {
        // مطابقة المحافظة الكاملة أو مديرية محددة (متسقة مع شاشات الإدارة)
        results = results
            .where((d) =>
                d.district == _selectedDistrict ||
                d.district.startsWith('$_selectedDistrict - '))
            .toList();
      }

      if (_selectedGender != null) {
        results = results.where((d) => d.gender == _selectedGender).toList();
      }

      // فلتر الحالة
      results = results.where((d) {
        if (_includeAvailable && !d.isSuspended) return true;
        if (_includeSuspended && d.isSuspended) return true;
        return false;
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل البحث: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

}

