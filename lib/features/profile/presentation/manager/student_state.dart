part of 'student_cubit.dart';

abstract class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentLoaded extends StudentState {
  final String studentName;
  final AcademicInfo academicInfo;

  const StudentLoaded({
    required this.studentName,
    required this.academicInfo,
  });

  @override
  List<Object?> get props => [studentName, academicInfo];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);
  @override
  List<Object?> get props => [message];
}