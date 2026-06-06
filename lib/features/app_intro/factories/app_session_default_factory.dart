import '../data/models/app_session_model.dart';

class AppSessionDefaultFactory {
  static AppSessionModel create() {
    return const AppSessionModel(
      isAuthenticated: false,
      isOnboardingCompleted: false,
      isPicChoose: false,
      token: null,
      tokenExpiresAt: null,
      role: null
    );
  }
}