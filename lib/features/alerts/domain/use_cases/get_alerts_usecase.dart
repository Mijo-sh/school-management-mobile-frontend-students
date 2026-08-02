import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/features/alerts/domain/entities/alert_item.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../repositories/alert_repository.dart';

// 1. سننشئ كلاس بسيط لتمثيل نتيجة الصفحات بدون كسر الـ Models المعقدة 👇


class GetAlertsUseCase {
  final AlertRepository repository;
  const GetAlertsUseCase({required this.repository});
  Future<Either<Failure, Paginated<AlertItem>>> call({int? studentId, int page = 1}) {
    return repository.getAlerts(studentId: studentId, page: page);
  }
}
