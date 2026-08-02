import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/homework_repository.dart';

class GetUnreadHomeworksCountUseCase {
  final HomeworkRepository repository;
  const GetUnreadHomeworksCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}
