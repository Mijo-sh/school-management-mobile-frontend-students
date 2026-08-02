import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/evaluation_repository.dart';

class MarkAllEvaluationsAsReadUseCase {
  final EvaluationRepository repository;
  const MarkAllEvaluationsAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAllAsRead(studentId: studentId);
  }
}
