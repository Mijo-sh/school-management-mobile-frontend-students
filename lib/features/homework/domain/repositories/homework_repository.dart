import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/homework_item.dart';

abstract class HomeworkRepository {
  Future<Either<Failure, Paginated<HomeworkItem>>> getHomeworks({int? studentId, int page = 1});
  Future<Either<Failure, int>> getUnreadCount({int? studentId});
  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}
