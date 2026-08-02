import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';

abstract class PracticeQuizzesRepository {
  Future<Either<Failure, List<QuizListItemEntity>>> getQuizzesBySubject(int subjectId);

  Future<Either<Failure, QuizDetailEntity>> getQuizDetails(int quizId);

  Future<Either<Failure, Unit>> submitQuizAnswers({
    required List<SubmitAnswerEntity> answers,
  });
  Future<Either<Failure, LastAttemptDetailsEntity>> getLastAttemptDetails(int quizId);
}