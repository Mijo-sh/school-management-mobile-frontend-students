import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/homework_item.dart';
import '../repositories/homework_repository.dart';

class GetHomeworksUseCase {
  final HomeworkRepository repository;
  const GetHomeworksUseCase({required this.repository});

  Future<Either<Failure, Paginated<HomeworkItem>>> call({int? studentId, int page = 1}) {
    return repository.getHomeworks(studentId: studentId, page: page);
  }
}
