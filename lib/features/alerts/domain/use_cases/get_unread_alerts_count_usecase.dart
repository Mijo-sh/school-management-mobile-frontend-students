import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/alert_repository.dart';

class GetUnreadAlertsCountUseCase {
  final AlertRepository repository;
  const GetUnreadAlertsCountUseCase({required this.repository});

  /// [studentId] اختياري: null = عدد تنبيهات المستخدم الحالي،
  /// موجود = عدد تنبيهات ابن معيّن — مثالي للبادج فوق كارد Alerts
  /// بـ ServicesPage.
  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}
