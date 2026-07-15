// app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// استيرادات الملفات الخاصة بك
import '../../features/activities/presentation/pages/activities_page.dart';
import '../../features/announcement/presentation/pages/announcements_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/app_intro/presentation/bloc/splash/splash_bloc.dart';
import '../../features/app_intro/presentation/pages/onboarding_page.dart';
import '../../features/app_intro/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/child_shell_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/profile/domain/entities/child_card.dart';
import '../../features/profile/presentation/pages/add_picture_page.dart';
import '../../features/profile/presentation/pages/guardian.dart'; // صفحة ولي الأمر
import '../../features/profile/presentation/pages/profile_page.dart'; // صفحة الـ Dashboard للطالب
import '../../features/profile/presentation/manager/student_cubit.dart';
import '../../features/profile/presentation/manager/guardian_cubit.dart';
import '../injector/injector_container.dart';
import 'route_name.dart';
import '../../features/home/presentation/pages/student_shell.dart'; // الـ Shell الجديد
import '../../features/home/presentation/pages/services_page.dart'; // صفحة الخدمات

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter appRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteName.splash,
    routes: [
      // 1. Splash
      GoRoute(
        path: RouteName.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => di<SplashBloc>(),
          child: const SplashPage(),
        ),
      ),

      // 2. Onboarding
      GoRoute(
        path: RouteName.onboarding,
        builder: (context, state) => BlocProvider(
          create: (_) => di<OnboardingBloc>(),
          child: const OnboardingPage(),
        ),
      ),

      // 3. Login
      GoRoute(
        path: RouteName.logIn,
        builder: (context, state) => const LoginPage(),
      ),

      // 4. Add Picture
      GoRoute(
        path: RouteName.addPic,
        builder: (context, state) => const AddPicturePage(),
      ),

      // 5. Home Shell (الموجه الذكي الذي يفحص الـ Role ويوجه بالـ context.go)
      GoRoute(
        path: RouteName.homeShell,
        builder: (context, state) => const HomeShellPage(),
      ),

      // 6. صفحة ولي الأمر الرئيسية (Parent Home)
      GoRoute(
        path: ParentRouteName.home,
        builder: (context, state) => BlocProvider(
          create: (_) => di<GuardianCubit>()..loadChildren(),
          child: const GuardianPage(),
        ),
      ),

      // 7. الـ Stateful Shell Route الخاص بالطالب (للحفاظ على الـ Navigation Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StudentShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.dashboard,
                builder: (context, state) => BlocProvider(
                  create: (_) => di<StudentCubit>()..loadStudentData(),
                  child: const StudentDashboard(), // أو الـ ProfilePage حسب المسمى عندك
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.services,
                builder: (context, state) => const ServicesPage(
                  extraCards: [
                    (
                    title: 'Homework',
                    image: 'assets/images/homework.png',
                    color: Color(0xFFB07D00),
                    iconBg: Color(0xFFFEF3CD)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // نلتقط الـ ChildCard الممررة عبر الـ extra
          final childCard = state.extra as ChildCard;

          return ChildShellPage(
            navigationShell: navigationShell,
            child: childCard,
          );
        },
        branches: [
          // الفرع الأول: لوحة تحكم الابن (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ParentRouteName.childDashboard,
                builder: (context, state) {
                  final childCard = state.extra as ChildCard;
                  return BlocProvider(
                    // نمرر الـ ChildCard للـ Cubit مباشرة بدون طلب سيرفر
                    create: (_) => di<StudentCubit>()..loadFromChildCard(childCard),
                    child: const StudentDashboard(),
                  );
                },
              ),
            ],
          ),
          // الفرع الثاني: خدمات الابن (Services)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ParentRouteName.childServices,
                builder: (context, state) {
                  final childCard = state.extra as ChildCard;
                  return ServicesPage(
                    studentId: childCard.id,
                    childName: childCard.fullName,
                    extraCards: [
                      (
                      title: 'Financial',
                      image: 'assets/images/financial.png',
                      color: const Color(0xFF0F9D58),
                      iconBg: const Color(0xFFDDF5E8)
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteName.alerts,
        builder: (context, state) => AlertsPage(studentId: state.extra as int?),
      ),
      GoRoute(
        path: RouteName.announcements,
        builder: (context, state) => AnnouncementsPage(studentId: state.extra as int?),
      ),
      GoRoute(
        path: RouteName.activities,
        builder: (context, state) => ActivitiesPage(studentId: state.extra as int?),
      ),
    ],
  );
}