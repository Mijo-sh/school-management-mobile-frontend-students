import 'package:flutter/material.dart';

/// الخلفية الموحّدة المستخدمة بهيدر الداشبورد وبقية الشاشات (لون
/// أساسي + نقشة خفيفة فوقه بتأثير difference) — بدل ما نكررها بكل
/// ملف هيدر لحاله (dashboard_header.dart، CurvedHeaderBar، إلخ).
///
/// الاستخدام: حطها كأول عنصر جوا [Stack] (أو [Positioned.fill] إذا
/// الأب مش Stack بحجم محدد أصلًا)، وخليها ورا باقي محتوى الهيدر.
///
/// ```dart
/// Stack(
///   fit: StackFit.expand,
///   children: [
///     const DecorativeHeaderBackground(),
///     // ... باقي محتوى الهيدر فوقها
///   ],
/// )
/// ```
class DecorativeHeaderBackground extends StatelessWidget {
  /// شدة ظهور النقشة — بين 0 (مخفية تمامًا) و1 (أوضح ما يمكن).
  /// القيمة الافتراضية (0.12) هي نفسها المستخدمة بكل الهيدرز الحالية.
  final double patternOpacity;

  /// اللون الأساسي خلف النقشة. لو null، بياخد [ColorScheme.primary]
  /// تلقائيًا من الـ context (الحالة الشائعة بكل هيدرز التطبيق).
  final Color? backgroundColor;

  const DecorativeHeaderBackground({
    super.key,
    this.patternOpacity = 0.12,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: backgroundColor ?? cs.primary),
        Opacity(
          opacity: patternOpacity.clamp(0.0, 1.0),
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/background_login.jpg',
              fit: BoxFit.cover,
              color: Colors.white,
              colorBlendMode: BlendMode.difference,
            ),
          ),
        ),
      ],
    );
  }
}