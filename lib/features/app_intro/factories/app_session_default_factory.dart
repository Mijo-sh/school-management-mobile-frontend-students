import '../data/models/app_session_model.dart';

class AppSessionDefaultFactory {
  static AppSessionModel create() {
    return const AppSessionModel(
      isOnboardingCompleted: false,
      token: null,
      tokenExpiresAt: null,
      role: null
    );
  }
}