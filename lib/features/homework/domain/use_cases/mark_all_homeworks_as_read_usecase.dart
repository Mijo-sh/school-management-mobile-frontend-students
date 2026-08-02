import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/homework_repository.dart';

class MarkAllHomeworksAsReadUseCase {
  final HomeworkRepository repository;
  const MarkAllHomeworksAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAllAsRead(studentId: studentId);
  }
}
