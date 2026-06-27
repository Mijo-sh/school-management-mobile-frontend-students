import '../../../../../../core/theme/app_colors.dart';
import 'onboarding_bubbles_widget.dart';
import 'package:flutter/material.dart';

class OnboardingBackgroundWidget extends StatelessWidget {
  const OnboardingBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.purple600,
                AppColors.purple300
              ]
            )
          )
        ),
        Positioned.fill(
          child: OnboardingBubblesWidget()
        )
      ]
    );
  }
}