import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alert_item.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<AlertItem>>> getAlerts({int? studentId});

  /// endpoint خفيف لحاله — بس رقم، للاستخدام بالبادج فوق كارد Alerts.
  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}
