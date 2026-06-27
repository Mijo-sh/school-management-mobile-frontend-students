part of 'guardian_cubit.dart';

abstract class GuardianState extends Equatable {
  const GuardianState();
  @override
  List<Object?> get props => [];
}

class GuardianInitial extends GuardianState {
  const GuardianInitial();
}

class GuardianLoading extends GuardianState {
  const GuardianLoading();
}

class GuardianLoaded extends GuardianState {
  final List<ChildCard> children;
  const GuardianLoaded(this.children);
  @override
  List<Object?> get props => [children];
}

class GuardianError extends GuardianState {
  final String message;
  const GuardianError(this.message);
  @override
  List<Object?> get props => [message];
}
