import '../../../../../core/routing/route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../enums/splash_decision.dart';
import '../entities/app_session.dart';
import '../enums/user_role.dart';

class AppEntryDecider {
  SplashDecision decide(AppSession session) {
    if(!session.isOnboardingCompleted) {
      return SplashDecision.onboarding;
    }
    if(!session.isAuthenticated || session.isTokenExpired) {
      return SplashDecision.logIn;
    }
    if(!session.isPicChoose) {
      return SplashDecision.addPic;
    }
    switch(session.role) {
      case UserRole.parent:
        return SplashDecision.parentHome;
      case UserRole.student:
        return SplashDecision.studentHomeShell;
      default:
        debugPrint('error to move to home. \n user role: ${session.role}');
        return SplashDecision.logIn;
    }
  }

  void decideHandler(BuildContext context, SplashDecision decision) {
    switch(decision) {
      case SplashDecision.onboarding:
        context.go(RouteName.onboarding);
        break;
      case SplashDecision.logIn:
        context.go(RouteName.logIn);
        break;
      case SplashDecision.addPic:
        context.go(RouteName.addPic);
        break;
      case SplashDecision.studentHomeShell:
        context.go(RouteName.studentHomeShell);
        break;
      case SplashDecision.parentHome:
        context.go(RouteName.parentHome);
        break;
    }
  }
}