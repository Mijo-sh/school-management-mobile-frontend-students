import '../../domain/entities/app_session.dart';
import '../../domain/enums/user_role.dart';

class AppSessionModel extends AppSession {
  const AppSessionModel({
    required super.isAuthenticated,
    required super.isOnboardingCompleted,
    required super.isPicChoose,
    super.token,
    super.tokenExpiresAt,
    super.role
  });

  factory AppSessionModel.fromEntity(AppSession entity) {
    return AppSessionModel(
      isAuthenticated: entity.isAuthenticated,
      isOnboardingCompleted: entity.isOnboardingCompleted,
      isPicChoose: entity.isPicChoose,
      token: entity.token,
      tokenExpiresAt: entity.tokenExpiresAt,
      role: entity.role
    );
  }

  factory AppSessionModel.fromJson(Map<String, dynamic> json) {
    return AppSessionModel(
      isAuthenticated: json['isAuthenticated'],
      isOnboardingCompleted: json['isOnboardingCompleted'],
      isPicChoose: json['isPicChoose'],
      token: json['token'],
      tokenExpiresAt: json['tokenExpiresAt'] != null ? DateTime.parse(json['tokenExpiresAt']) : null,
      role: json['role'] != null ? UserRole.values.byName(json['role']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAuthenticated': isAuthenticated,
      'isOnboardingCompleted': isOnboardingCompleted,
      'isPicChoose': isPicChoose,
      'token': token,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
      'role': role?.name
    };
  }
}