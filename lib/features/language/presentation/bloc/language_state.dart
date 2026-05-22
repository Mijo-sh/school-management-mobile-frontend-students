part of 'language_bloc.dart';

enum LanguageStatus {
  initial,
  loading,
  success,
  error
}

class LanguageState extends Equatable {
  final LanguageStatus status;
  final LanguageType type;
  final String? errorMessage;

  const LanguageState({
    required this.status,
    required this.type,
    this.errorMessage
  });

  factory LanguageState.initial() {
    return const LanguageState(
      status: LanguageStatus.initial,
      type: LanguageType.ar
    );
  }

  LanguageState copyWith({
    LanguageStatus? status,
    LanguageType? type,
    String? errorMessage,
    bool clearError = false
  }) {
    return LanguageState(
      status: status ?? this.status,
      type: type ?? this.type,
      errorMessage: clearError? null : (errorMessage ?? this.errorMessage)
    );
  }

  @override
  List<Object?> get props => [status, type, errorMessage];
}