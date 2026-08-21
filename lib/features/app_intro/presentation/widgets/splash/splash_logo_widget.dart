import '../../../../../core/assets_manager/images_manager.dart';
import 'package:flutter/material.dart';

class SplashLogoWidget extends StatelessWidget {
  final Animation<double> scale;
  final Animation<double> opacity;

  const SplashLogoWidget({
    super.key,
    required this.scale,
    required this.opacity
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: scale,
        child: SizedBox(
          height: 150,
          width: 150,
          child: Center(child: Image.asset("assets/images/logo1.png"))
        )
      )
    );
  }
}