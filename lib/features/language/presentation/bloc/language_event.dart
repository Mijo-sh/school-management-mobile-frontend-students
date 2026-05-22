part of 'language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class GetLanguageEvent extends LanguageEvent{}

class ToggleLanguageEvent extends LanguageEvent {}