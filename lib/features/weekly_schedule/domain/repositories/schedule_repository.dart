import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entry.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, WeeklySchedule>> getWeeklySchedule(int? studentId);
  Future<Either<Failure, WeeklySchedule>> getTomorrowSchedule(int? studentId);
}
