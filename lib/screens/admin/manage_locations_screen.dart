import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/location_model.dart';
import '../../services/location_service.dart';
import '../../providers/location_provider.dart';
import '../../config/service_locator.dart';
import '../../widgets/loading_widget.dart';

/// شاشة إدارة المناطق (للأدمن): تفعيل/إيقاف المحافظات، وإدارة المديريات
class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen> {
  final LocationService _service = getIt<LocationService>();

  List<GovernorateModel> _governorates = [];
  final Map<String, List<DistrictModel>> _districts = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _governorates = await _service.getAllGovernorates();
    } catch (e) {
      _error = 'تعذّر تحميل المحافظات';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDistricts(String gov) async {
    final list = await _service.getDistrictsOf(gov);
    if (mounted) setState(() => _districts[gov] = list);
  }

  void _refreshPublicLists() => context.read<LocationProvider>().refresh();

  void _showError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  Future<void> _toggleGovernorate(GovernorateModel g, bool value) async {
    try {
      await _service.setGovernorateActive(g.name, value);
      await _loadGovernorates();
      _refreshPublicLists();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleDistrict(String gov, DistrictModel d, bool value) async {
    try {
      await _service.setDistrictActive(d.id, value);
      await _loadDistricts(gov);
      _refreshPublicLists();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _addDistrict(String gov) async {
    final name = await _promptName('إضافة مديرية في $gov');
    if (name == null || name.trim().isEmpty) return;
    try {
      await _service.addDistrict(gov, name.trim());
      await _loadDistricts(gov);
      _refreshPublicLists();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _editDistrict(String gov, DistrictModel d) async {
    final name = await _promptName('تعديل اسم المديرية', initial: d.name);
    if (name == null || name.trim().isEmpty || name.trim() == d.name) return;
    try {
      await _service.updateDistrict(d.id, gov, d.name, name.trim());
      await _loadDistricts(gov);
      _refreshPublicLists();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteDistrict(String gov, DistrictModel d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف مديرية'),
        content: Text('هل تريد حذف "${d.name}"؟'),
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
    if (confirm != true) return;
    try {
      await _service.deleteDistrict(d.id, gov, d.name);
      await _loadDistricts(gov);
      _refreshPublicLists();
    } catch (e) {
      _showError(e);
    }
  }

  Future<String?> _promptName(String title, {String? initial}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'اسم المديرية'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المناطق'),
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
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل المناطق...')
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadGovernorates,
                  child: ListView(
                    children: [
                      Container(
                        width: double.infinity,
                        color: AppColors.info.withValues(alpha: 0.08),
                        padding: const EdgeInsets.all(12),
                        child: const Text(
                          'فعّل المحافظات والمديريات التي تريد إظهارها للمستخدمين. '
                          'الموقوفة تختفي من الإضافة والبحث.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ..._governorates.map(_buildGovernorateTile),
                    ],
                  ),
                ),
    );
  }

  Widget _buildGovernorateTile(GovernorateModel g) {
    return ExpansionTile(
      onExpansionChanged: (open) {
        if (open && !_districts.containsKey(g.name)) _loadDistricts(g.name);
      },
      leading: Icon(
        Icons.map,
        color: g.isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        g.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: g.isActive ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      subtitle: Text(g.isActive ? 'مفعّلة' : 'موقوفة'),
      trailing: Switch(
        value: g.isActive,
        activeThumbColor: AppColors.success,
        onChanged: (v) => _toggleGovernorate(g, v),
      ),
      children: [_buildDistrictsSection(g.name)],
    );
  }

  Widget _buildDistrictsSection(String gov) {
    final list = _districts[gov];
    if (list == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        ...list.map(
          (d) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(right: 32, left: 8),
            leading: Icon(
              Icons.location_on,
              size: 18,
              color: d.isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            title: Text(
              d.name,
              style: TextStyle(
                color:
                    d.isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: d.isActive,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => _toggleDistrict(gov, d, v),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _editDistrict(gov, d);
                    if (v == 'delete') _deleteDistrict(gov, d);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextButton.icon(
            onPressed: () => _addDistrict(gov),
            icon: const Icon(Icons.add),
            label: const Text('إضافة مديرية'),
          ),
        ),
      ],
    );
  }
}
