import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/alert_repository.dart';

class MarkAlertAsReadUseCase {
  final AlertRepository repository;
  const MarkAlertAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAsRead(studentId: studentId);
  }
}
