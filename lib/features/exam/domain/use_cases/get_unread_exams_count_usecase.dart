// lib/features/exam/domain/use_cases/get_unread_exams_count_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exam_unread_counts.dart';
import '../repositories/exam_schedule_repository.dart';

class GetUnreadExamsCountUseCase {
  final ExamScheduleRepository repository;
  GetUnreadExamsCountUseCase(this.repository);

  /// يرجّع العدّادين مفصولين (exams + quizzes).
  Future<Either<Failure, ExamUnreadCounts>> call({int? studentId}) {
    return repository.getUnreadCounts(studentId: studentId);
  }
}
