import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../repositories/alert_repository.dart';

// 1. سننشئ كلاس بسيط لتمثيل نتيجة الصفحات بدون كسر الـ Models المعقدة 👇


class GetAlertsUseCase {
  final AlertRepository repository;
  const GetAlertsUseCase({required this.repository});
  Future<Either<Failure, Paginated>> call({int? studentId, int page = 1}) {
    return repository.getAlerts(studentId: studentId, page: page);
  }
}