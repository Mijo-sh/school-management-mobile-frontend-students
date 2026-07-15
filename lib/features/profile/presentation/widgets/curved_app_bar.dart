// widgets/curved_app_bar.dart
import 'package:flutter/material.dart';

class CurvedAppBar extends StatelessWidget {
  final String title;
  const CurvedAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 14,
        bottom: 18,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Icon(Icons.menu_rounded, color: cs.onPrimary, size: 24),
          ),
          Text(
            title,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}