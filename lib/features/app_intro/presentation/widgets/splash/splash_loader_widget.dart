import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashLoaderWidget extends StatelessWidget {
  const SplashLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.stretchedDots(
      color: AppColors.white,
      size: 50
    );
  }
}