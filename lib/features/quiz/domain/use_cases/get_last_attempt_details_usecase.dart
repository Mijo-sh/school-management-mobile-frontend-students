import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/practice_quizzes_repository.dart';

class GetLastAttemptDetailsUseCase {
  final PracticeQuizzesRepository repository;

  GetLastAttemptDetailsUseCase(this.repository);

  Future<Either<Failure, LastAttemptDetailsEntity>> call(int quizId) async {
    return await repository.getLastAttemptDetails(quizId);
  }
}