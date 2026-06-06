import '../../../../../core/assets_manager/images_manager.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashBackgroundWidget extends StatelessWidget {
  const SplashBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.primaryColorDark,
                theme.primaryColor
              ]
            )
          )
        ),
        // pattern background
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              ImagesManager.splashBackground,
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