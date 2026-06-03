import 'package:flutter/material.dart';

/// Transitions مخصصة للتنقل بين الشاشات
class AppPageTransitions {
  /// Slide من اليمين (للشاشات الفرعية)
  static Route<T> slideFromRight<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curve = CurveTween(curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).chain(curve).animate(animation);

        // الشاشة الخلفية تتحرك للجهة اليسرى قليلاً
        final backSlide = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.15, 0),
        ).chain(curve).animate(secondaryAnimation);

        return SlideTransition(
          position: backSlide,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Fade (للشاشات الرئيسية - مرونة أكثر)
  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  /// Slide من الأسفل للأعلى (للـ modals وDialogs)
  static Route<T> slideUp<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) {
        final curve = CurveTween(curve: Curves.easeOutQuint);
        final slide = Tween<Offset>(
          begin: const Offset(0, 1.0),
          end: Offset.zero,
        ).chain(curve).animate(animation);

        final fade = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Scale + Fade (للداشبورد والشاشات المهمة)
  static Route<T> scaleUp<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, _, child) {
        final curve = CurveTween(curve: Curves.easeOutBack);
        final scale = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(curve).animate(animation);
        final fade = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }
}
