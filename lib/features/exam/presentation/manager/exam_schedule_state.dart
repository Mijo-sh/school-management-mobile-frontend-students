// lib/features/exam/presentation/manager/exam_schedule_state.dart

part of 'exam_schedule_cubit.dart';

abstract class ExamScheduleState extends Equatable {
  const ExamScheduleState();
  @override
  List<Object?> get props => [];
}

class ExamScheduleInitial extends ExamScheduleState {}

class ExamScheduleLoading extends ExamScheduleState {}

class ExamScheduleLoaded extends ExamScheduleState {
  final List<ExamScheduleItem> items;
  const ExamScheduleLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class ExamScheduleError extends ExamScheduleState {
  final String message;
  const ExamScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}
