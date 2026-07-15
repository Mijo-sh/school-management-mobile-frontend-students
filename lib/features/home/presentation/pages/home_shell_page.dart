// home_shell_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/routing/route_name.dart';
import '../../../shared/domain/entities/user_role.dart';
import '../manager/main_cubit.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<MainCubit>()..loadRole(),
      child: const _HomeShellView(),
    );
  }
}

class _HomeShellView extends StatelessWidget {
  const _HomeShellView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainCubit, MainState>(
      listener: (context, state) {
        if (state is MainRoleLoaded) {
          switch (state.role) {
            case UserRole.student:
            // الانتقال المباشر لـ Dashboard الطالب داخل الـ Shell
              context.go(StudentRouteName.dashboard);
              break;
            case UserRole.guardian:
            // الانتقال لصفحة ولي الأمر
              context.go(ParentRouteName.home);
              break;
            case UserRole.unknown:
            // يمكنك التوجيه لصفحة تسجيل الدخول أو إظهار رسالة خطأ
              context.go(RouteName.logIn);
              break;
          }
        }
      },
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
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

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}