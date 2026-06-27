import '../../../../../core/assets_manager/images_manager.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashBackgroundWidget extends StatelessWidget {
  const SplashBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.purple600
          )
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              ImagesManager.patternBackground,
              fit: BoxFit.fill,
              color: AppColors.white,
              colorBlendMode: BlendMode.srcIn
            )
          )
        )
      ]
    );
  }
}