part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendOtpRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const LoginRequested({required this.phoneNumber, required this.otp});
  @override
  List<Object?> get props => [phoneNumber, otp];
}
class ResendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const ResendOtpRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}