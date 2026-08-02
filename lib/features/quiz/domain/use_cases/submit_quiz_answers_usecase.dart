import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/practice_quizzes_repository.dart';

class SubmitQuizAnswersUseCase {
  final PracticeQuizzesRepository repository;

  SubmitQuizAnswersUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required List<SubmitAnswerEntity> answers}) async {
    return await repository.submitQuizAnswers(answers: answers);
  }
}