// student_shell.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: CurvedNavigationBar(
          index: navigationShell.currentIndex,
          height: 60,
          backgroundColor: Colors.transparent,
          color: cs.primary,
          buttonBackgroundColor: cs.primaryContainer,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          onTap: _onTap,
          items: [
            Icon(Icons.home_rounded, color: cs.onPrimary, size: 26),
            Icon(Icons.grid_view_rounded, color: cs.onPrimary, size: 26),
          ],
        ),
        body: navigationShell,
      ),
    );
  }
}