import '../../../shared/domain/entities/user_role.dart';
import '../../domain/entities/app_session.dart';
import 'dart:convert';

class AppSessionModel extends AppSession {
  const AppSessionModel({
    required super.isOnboardingCompleted,
    required super.isPicChoose,
    super.token,
    super.tokenExpiresAt,
    super.role
  });

  factory AppSessionModel.fromEntity(AppSession entity) {
    return AppSessionModel(
      isOnboardingCompleted: entity.isOnboardingCompleted,
      isPicChoose: entity.isPicChoose,
      token: entity.token,
      tokenExpiresAt: entity.tokenExpiresAt,
      role: entity.role
    );
  }

  factory AppSessionModel.fromJson(Map<String, dynamic> json) {
    return AppSessionModel(
      isOnboardingCompleted: json['isOnboardingCompleted'],
      isPicChoose: json['isPicChoose'],
      token: json['token'],
      tokenExpiresAt: json['tokenExpiresAt'] != null ? DateTime.parse(json['tokenExpiresAt']) : null,
      role: json['role'] != null ? UserRole.fromString(json['role']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOnboardingCompleted': isOnboardingCompleted,
      'isPicChoose': isPicChoose,
      'token': token,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
      'role': role?.name
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppSessionModel.fromJsonString(String source) =>
    AppSessionModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}