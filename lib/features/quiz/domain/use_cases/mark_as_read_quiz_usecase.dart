import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/practice_quizzes_repository.dart';

class MarkQuizzesAsReadUseCase {
  final PracticeQuizzesRepository repository;

  MarkQuizzesAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required int subjectId}) {
    return repository.markAllAsRead(subjectId:subjectId );
  }
}