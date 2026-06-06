import 'onboarding_bubbles_widget.dart';
import 'package:flutter/material.dart';

class OnboardingBackgroundWidget extends StatelessWidget {
  const OnboardingBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
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
        Positioned.fill(
          child: OnboardingBubblesWidget()
        )
      ]
    );
  }
}