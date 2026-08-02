import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/practice_quizzes_repository.dart';

class GetQuizDetailsUseCase {
  final PracticeQuizzesRepository repository;

  GetQuizDetailsUseCase(this.repository);

  Future<Either<Failure, QuizDetailEntity>> call(int quizId) async {
    return await repository.getQuizDetails(quizId);
  }
}