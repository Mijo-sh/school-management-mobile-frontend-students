import '../../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingBubblesWidget extends StatelessWidget {
  const OnboardingBubblesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _bubble(left: width * 0.05, top: 20, size: 12),
        _bubble(left: width * 0.30, top: 10, size: 60),
        _bubble(left: width * 0.1, top: 80, size: 35),
        _bubble(left: width * 0.60, top: 90, size: 35),
        _bubble(left: width * 0.15, top: 390, size: 18),
        _bubble(right: width * 0.09, top: 60, size: 16),
        _bubble(right: width * 0.15, top: 190, size: 18),
        _bubble(right: width * 0.09, top: 380, size: 30),
        _bubble(right: width * 0.45, top: 360, size: 60),
        _bubble(left: width * 0.1, bottom: 100, size: 15),
        _bubble(left: width * 0.12, bottom: 20, size: 50),
        _bubble(right: width * 0.40, bottom: 10, size: 30),
        _bubble(right: width * 0.05, bottom: 150, size: 30),
        _bubble(right: width * 0.12, bottom: 50, size: 16)
      ]
    );
  }

  Widget _bubble({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(.08),
          shape: BoxShape.circle
        )
      )
    );
  }
}