import 'package:flutter/material.dart';
import 'splash_app_name_widget.dart';
import 'splash_loader_widget.dart';
import 'splash_logo_widget.dart';

class SplashContentWidget extends StatelessWidget {
  final Animation<double> logoScale;
  final Animation<double> logoOpacity;
  final Animation<Offset> textOffset;
  final Animation<double> textOpacity;

  const SplashContentWidget({
    super.key,
    required this.logoScale,
    required this.logoOpacity,
    required this.textOffset,
    required this.textOpacity
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            SplashLogoWidget(scale: logoScale, opacity: logoOpacity),
            SplashAppNameWidget(offset: textOffset, opacity: textOpacity),
            const SizedBox(height: 90),
            SplashLoaderWidget()
          ]
        )
      )
    );
  }
}