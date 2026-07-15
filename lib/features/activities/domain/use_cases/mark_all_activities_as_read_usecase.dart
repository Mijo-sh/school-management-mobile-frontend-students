import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/activity_repository.dart';

class MarkAllActivitiesAsReadUseCase {
  final ActivityRepository repository;
  const MarkAllActivitiesAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAllAsRead(studentId: studentId);
  }
}
