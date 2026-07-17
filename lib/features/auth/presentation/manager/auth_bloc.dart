import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/notifications/domain/use_cases/put_fcmtoken_usecase.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../../domain/use_cases/log_in_usecase.dart';
import '../../domain/use_cases/log_out.dart';
import '../../domain/use_cases/resend_otp_usecase.dart';
import '../../domain/use_cases/send_otp_usecase.dart';
import '../../../../core/notifications/domain/use_cases/ensure_fcm_token_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SendOtpUsecase sendOtpUsecase;
  final ResendOtpUsecase resendOtpUsecase;
  final LogOutUsecase logOutUsecase;
  final EnsureFcmTokenUseCase ensureFcmToken;
  final PutFcmTokenUseCase putFcmToken;


  AuthBloc({
    required this.loginUseCase,
    required this.sendOtpUsecase,
    required this.resendOtpUsecase,
    required this.ensureFcmToken,
    required this.putFcmToken,
    required this.logOutUsecase,
  }) : super(const AuthInitial()) {
    on<SendOtpRequested>(_onSendOtp);
    on<LoginRequested>(_onLogin);
    on<ResendOtpRequested>(_onResendOtp);
    on<LogoutRequested>(_onLogout);
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

    await result.fold(
          (failure) async => emit(AuthError(failure.message)),
          (user) async {
        try {
          final fcmToken = await ensureFcmToken();

          if (fcmToken != null) {
            await putFcmToken(fcmToken);
            print("🔔 [AuthBloc]: تم إرسال وربط الـ FCM Token بنجاح بالسيرفر فور تسجيل الدخول.");
          }
        } catch (e) {
          print("⚠️ [AuthBloc]: فشل إرسال الـ FCM ولكن تم إكمال عملية الدخول: $e");
        }

        emit(LoginSuccess(user));
      },
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
  Future<void> _onLogout(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await logOutUsecase();

    result.fold(
            (failure) {
          // طباعة الخطأ
          print("❌ [AuthBloc]: فشل تسجيل الخروج - ${failure.message}");
          emit(AuthError(failure.message));
        },
            (_) {
          // طباعة النجاح
          print("✅ [AuthBloc]: تم تسجيل الخروج ومسح الكاش بنجاح.");
          emit(const LogoutSuccess());
        },
    );
  }
}