// presentation/manager/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial
class AuthInitial extends AuthState {}

// Send OTP
class SendOtpLoading extends AuthState {}

class SendOtpSuccess extends AuthState {
  final String message;
  const SendOtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SendOtpFailure extends AuthState {
  final String message;
  const SendOtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Verify OTP
class VerifyOtpLoading extends AuthState {}

class VerifyOtpSuccess extends AuthState {
  final UserEntity user;
  const VerifyOtpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class VerifyOtpFailure extends AuthState {
  final String message;
  const VerifyOtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}