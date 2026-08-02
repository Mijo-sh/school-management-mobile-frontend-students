// widgets/child_avatar.dart
import 'package:flutter/material.dart';

class ChildAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String gender;

  const ChildAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 150,
      height: 150,
          child:  _fallback(cs),
    );
  }

  Widget _fallback(ColorScheme cs) {
    final assetPath = gender.toLowerCase() == 'male'
        ? 'assets/images/student_boy.png'
        : 'assets/images/student_girl.png';

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.person_rounded, size: 100, color: cs.primary),
      ),
    );
  }
}