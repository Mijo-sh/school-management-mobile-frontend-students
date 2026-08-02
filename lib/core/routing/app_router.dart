// app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_mobile_frontend_students/features/home/presentation/widgets/drawer_help_us_page.dart';
import 'package:school_management_mobile_frontend_students/features/marks/presentation/pages/grades_page.dart';
import '../../features/activities/presentation/pages/activities_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/announcement/presentation/pages/announcements_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/app_intro/presentation/bloc/splash/splash_bloc.dart';
import '../../features/app_intro/presentation/pages/onboarding_page.dart';
import '../../features/app_intro/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/verification_page.dart';
import '../../features/evaluation/presentation/pages/evaluations_page.dart';
import '../../features/home/presentation/pages/child_shell_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/homework/presentation/pages/homeworks_page.dart';
import '../../features/laws/presentation/pages/school_rules_page.dart';
import '../../features/profile/presentation/pages/guardian.dart'; // صفحة ولي الأمر
import '../../features/profile/presentation/pages/profile_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart'; // صفحة الـ Dashboard للطالب
import '../../features/profile/presentation/manager/student_cubit.dart';
import '../../features/profile/presentation/manager/guardian_cubit.dart';
import '../../features/quiz/presentation/manager/practice_quizzes_cubit.dart';
import '../../features/quiz/presentation/pages/quiz_view_screen.dart';
import '../../features/quiz/presentation/pages/quizzes_list_screen.dart';
import '../../features/quiz/presentation/pages/subjects_screen.dart';
import '../../features/subject/presentation/manager/subjects_cubit.dart';
import '../../features/tasks/presentation/pages/random_tasks_page.dart';
import '../injector/injector_container.dart';
import 'route_name.dart';
import '../../features/home/presentation/pages/student_shell.dart'; // الـ Shell الجديد
import '../../features/home/presentation/pages/services_page.dart'; // صفحة الخدمات
import 'selected_child_holder.dart';

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


      GoRoute(
        path: RouteName.verification,
        builder: (context, state) => VerificationPage(
          phoneNumber: state.extra as String,
        ),
      ),
      GoRoute(
        path: RouteName.randomTasks,
        builder: (context, state) =>RandomTasksPage(),
      ),

      // 5. Home Shell (الموجه الذكي الذي يفحص الـ Role ويوجه بالـ context.go)
      GoRoute(
        path: RouteName.homeShell,
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: RouteName.helpUs,
        builder: (context, state) => const HelpUsPage(),
      ),
      GoRoute(
        path: RouteName.schoolRules,
        builder: (context, state) => const SchoolRulesPage(),
      ),
      GoRoute(
        path: RouteName.showprofile,
        builder: (context, state) => const ProfileDetailsPage(),
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
          // الفرع الأول: الـ Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.dashboard,
                builder: (context, state) => BlocProvider(
                  create: (_) => di<StudentCubit>()..loadStudentData(),
                  child: const StudentDashboard(),
                ),
              ),
            ],
          ),
          // الفرع الثاني: الخدمات (Services)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.services,
                builder: (context, state) => const ServicesPage(
                  extraCards: [
                    (
                    title: 'Homeworks',
                    image: 'assets/images/homework.png',
                    color: Color(0xFFB07D00),
                    iconBg: Color(0xFFFEF3CD)
                    ),
                  ],
                ),
              ),
            ],
          ),
          // الفرع الثالث: الـ AI Chat (الذي يشبه ما طلبتيه)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.aiChat,
                builder: (context, state) => const AiChatPage(),
              ),
            ],
          ),
          // 👇 الفرع الرابع الجديد: المواد التدريبية (Practice Quizzes) لتظهر بالناف بار
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: StudentRouteName.practiceSubjects,
                builder: (context, state) => BlocProvider(
                  create: (_) => di<SubjectsCubit>()..fetchSubjects(),
                  child: const SubjectsScreen(),
                ),
              )
            ],
          ),
        ],
      ),

      // 8. الـ Stateful Shell Route الخاص بابن ولي الأمر
      //
      // تنبيه: ما منستخدم state.extra هون إطلاقًا — لأنو navigationShell.goBranch()
      // (المستخدمة بـ ChildShellPage._onTap) ما بتمرر extra عند التنقل بين
      // الفروع، فـ "type 'Null' is not a subtype of 'ChildCard'" كانت
      // بتصير أول ما تضغط عالتبويب التاني. بدالها، منقرا من
      // SelectedChildHolder (singleton ثابت عبر الـ DI)، يلي بينحدّث مرة
      // وحدة بس من guardian.dart وقت الضغط على كارد الابن، وبضل صحيح بغض
      // النظر عن أي تنقل بين التبويبات.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final child = di<SelectedChildHolder>().current;
          if (child == null) {
            // احتياط أمان — ما المفروض يصير أبدًا لو التنقل صار من
            // guardian.dart بس (يلي بيحدّث الـ holder قبل التنقل مباشرة).
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return ChildShellPage(navigationShell: navigationShell, child: child);
        },
        branches: [
          // الفرع الأول: لوحة تحكم الابن (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ParentRouteName.childDashboard,
                builder: (context, state) {
                  final child = di<SelectedChildHolder>().current!;
                  return BlocProvider(
                    create: (_) => di<StudentCubit>()..loadFromChildCard(child),
                    child:  StudentDashboard(studentId: child.id,),
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
                  final child = di<SelectedChildHolder>().current!;
                  return ServicesPage(
                    studentId: child.id,
                    childName: child.fullName,
                    extraCards: [
                      (
                      title: 'Financial',
                      image: 'assets/images/financial.png',
                      color: const Color(0xFF0F9D58),
                      iconBg: const Color(0xFFDDF5E8)
                      ),
                      (
                      title: 'Homeworks',
                      image: 'assets/images/homework.png',
                      color: const Color(0xFFB07D00),
                      iconBg: const Color(0xFFFEF3CD)
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
      GoRoute(
        path: RouteName.evaluations,
        builder: (context, state) => EvaluationsPage(studentId: state.extra as int?),
      ),
      GoRoute(
        path: RouteName.homeworks,
        builder: (context, state) => HomeworksPage(studentId: state.extra as int?),
      ),
      GoRoute(
        path: RouteName.grades,
        builder: (context, state) => GradesPage(studentId: state.extra as int?),
      ),

      // 2. شاشة قائمة الكويزات للمادة (يمكن تمرير الـ subjectId و subjectName عبر extra كـ Map)
      GoRoute(
        path: StudentRouteName.practiceQuizzesList,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BlocProvider.value(
            value: args['cubit'] as PracticeQuizzesCubit,
            child: QuizzesListScreen(
              subjectName: args['subjectName'],
              subjectId: args['subjectId'],
            ),
          );
        },
      ),
      // 3. شاشة حل الاختبار
      GoRoute(
        path: StudentRouteName.practiceQuizView,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BlocProvider.value(
            value: args['cubit'] as PracticeQuizzesCubit,
            child: QuizViewScreen(
              quizTitle: args['quizTitle'],
              subjectId: args['subjectId'],
              isReviewMode: args['isReviewMode'] ?? false, // تمرير القيمة هنا بأمان
            ),
          );
        },
      ),
    ],
  );
}