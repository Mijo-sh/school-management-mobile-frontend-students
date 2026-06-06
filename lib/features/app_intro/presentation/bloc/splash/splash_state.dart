part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

final class SplashInitial extends SplashState {}

class LoadingSplashState extends SplashState {}

class NavigateSplashState extends SplashState {
  final SplashDecision decision;

  const NavigateSplashState({required this.decision});

  @override
  List<Object> get props => [decision];
}

class ErrorSplashState extends SplashState {
  final String message;

  const ErrorSplashState({required this.message});

  @override
  List<Object> get props => [message];
}