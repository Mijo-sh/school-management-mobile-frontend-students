// lib/features/exam/presentation/manager/exam_schedule_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/exam_schedule_entity.dart';
import '../../domain/use_cases/get_exam_schedule_usecase.dart';

part 'exam_schedule_state.dart';

/// Cubit لصفحة واحدة (مذاكرة أو امتحان حسب [type]).
/// يجلب كل الجدول ثم يفلتر النوع المطلوب.
class ExamScheduleCubit extends Cubit<ExamScheduleState> {
  final GetExamScheduleUseCase getExamSchedule;
  final ExamType type;
  final int? studentId;

  ExamScheduleCubit({
    required this.getExamSchedule,
    required this.type,
    this.studentId,
  }) : super(ExamScheduleInitial());

  Future<void> load() async {
    emit(ExamScheduleLoading());
    final result = await getExamSchedule(studentId: studentId);
    result.fold(
      (failure) => emit(ExamScheduleError(_mapFailure(failure))),
      (items) {
        final filtered = items.where((e) => e.type == type).toList();
        emit(ExamScheduleLoaded(filtered));
      },
    );
  }

  // 👇 لو عندك mapFailureToMessage جاهزة بتطبيق الطالب، استبدلي هذه بها.
  String _mapFailure(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty ? failure.message : 'خطأ من الخادم';
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }
}
