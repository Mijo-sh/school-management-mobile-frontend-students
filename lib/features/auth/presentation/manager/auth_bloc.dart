import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/use_cases/log_in_usecase.dart';
import '../../domain/use_cases/resend_otp_usecase.dart';
import '../../domain/use_cases/send_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SendOtpUsecase sendOtpUsecase;
  final ResendOtpUsecase resendOtpUsecase;

  AuthBloc({
    required this.loginUseCase,
    required this.sendOtpUsecase,
    required this.resendOtpUsecase,
  }) : super(const AuthInitial()) {
    on<SendOtpRequested>(_onSendOtp);
    on<LoginRequested>(_onLogin);
    on<ResendOtpRequested>(_onResendOtp);
  }

  Future<void> _onSendOtp(
      SendOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await sendOtpUsecase(event.phoneNumber);
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (message) => emit(OtpSentSuccess(message)),
    );
  }

  Future<void> _onLogin(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
    );
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(LoginSuccess(user)),
    );
  }
  Future<void> _onResendOtp(
      ResendOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await resendOtpUsecase(event.phoneNumber);
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (message) => emit(OtpSentSuccess(message)),
    );
  }
}