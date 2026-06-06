import 'package:flutter/material.dart';

class SplashVersionWidget extends StatelessWidget {
  final String appVersion;

  const SplashVersionWidget({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(child: Text(
        appVersion,
        style: theme.primaryTextTheme.bodyLarge
      ))
    );
  }
}