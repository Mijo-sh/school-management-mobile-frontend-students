import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../profile/presentation/manager/guardian_cubit.dart';
import '../../../profile/presentation/manager/student_cubit.dart';
import '../../../profile/presentation/pages/guardian.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'home_paage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BlocProvider(
      create: (_) => di<StudentCubit>()..loadStudentData(),
      child: const StudentDashboard(),
    ),
    BlocProvider(
      create: (_) => di<GuardianCubit>()..loadChildren(),
      child: const GuardianPage(),
    ),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(child: Scaffold(
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: cs.primary,
        buttonBackgroundColor: cs.primaryContainer,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (i) {
          if (i < _screens.length) {
            setState(() => _currentIndex = i);
          }
        },
        items: [
          Icon(Icons.home_rounded,           color: cs.onPrimary, size: 26),
          Icon(Icons.calendar_month_rounded, color: cs.onPrimary, size: 26),
          Icon(Icons.bar_chart_rounded,      color: cs.onPrimary, size: 26),
          Icon(Icons.person_rounded,         color: cs.onPrimary, size: 26),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex < _screens.length ? _currentIndex : 0,
        children: _screens,
      ),
    ));
  }
}