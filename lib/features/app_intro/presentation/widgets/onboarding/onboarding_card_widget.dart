import '../../../../../core/theme/app_colors.dart';
import 'onboarding_next_button_widget.dart';
import 'onboarding_clipper_widget.dart';
import 'package:flutter/material.dart';

class OnboardingCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onNext;
  final double progress;

  const OnboardingCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onNext,
    required this.progress
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipPath(
          clipper: OnboardingClipperWidget(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            height: MediaQuery.of(context).size.height * 0.30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
                bottom: 70
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 15),
                  Text(
                    description,
                    textAlign: TextAlign.center
                  )
                ]
              )
            )
          )
        ),
        Positioned(
          bottom: -15,
          child: OnboardingNextButtonWidget(
            onTap: onNext,
            progress: progress
          )
        )
      ]
    );
  }
}