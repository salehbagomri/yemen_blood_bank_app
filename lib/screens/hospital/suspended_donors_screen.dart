import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../services/donor_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../../utils/error_handler.dart';

/// شاشة المتبرعين الموقوفين (للمستشفى)
class SuspendedDonorsScreen extends StatefulWidget {
  const SuspendedDonorsScreen({super.key});

  @override
  State<SuspendedDonorsScreen> createState() => _SuspendedDonorsScreenState();
}

class _SuspendedDonorsScreenState extends State<SuspendedDonorsScreen> {
  final _donorService = DonorService();
  List<DonorModel> _suspendedDonors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuspendedDonors();
  }

  Future<void> _loadSuspendedDonors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final donors = await _donorService.getSuspendedDonors();
      setState(() {
        _suspendedDonors = donors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getArabicMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.suspendedDonors),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuspendedDonors,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل المتبرعين الموقوفين...');
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        message: _errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadSuspendedDonors,
      );
    }

    if (_suspendedDonors.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle,
        title: 'لا يوجد متبرعين موقوفين',
        message: 'جميع المتبرعين متاحين للتبرع',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSuspendedDonors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suspendedDonors.length,
        itemBuilder: (context, index) {
          final donor = _suspendedDonors[index];
          return _SuspendedDonorCard(donor: donor);
        },
      ),
    );
  }
}

/// بطاقة المتبرع الموقوف
class _SuspendedDonorCard extends StatelessWidget {
  final DonorModel donor;

  const _SuspendedDonorCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    final daysLeft = donor.daysUntilCanDonate ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.warning,
                  child: Text(
                    donor.bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Helpers.displayPhoneNumber(donor.phoneNumber),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موقوف حتى: ${Helpers.formatDate(donor.suspendedUntil!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'باقي $daysLeft يوم',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (donor.lastDonationDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'آخر تبرع: ${Helpers.formatDate(donor.lastDonationDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

