import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/app_intro/presentation/bloc/splash/splash_bloc.dart';
import '../../features/app_intro/presentation/pages/onboarding_page.dart';
import '../../features/app_intro/presentation/pages/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../injector/injector_container.dart';
import 'package:go_router/go_router.dart';
import 'route_name.dart';

class AppRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: RouteName.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => di<SplashBloc>(),
          child: const SplashPage()
        )
      ),

      GoRoute(
        path: RouteName.onboarding,
        builder: (context, state) => BlocProvider(
          create: (_) => di<OnboardingBloc>(),
          child: const OnboardingPage()
        )
      ),
    ]
  );
}