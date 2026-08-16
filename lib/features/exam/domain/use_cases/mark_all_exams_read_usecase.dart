// lib/features/exam/domain/use_cases/mark_all_exams_read_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exam_schedule_entity.dart';
import '../repositories/exam_schedule_repository.dart';

class MarkAllExamsReadUseCase {
  final ExamScheduleRepository repository;
  MarkAllExamsReadUseCase(this.repository);

  /// [type] يحدّد النوع المُعلَّم كمقروء (quiz أو exam).
  Future<Either<Failure, Unit>> call({required ExamType type, int? studentId}) {
    return repository.markAllAsRead(type: type, studentId: studentId);
  }
}
