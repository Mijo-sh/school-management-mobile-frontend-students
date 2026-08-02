import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/evaluation_item.dart';

abstract class EvaluationRepository {
  Future<Either<Failure, Paginated<EvaluationItem>>> getEvaluations({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}
