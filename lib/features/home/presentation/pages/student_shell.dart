// student_shell.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/unread_counts_store.dart';

class StudentShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  void initState() {
    super.initState();
    // 👇 هون بالضبط المكان الصحيح — أول ما الطالب يدخل الـ shell
    // (بغض النظر عن أي تبويب رح يبين أول شي)، نحمّل عدادات البادج
    // الثلاثة مرة وحدة، قبل ما يوصل لتبويب الخدمات أصلًا.
    di<UnreadCountsStore>().loadAll(); // studentId = null (الطالب نفسو)
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        extendBody: true,
        bottomNavigationBar: CurvedNavigationBar(
          index: widget.navigationShell.currentIndex,
          height: 60,
          backgroundColor: Colors.transparent,
          color: cs.primary,
          buttonBackgroundColor: cs.primaryContainer,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          onTap: _onTap,
          items: [
            Icon(Icons.home_rounded, color: cs.onPrimary, size: 26),         // Index 0: Dashboard
            Icon(Icons.grid_view_rounded, color: cs.onPrimary, size: 26),    // Index 1: Services
            Icon(Icons.chat_bubble_outline, color: cs.onPrimary, size: 26),  // Index 2: AI Chat
            Icon(Icons.quiz_rounded, color: cs.onPrimary, size: 26),
          ],
        ),
        body: widget.navigationShell,
      ),
    );
  }
}
