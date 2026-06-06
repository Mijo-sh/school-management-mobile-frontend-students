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

  SplashBloc({
    required this.getAppSession,
    required this.decider
  }) : super(SplashInitial()) {
    on<GetAppSessionSplashEvent>(_onGetAppSession);
  }

  Future<void> _onGetAppSession(
    GetAppSessionSplashEvent event,
    Emitter<SplashState> emit
    ) async {
    emit(LoadingSplashState());
    final sessionOrFailure = await getAppSession();
    sessionOrFailure.fold(
      (failure) => emit(ErrorSplashState(message: 'splash error')),
      (session) {
        final decision = decider.decide(session);
        emit(NavigateSplashState(decision: decision));
      }
    );
  }
}