import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/payment_alert_item.dart';

abstract class PaymentAlertRepository {
  Future<Either<Failure, Paginated<PaymentAlertItem>>> getAlerts({
    int? studentId,
    int page = 1,
  });

  Future<Either<Failure, int>> getUnreadCount({int? studentId});
  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}