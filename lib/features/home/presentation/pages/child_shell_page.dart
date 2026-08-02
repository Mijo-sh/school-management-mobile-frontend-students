// child_shell_page.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/unread_counts_store.dart';
import '../../../profile/domain/entities/child_card.dart';

class ChildShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final ChildCard child;

  const ChildShellPage({
    super.key,
    required this.navigationShell,
    required this.child,
  });

  @override
  State<ChildShellPage> createState() => _ChildShellPageState();
}

class _ChildShellPageState extends State<ChildShellPage> {
  @override
  void initState() {
    super.initState();
    // نفس مبدأ StudentShell بالظبط، بس هون studentId = id الابن.
    di<UnreadCountsStore>().loadAll(studentId: widget.child.id);
  }

  @override
  void didUpdateWidget(covariant ChildShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو تبدّل الابن (نادر بنفس مكان الـ widget، بس احتياط) نعيد التحميل.
    if (oldWidget.child.id != widget.child.id) {
      di<UnreadCountsStore>().loadAll(studentId: widget.child.id);
    }
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
            Icon(Icons.home_rounded, color: cs.onPrimary, size: 26),
            Icon(Icons.grid_view_rounded, color: cs.onPrimary, size: 26),
           // Icon(Icons.chat_bubble_outline, color: cs.onPrimary, size: 26),

          ],
        ),
        body: widget.navigationShell,
      ),
    );
  }
}
