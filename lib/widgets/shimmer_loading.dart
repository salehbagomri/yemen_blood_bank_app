import 'package:flutter/material.dart';

/// Shimmer loading effect بدون حاجة لباكدج خارجي
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// Shimmer مستطيل
  const ShimmerWidget.rect({
    super.key,
    required this.width,
    required this.height,
  }) : borderRadius = const BorderRadius.all(Radius.circular(6));

  /// Shimmer دائري
  factory ShimmerWidget.circle({Key? key, required double size}) {
    return ShimmerWidget(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// Shimmer جاهزة للاستخدام في مختلف الشاشات
// ================================================================

/// Shimmer skeleton لبطاقة متبرع (DonorCard)
class DonorCardShimmer extends StatelessWidget {
  const DonorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // دائرة فصيلة الدم
          ShimmerWidget.circle(size: 50),
          const SizedBox(width: 12),
          // معلومات النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rect(width: 140, height: 16),
                const SizedBox(height: 8),
                ShimmerWidget.rect(width: 200, height: 12),
                const SizedBox(height: 6),
                ShimmerWidget.rect(width: 160, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Chip الحالة
          ShimmerWidget.rect(width: 40, height: 22),
        ],
      ),
    );
  }
}

/// قائمة shimmer لـ N بطاقة
class DonorListShimmer extends StatelessWidget {
  final int count;

  const DonorListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, index) => DonorCardShimmer(key: ValueKey(index)),
    );
  }
}

/// Shimmer لقسم الإحصائيات
class StatisticsShimmer extends StatelessWidget {
  const StatisticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerWidget.circle(size: 24),
              const SizedBox(width: 8),
              ShimmerWidget.rect(width: 100, height: 18),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _statCardShimmer()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _statCardShimmer()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.circle(size: 20),
          const SizedBox(height: 8),
          ShimmerWidget.rect(width: double.infinity, height: 10),
          const SizedBox(height: 6),
          ShimmerWidget.rect(width: 60, height: 16),
        ],
      ),
    );
  }
}

/// Shimmer لصف بحث سريع (Hospital dashboard)
class SearchResultShimmer extends StatelessWidget {
  const SearchResultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ShimmerWidget.rect(width: 40, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rect(width: 120, height: 14),
                    const SizedBox(height: 6),
                    ShimmerWidget.rect(width: 180, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
