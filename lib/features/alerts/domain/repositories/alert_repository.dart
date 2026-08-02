import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/features/alerts/domain/entities/alert_item.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';


abstract class AlertRepository {
  Future<Either<Failure, Paginated<AlertItem>>> getAlerts({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}
