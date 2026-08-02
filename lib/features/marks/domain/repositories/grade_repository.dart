import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/grade_item.dart';

abstract class GradeRepository {
  Future<Either<Failure, Paginated<GradeItem>>> getGrades({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}