part of 'main_cubit.dart';

abstract class MainState extends Equatable {
  const MainState();
  @override
  List<Object?> get props => [];
}

class MainInitial extends MainState {
  const MainInitial();
}

class MainLoading extends MainState {
  const MainLoading();
}

class MainRoleLoaded extends MainState {
  final UserRole role;
  const MainRoleLoaded(this.role);
  @override
  List<Object?> get props => [role];
}

class MainError extends MainState {
  final String message;
  const MainError(this.message);
  @override
  List<Object?> get props => [message];
}
