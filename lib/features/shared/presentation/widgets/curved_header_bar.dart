import 'package:flutter/material.dart';

class CurvedHeaderBar extends StatelessWidget {
  final String title;
  final String? backgroundImage;

  const CurvedHeaderBar({
    super.key,
    required this.title,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        decoration: BoxDecoration(color: cs.primary),
        child: Stack(
          children: [
            if (backgroundImage != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    backgroundImage!,
                    fit: BoxFit.cover,
                    color: Colors.white,
                    colorBlendMode: BlendMode.difference,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                top: statusBarHeight + 4,
                bottom: 8,
                left: 20,
                right: 20,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_rounded, color: cs.onPrimary),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}