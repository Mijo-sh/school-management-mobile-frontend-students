import '../../../../../core/notifications/domain/use_cases/ensure_fcm_token_usecase.dart';
import '../../../../../core/notifications/domain/use_cases/put_fcmtoken_usecase.dart';
import '../../../domain/use_cases/get_app_session_use_case.dart';
import '../../../domain/services/app_entry_decider.dart';
import '../../../domain/enums/splash_decision.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetAppSessionUseCase getAppSession;
  final AppEntryDecider decider;
  final EnsureFcmTokenUseCase ensureFcmToken;
  final PutFcmTokenUseCase putFcmToken;

  SplashBloc({
    required this.getAppSession,
    required this.decider,
    required this.ensureFcmToken,
    required this.putFcmToken
  }) : super(SplashInitial()) {
    on<GetAppSessionSplashEvent>(_onGetAppSession);
  }

  Future<void> _onGetAppSession(
    GetAppSessionSplashEvent event,
    Emitter<SplashState> emit
    ) async {
    emit(LoadingSplashState());
    try {
      final fcmToken = await ensureFcmToken();
      print("FCM Token في مرحلة الـ Splash: $fcmToken");

      final sessionOrFailure = await getAppSession();

      await sessionOrFailure.fold(
            (failure) async {
          emit(const ErrorSplashState(message: 'فشلت عملية جلب البيانات المحلية'));
        },
            (session) async {

          if (session.isAuthenticated && fcmToken != null) {
            await putFcmToken(fcmToken);
          }

          final decision = decider.decide(session);
          emit(NavigateSplashState(decision: decision));
        },
      );
    } catch (e) {
      emit(const ErrorSplashState(message: 'حدث خطأ غير متوقع أثناء التهيئة'));
    }
  }
}
