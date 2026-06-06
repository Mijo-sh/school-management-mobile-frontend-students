import '../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingNextButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double progress;

  const OnboardingNextButtonWidget({
    super.key,
    required this.onTap,
    required this.progress
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 3.5,
                  backgroundColor: AppColors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white)
                )
              )
            ),
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFB8FFB),
                    Color(0xFF704170)
                  ]
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(.15)
                  )
                ]
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 35,
                color: AppColors.white
              )
            )
          ]
        )
      )
    );
  }
}