import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alert_item.dart';
import '../repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;
  const GetAlertsUseCase({required this.repository});

  /// [studentId] اختياري: null = تنبيهات المستخدم الحالي (طالب)،
  /// موجود = تنبيهات ابن معيّن (ولي أمر).
  Future<Either<Failure, List<AlertItem>>> call({int? studentId}) {
    return repository.getAlerts(studentId: studentId);
  }
}
