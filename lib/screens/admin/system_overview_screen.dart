import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/statistics_provider.dart';
import '../../services/hospital_service.dart';
import '../../services/report_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/loading_widget.dart';

/// شاشة النظرة العامة على النظام (للأدمن)
class SystemOverviewScreen extends StatefulWidget {
  const SystemOverviewScreen({super.key});

  @override
  State<SystemOverviewScreen> createState() => _SystemOverviewScreenState();
}

class _SystemOverviewScreenState extends State<SystemOverviewScreen> {
  final _hospitalService = HospitalService();
  final _reportService = ReportService();
  final _donorService = DonorService();
  
  int _totalHospitals = 0;
  int _activeHospitals = 0;
  int _pendingReports = 0;
  int _suspendedDonors = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // تأجيل التحميل لما بعد بناء الواجهة
    Future.microtask(() => _loadOverviewData());
  }

  Future<void> _loadOverviewData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحميل الإحصائيات
      await context.read<StatisticsProvider>().loadStatistics();
      
      // تحميل بيانات المستشفيات
      final hospitals = await _hospitalService.getAllHospitals();
      _totalHospitals = hospitals.length;
      _activeHospitals = hospitals.where((h) => h.isActive).length;
      
      // تحميل البلاغات المعلقة
      _pendingReports = await _reportService.getPendingReportsCount();
      
      // تحميل المتبرعين الموقوفين
      final suspended = await _donorService.getSuspendedDonors();
      _suspendedDonors = suspended.length;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.systemOverview),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOverviewData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل البيانات...')
          : RefreshIndicator(
              onRefresh: _loadOverviewData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // إحصائيات المتبرعين
                    _buildSectionTitle('إحصائيات المتبرعين'),
                    Consumer<StatisticsProvider>(
                      builder: (context, provider, _) {
                        final stats = provider.statistics;
                        if (stats == null) {
                          return const SizedBox.shrink();
                        }
                        
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.people,
                                    title: 'إجمالي المتبرعين',
                                    value: '${stats.totalDonors}',
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.pause_circle,
                                    title: 'موقوفين مؤقتاً',
                                    value: '$_suspendedDonors',
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.bloodtype,
                                    title: 'أكثر فصيلة',
                                    value: stats.mostCommonBloodType ?? '-',
                                    subtitle: '${stats.mostCommonBloodTypeCount} متبرع',
                                    color: AppColors.bloodTypeA,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.location_city,
                                    title: 'أكثر مديرية',
                                    value: stats.mostActiveDistrict ?? '-',
                                    subtitle: '${stats.mostActiveDistrictCount} متبرع',
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // إحصائيات المستشفيات
                    _buildSectionTitle('إحصائيات المستشفيات'),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_hospital,
                            title: 'إجمالي المستشفيات',
                            value: '$_totalHospitals',
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            title: 'مستشفيات نشطة',
                            value: '$_activeHospitals',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // إحصائيات البلاغات
                    _buildSectionTitle('إحصائيات البلاغات'),
                    _StatCard(
                      icon: Icons.report,
                      title: 'بلاغات معلقة',
                      value: '$_pendingReports',
                      color: _pendingReports > 0 ? AppColors.warning : AppColors.success,
                      subtitle: _pendingReports > 0 ? 'يحتاج مراجعة' : 'لا توجد بلاغات',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // توزيع فصائل الدم
                    _buildSectionTitle('توزيع فصائل الدم'),
                    Consumer<StatisticsProvider>(
                      builder: (context, provider, _) {
                        final stats = provider.statistics;
                        if (stats == null || stats.bloodTypeDistribution.isEmpty) {
                          return const Text('لا توجد بيانات');
                        }
                        
                        return _BloodTypeDistribution(
                          distribution: stats.bloodTypeDistribution,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // توزيع المحافظات (مجمَّع — أوضح من عرض كل المديريات وطنياً)
                    _buildSectionTitle('توزيع المحافظات'),
                    Consumer<StatisticsProvider>(
                      builder: (context, provider, _) {
                        final stats = provider.statistics;
                        if (stats == null || stats.districtDistribution.isEmpty) {
                          return const Text('لا توجد بيانات');
                        }

                        return _DistrictDistribution(
                          distribution: stats.governorateDistribution,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// توزيع فصائل الدم
class _BloodTypeDistribution extends StatelessWidget {
  final Map<String, int> distribution;

  const _BloodTypeDistribution({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedEntries.map((entry) {
            final percentage = distribution.values.reduce((a, b) => a + b) > 0
                ? (entry.value / distribution.values.reduce((a, b) => a + b) * 100)
                : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${entry.value} متبرع (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(
                      _getBloodTypeColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A') && !bloodType.contains('AB')) return AppColors.bloodTypeA;
    if (bloodType.contains('B') && !bloodType.contains('AB')) return AppColors.bloodTypeB;
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}

/// توزيع المديريات
class _DistrictDistribution extends StatelessWidget {
  final Map<String, int> distribution;

  const _DistrictDistribution({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedEntries.map((entry) {
            final percentage = distribution.values.reduce((a, b) => a + b) > 0
                ? (entry.value / distribution.values.reduce((a, b) => a + b) * 100)
                : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${entry.value} متبرع (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

