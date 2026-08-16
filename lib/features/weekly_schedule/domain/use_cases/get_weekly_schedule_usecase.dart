import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entry.dart';
import '../repositories/schedule_repository.dart';

class GetWeeklyScheduleUseCase {
  final ScheduleRepository repository;
  GetWeeklyScheduleUseCase(this.repository);

  Future<Either<Failure, WeeklySchedule>> call(int? studentId) {
    return repository.getWeeklySchedule(studentId);
  }
}
