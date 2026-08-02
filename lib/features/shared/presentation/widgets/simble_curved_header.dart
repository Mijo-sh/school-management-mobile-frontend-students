
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DecorativeHeaderBackground.dart';

class SimbleCurvedHeader extends StatelessWidget {
  final title;
  const SimbleCurvedHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        children: [
          const Positioned.fill(child: DecorativeHeaderBackground()),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}