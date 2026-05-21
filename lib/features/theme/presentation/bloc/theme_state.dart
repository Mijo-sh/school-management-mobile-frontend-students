part of 'theme_bloc.dart';

enum ThemeStatus {
  initial,
  loading,
  success,
  error
}

class ThemeState extends Equatable {
  final ThemeStatus status;
  final ThemeType type;
  final String? errorMessage;

  const ThemeState({
    required this.status,
    required this.type,
    this.errorMessage
  });

  factory ThemeState.initial() {
    return const ThemeState(
      status: ThemeStatus.initial,
      type: ThemeType.light
    );
  }

  ThemeState copyWith({
    ThemeStatus? status,
    ThemeType? type,
    String? errorMessage,
    bool clearError = false
  }) {
    return ThemeState(
      status: status ?? this.status,
      type: type ?? this.type,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage)
    );
  }

  @override
  List<Object?> get props => [status, type, errorMessage];
}