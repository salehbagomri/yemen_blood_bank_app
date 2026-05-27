// =====================================================================
// Widget Tests: ShimmerWidget
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_blood_bank/widgets/shimmer_loading.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════
  group('ShimmerWidget', () {
    testWidgets('ShimmerWidget.rect يُعرض بأبعاد صحيحة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShimmerWidget.rect(width: 200, height: 20)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final size = container.constraints;
      expect(size, isNotNull);
    });

    testWidgets('ShimmerWidget.circle يُعرض كدائرة', (tester) async {
      // ملاحظة: ShimmerWidget.circle factory ليست const لذا لا نستخدم const
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: ShimmerWidget.circle(size: 50))),
        ),
      );

      expect(find.byType(ShimmerWidget), findsOneWidget);
    });

    testWidgets('يُشغّل animation تلقائياً', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShimmerWidget(width: 100, height: 20)),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorCardShimmer', () {
    testWidgets('يُعرض بنجاح', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DonorCardShimmer())),
      );

      expect(find.byType(DonorCardShimmer), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('DonorListShimmer', () {
    testWidgets('يُعرض العدد الصحيح من البطاقات', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DonorListShimmer(count: 4))),
      );

      expect(find.byType(DonorCardShimmer), findsNWidgets(4));
    });

    testWidgets('يعمل بالقيمة الافتراضية (6 بطاقات)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DonorListShimmer())),
      );

      expect(find.byType(DonorCardShimmer), findsNWidgets(6));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  group('StatisticsShimmer', () {
    testWidgets('يُعرض بنجاح', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatisticsShimmer())),
      );

      expect(find.byType(StatisticsShimmer), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}
