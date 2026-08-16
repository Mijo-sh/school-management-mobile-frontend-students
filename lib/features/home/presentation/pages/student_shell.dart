// student_shell.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/unread_counts_store.dart';
import '../../../exam/presentation/widgets/exam_unread_store.dart';
import '../../../quiz/presentation/widgets/quiz_unread_store.dart';

class StudentShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // نراقب حالة التطبيق (foreground/background)
    WidgetsBinding.instance.addObserver(this);

    // أول ما الطالب يدخل الـ shell، نحمّل العدّادات مرة وحدة.
    di<UnreadCountsStore>().loadAll(); // studentId = null (الطالب نفسو)
    di<QuizUnreadStore>().loadAll();   // عدّادات كويزات كل مادة
    di<ExamUnreadStore>().loadCounts();   // 👈 وهذا؟

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // لما يرجع التطبيق من الخلفية (background/terminated) للواجهة،
    // نعيد جلب العدّادات — لأن onForegroundMessage ما بيشتغل بالخلفية،
    // فأي إشعار وصل والتطبيق تحت ما حدّث العدّاد، وهون منعوّض.
    if (state == AppLifecycleState.resumed) {
      di<UnreadCountsStore>().loadAll(); // studentId = null (الطالب نفسو)
      di<QuizUnreadStore>().loadAll();
      di<ExamUnreadStore>().loadCounts();   // 👈 هل هذا موجود؟

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
            Icon(Icons.chat_bubble_outline, color: cs.onPrimary, size: 26),
            Icon(Icons.quiz_rounded, color: cs.onPrimary, size: 26),
            Icon(Icons.calendar_month_rounded, color: cs.onPrimary, size: 26),
          ],
        ),
        body: widget.navigationShell,
      ),
    );
  }
}