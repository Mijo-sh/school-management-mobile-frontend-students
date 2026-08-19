part of 'top_students_cubit.dart';

abstract class TopStudentsState extends Equatable {
  const TopStudentsState();
  @override
  List<Object?> get props => [];
}

class TopStudentsInitial extends TopStudentsState {}

class TopStudentsLoading extends TopStudentsState {}

class TopStudentsLoaded extends TopStudentsState {
  final List<TopStudent> students;
  const TopStudentsLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

class TopStudentsError extends TopStudentsState {
  final String message;
  const TopStudentsError(this.message);
  @override
  List<Object?> get props => [message];
}