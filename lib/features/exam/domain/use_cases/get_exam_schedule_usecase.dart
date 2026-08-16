// lib/features/exam/domain/use_cases/get_exam_schedule_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exam_schedule_entity.dart';
import '../repositories/exam_schedule_repository.dart';

class GetExamScheduleUseCase {
  final ExamScheduleRepository repository;
  GetExamScheduleUseCase(this.repository);

  Future<Either<Failure, List<ExamScheduleItem>>> call({int? studentId}) {
    return repository.getExamSchedule(studentId: studentId);
  }
}
