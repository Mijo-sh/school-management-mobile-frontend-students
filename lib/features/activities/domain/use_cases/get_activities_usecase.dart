import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_item.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository repository;
  const GetActivitiesUseCase({required this.repository});

  Future<Either<Failure, List<ActivityItem>>> call({int? studentId}) {
    return repository.getActivities(studentId: studentId);
  }
}
