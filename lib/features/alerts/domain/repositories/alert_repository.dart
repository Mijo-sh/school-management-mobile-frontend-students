import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';


abstract class AlertRepository {
  Future<Either<Failure, Paginated>> getAlerts({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}
