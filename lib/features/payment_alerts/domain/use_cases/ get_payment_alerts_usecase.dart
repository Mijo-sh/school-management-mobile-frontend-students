// get_payment_alerts_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/payment_alert_item.dart';
import '../repositories/payment_alert_repository.dart';

class GetPaymentAlertsUseCase {
  final PaymentAlertRepository repository;
  const GetPaymentAlertsUseCase({required this.repository});

  Future<Either<Failure, Paginated<PaymentAlertItem>>> call({
    int? studentId,
    int page = 1,
  }) {
    return repository.getAlerts(studentId: studentId, page: page);
  }
}