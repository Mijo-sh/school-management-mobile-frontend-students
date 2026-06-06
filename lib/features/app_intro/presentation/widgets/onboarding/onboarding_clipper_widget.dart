import 'package:flutter/material.dart';

class OnboardingClipperWidget extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 25.0;
    const holeRadius = 50.0;

    path.moveTo(0, radius);
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius)
    );
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius)
    );
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius)
    );
    path.lineTo(size.width / 2 + holeRadius + 20, size.height);
    path.quadraticBezierTo(
      size.width / 2 + holeRadius, size.height,
      size.width / 2 + holeRadius, size.height - 25
    );
    path.arcToPoint(
      Offset(size.width / 2 - holeRadius, size.height - 25),
      radius: const Radius.circular(holeRadius),
      clockwise: false
    );
    path.quadraticBezierTo(
      size.width / 2 - holeRadius, size.height,
      size.width / 2 - holeRadius - 20, size.height
    );
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius)
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}