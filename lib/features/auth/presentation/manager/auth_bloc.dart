// presentation/manager/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/use_cases/log_in_usecase.dart';
import '../../domain/use_cases/send_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase sendOtpUsecase;
  final LoginUseCase loginUseCase;
  AuthBloc({
    required this.sendOtpUsecase,
    required this.loginUseCase,
  }) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
  }

  Future<void> _onSendOtp(
      SendOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(SendOtpLoading());

    final result = await sendOtpUsecase(event.phoneNumber);

    result.fold(
          (failure) => emit(SendOtpFailure(failure.message)),
          (message) => emit(SendOtpSuccess(message)),
    );
  }

  Future<void> _onVerifyOtp(
      VerifyOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(VerifyOtpLoading());

    final result = await loginUseCase(
      VerifyOtpParams(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      ),
    );

    result.fold(
          (failure) => emit(VerifyOtpFailure(failure.message)),
          (user) => emit(VerifyOtpSuccess(user)),
    );
  }
}