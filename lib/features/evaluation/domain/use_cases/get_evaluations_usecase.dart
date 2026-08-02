import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/evaluation_item.dart';
import '../repositories/evaluation_repository.dart';

class GetEvaluationsUseCase {
  final EvaluationRepository repository;
  const GetEvaluationsUseCase({required this.repository});

  Future<Either<Failure, Paginated<EvaluationItem>>> call({int? studentId, int page = 1}) {
    return repository.getEvaluations(studentId: studentId, page: page);
  }
}
