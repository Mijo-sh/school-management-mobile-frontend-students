import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entry.dart';
import '../repositories/schedule_repository.dart';

class GetTomorrowScheduleUseCase {
  final ScheduleRepository repository;
  GetTomorrowScheduleUseCase(this.repository);

  Future<Either<Failure, WeeklySchedule>> call(int studentId) {
    return repository.getTomorrowSchedule(studentId);
  }
}
