import 'package:flutter/material.dart';
import '../../../models/statistics_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/helpers.dart';

/// قسم الإحصائيات في الصفحة الرئيسية — مع Animated Counter
class StatisticsSection extends StatefulWidget {
  final StatisticsModel statistics;

  const StatisticsSection({super.key, required this.statistics});

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StatisticsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statistics.totalDonors != widget.statistics.totalDonors) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                AppStrings.statistics,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _AnimatedStatCard(
                  icon: Icons.people,
                  title: AppStrings.totalDonors,
                  numericValue: widget.statistics.totalDonors,
                  parentController: _controller,
                  delay: 0.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimatedStatCard(
                  icon: Icons.bloodtype,
                  title: AppStrings.mostCommonBloodType,
                  textValue: widget.statistics.mostCommonBloodType ?? '-',
                  subtitle:
                      '${widget.statistics.mostCommonBloodTypeCount} متبرع',
                  parentController: _controller,
                  delay: 0.15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AnimatedStatCard(
                  icon: Icons.location_city,
                  title: AppStrings.mostActiveDistrict,
                  textValue: widget.statistics.mostActiveDistrict ?? '-',
                  subtitle:
                      '${widget.statistics.mostActiveDistrictCount} متبرع',
                  parentController: _controller,
                  delay: 0.25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimatedStatCard(
                  icon: Icons.access_time,
                  title: AppStrings.latestDonor,
                  textValue: widget.statistics.latestDonorName ?? '-',
                  subtitle: widget.statistics.latestDonorDate != null
                      ? Helpers.formatDate(widget.statistics.latestDonorDate!)
                      : null,
                  parentController: _controller,
                  delay: 0.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.update, color: Colors.white70, size: 12),
              const SizedBox(width: 4),
              Text(
                'آخر تحديث: ${Helpers.formatDateTime(widget.statistics.lastUpdated)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================

class _AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? numericValue;
  final String? textValue;
  final String? subtitle;
  final AnimationController parentController;
  final double delay;

  const _AnimatedStatCard({
    required this.icon,
    required this.title,
    this.numericValue,
    this.textValue,
    this.subtitle,
    required this.parentController,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final begin = delay;
    final end = (delay + 0.6).clamp(0.0, 1.0);

    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: parentController,
            curve: Interval(begin, end, curve: Curves.easeOutCubic),
          ),
        );

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parentController,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              numericValue != null
                  ? _AnimatedCounter(
                      value: numericValue!,
                      controller: parentController,
                      intervalBegin: begin,
                      intervalEnd: end,
                    )
                  : Text(
                      textValue ?? '-',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================

class _AnimatedCounter extends StatelessWidget {
  final int value;
  final AnimationController controller;
  final double intervalBegin;
  final double intervalEnd;

  const _AnimatedCounter({
    required this.value,
    required this.controller,
    required this.intervalBegin,
    required this.intervalEnd,
  });

  @override
  Widget build(BuildContext context) {
    final anim = IntTween(begin: 0, end: value).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(intervalBegin, intervalEnd, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Text(
        '${anim.value}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
