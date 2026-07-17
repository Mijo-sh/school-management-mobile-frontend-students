import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/activity_item.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository repository;
  const GetActivitiesUseCase({required this.repository});

  Future<Either<Failure, Paginated<ActivityItem>>> call({int? studentId, int page = 1}) {
    return repository.getActivities(studentId: studentId, page: page);
  }
}
