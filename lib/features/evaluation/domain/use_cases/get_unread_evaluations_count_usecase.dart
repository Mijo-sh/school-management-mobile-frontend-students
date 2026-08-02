import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/evaluation_repository.dart';

class GetUnreadEvaluationsCountUseCase {
  final EvaluationRepository repository;
  const GetUnreadEvaluationsCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}
