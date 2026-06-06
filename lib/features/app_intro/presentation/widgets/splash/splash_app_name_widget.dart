import '../../../../../core/localization/app_localization.dart';
import 'package:flutter/material.dart';

class SplashAppNameWidget extends StatelessWidget {
  final Animation<Offset> offset;
  final Animation<double> opacity;

  const SplashAppNameWidget({
    super.key,
    required this.offset,
    required this.opacity
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: offset,
        child: Text(
          "app_name".tr(context),
          style: theme.primaryTextTheme.headlineLarge
        )
      )
    );
  }
}