part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpSentSuccess extends AuthState {
  final String message;
  const OtpSentSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class LoginSuccess extends AuthState {
  final UserEntity user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}