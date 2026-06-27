import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  // مرجع ثابت — بساعد كاش الصور يتعرّف عليها كنفس الصورة
  static const _bg = AssetImage('assets/images/background_login.jpg');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(color: cs.primary),
        Positioned.fill(
          child: Opacity(
            opacity: 0.12,
            child: IgnorePointer(
              child: Image(
                image: _bg,
                fit: BoxFit.fill,
                color: Colors.white,
                colorBlendMode: BlendMode.difference,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}