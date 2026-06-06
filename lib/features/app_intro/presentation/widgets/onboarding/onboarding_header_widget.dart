import '../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingHeaderWidget extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const OnboardingHeaderWidget({
    super.key,
    required this.onBack,
    required this.onSkip
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onSkip,
            child: Text(
              "skip",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20
              )
            )
          ),
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.white,
            onPressed: onBack
          )
        ]
      )
    );
  }
}