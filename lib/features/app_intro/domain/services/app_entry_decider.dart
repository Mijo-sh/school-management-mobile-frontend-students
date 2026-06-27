import '../enums/splash_decision.dart';
import '../entities/app_session.dart';

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
    return SplashDecision.homeShell;
  }
}