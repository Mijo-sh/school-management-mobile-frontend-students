import 'route_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: RouteName.splash,
        builder: (context, state) => Placeholder()
      ),

      GoRoute(
        path: RouteName.onboarding,
        builder: (context, state) => Placeholder()
      ),
    ]
  );
}