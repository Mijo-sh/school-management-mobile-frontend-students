import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exam_unread_counts.dart';
import '../entities/exam_schedule_entity.dart';

abstract class ExamScheduleRepository {
  Future<Either<Failure, List<ExamScheduleItem>>> getExamSchedule({int? studentId});
  Future<Either<Failure, ExamUnreadCounts>> getUnreadCounts({int? studentId});
  Future<Either<Failure, Unit>> markAllAsRead({required ExamType type, int? studentId});
}
