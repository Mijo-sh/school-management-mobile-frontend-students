import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/activity_item.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<ActivityItem>>> getActivities({int? studentId});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}
