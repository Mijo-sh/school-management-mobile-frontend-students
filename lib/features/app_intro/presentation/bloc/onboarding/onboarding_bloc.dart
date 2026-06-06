import '../../../domain/use_cases/complete_onboarding_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase completeOnboarding;

  OnboardingBloc({required this.completeOnboarding}) : super(OnboardingInitial()) {
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit
    ) async {
    emit(LoadingOnboardingState());
    final completeOrFailure = await completeOnboarding();
    completeOrFailure.fold(
      (failure) => emit(ErrorOnboardingState(message: 'onboarding error')),
      (_) => emit(SuccessOnboardingState())
    );
  }
}