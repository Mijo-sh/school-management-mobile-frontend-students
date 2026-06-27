import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../profile/domain/entities/user_role.dart';
import '../../../profile/presentation/manager/guardian_cubit.dart';
import '../../../profile/presentation/manager/student_cubit.dart';
import '../../../profile/presentation/pages/guardian.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../manager/main_cubit.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الكيوبت يقرا الدور من التخزين أول ما تنفتح الشاشة
    return BlocProvider(
      create: (_) => di<MainCubit>()..loadRole(),
      child: const _MainView(),
    );
  }
}

class _MainView extends StatelessWidget {
  const _MainView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state is MainLoading || state is MainInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is MainError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          );
        }

        final role = (state as MainRoleLoaded).role;
        return _RoleScaffold(role: role);
      },
    );
  }
}

class _RoleScaffold extends StatefulWidget {
  final UserRole role;
  const _RoleScaffold({required this.role});

  @override
  State<_RoleScaffold> createState() => _RoleScaffoldState();
}

class _RoleScaffoldState extends State<_RoleScaffold> {
  int _currentIndex = 0;

  // التبويبات حسب الدور — كل تبويب ملفوف بالكيوبت تبعو فقط
  late final List<Widget> _screens = _buildScreens();
  late final List<Icon> _icons = _buildIcons();

  List<Widget> _buildScreens() {
    switch (widget.role) {
      case UserRole.student:
        return [
          BlocProvider(
            create: (_) => di<StudentCubit>()..loadStudentData(),
            child: const StudentDashboard(),
          ),
        ];
      case UserRole.guardian:
        return [
          BlocProvider(
            create: (_) => di<GuardianCubit>()..loadChildren(),
            child: const GuardianPage(),
          ),
        ];
      case UserRole.unknown:
        return [
          const Center(child: Text('دور غير مدعوم')),
        ];
    }
  }

  List<Icon> _buildIcons() {
    final cs = Theme.of(context).colorScheme;
    switch (widget.role) {
      case UserRole.student:
        return [Icon(Icons.home_rounded, color: cs.onPrimary, size: 26)];
      case UserRole.guardian:
        return [Icon(Icons.groups_rounded, color: cs.onPrimary, size: 26)];
      case UserRole.unknown:
        return [Icon(Icons.error_outline_rounded, color: cs.onPrimary, size: 26)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        // نخفي الشريط لو في تبويب واحد بس (لسا ما زدنا غيرو)
        bottomNavigationBar: _screens.length < 2
            ? null
            : CurvedNavigationBar(
                index: _currentIndex,
                height: 60,
                backgroundColor: Colors.transparent,
                color: cs.primary,
                buttonBackgroundColor: cs.primaryContainer,
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                onTap: (i) => setState(() => _currentIndex = i),
                items: _icons,
              ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
    );
  }
}
