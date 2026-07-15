import 'package:equatable/equatable.dart';
import '../../../shared/domain/entities/user_role.dart';

class AppSession extends Equatable {
  final bool isOnboardingCompleted;
  final bool isPicChoose;
  final String? token;
  final DateTime? tokenExpiresAt;
  final UserRole? role;

  const AppSession({
    required this.isOnboardingCompleted,
    required this.isPicChoose,
    this.token,
    this.tokenExpiresAt,
    this.role
  });

  AppSession copyWith({
    bool? isOnboardingCompleted,
    bool? isPicChoose,
    String? token,
    DateTime? tokenExpiresAt,
    UserRole? role
  }) {
    return AppSession(
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isPicChoose: isPicChoose ?? this.isPicChoose,
      token: token ?? this.token,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      role: role ?? this.role
    );
  }

  bool get isAuthenticated => token != null && !isTokenExpired;

  bool get isTokenExpired {
    if (tokenExpiresAt == null) {
      return true;
    }
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  @override
  List<Object?> get props => [
    isOnboardingCompleted,
    isPicChoose,
    token,
    tokenExpiresAt,
    role
  ];
}