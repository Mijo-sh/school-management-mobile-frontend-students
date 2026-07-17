import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/activity_item.dart';

abstract class ActivityRepository {
  Future<Either<Failure, Paginated<ActivityItem>>> getActivities({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}
