part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

final class OnboardingInitial extends OnboardingState {}

class LoadingOnboardingState extends OnboardingState {}

class SuccessOnboardingState extends OnboardingState {}

class ErrorOnboardingState extends OnboardingState {
  final String message;

  const ErrorOnboardingState({required this.message});

  @override
  List<Object> get props => [message];
}