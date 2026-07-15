import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/activity_repository.dart';

class GetUnreadActivitiesCountUseCase {
  final ActivityRepository repository;
  const GetUnreadActivitiesCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}
