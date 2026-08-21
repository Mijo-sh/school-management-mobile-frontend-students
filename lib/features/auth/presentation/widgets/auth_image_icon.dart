import 'package:flutter/material.dart';

/// Circular glass badge with an icon — the header emblem on both pages.
class AuthBadgeLogIN extends StatelessWidget {
  final String image;
  const AuthBadgeLogIN({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: cs.onPrimary.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: cs.onPrimary.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      // إضافة Padding لتقليل مساحة الصورة وجعلها أصغر من الدائرة
      child: Padding(
        padding: const EdgeInsets.all(7.0), // يمكنك زيادة أو نقص الرقم حسب الحجم المطلوب
        child: Image.asset(image),
      ),
    );
  }
}