// mark_payment_alert_as_read_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_alert_repository.dart';

class MarkPaymentAlertAsReadUseCase {
  final PaymentAlertRepository repository;
  const MarkPaymentAlertAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAsRead(studentId: studentId);
  }
}