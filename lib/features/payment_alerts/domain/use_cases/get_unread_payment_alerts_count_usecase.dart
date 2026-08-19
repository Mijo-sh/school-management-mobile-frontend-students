// get_unread_payment_alerts_count_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_alert_repository.dart';

class GetUnreadPaymentAlertsCountUseCase {
  final PaymentAlertRepository repository;
  const GetUnreadPaymentAlertsCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}