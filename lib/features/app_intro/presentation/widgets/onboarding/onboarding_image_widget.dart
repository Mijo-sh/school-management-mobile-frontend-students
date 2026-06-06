import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class OnboardingImageWidget extends StatelessWidget {
  final String image;

  const OnboardingImageWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: SvgPicture.asset(
        image,
        fit: BoxFit.contain
      ),
    );
  }
}