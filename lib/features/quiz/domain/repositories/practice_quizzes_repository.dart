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

  /// عدد غير المقروء لكل مادة: {grade_subject_id: count}
  Future<Either<Failure, Map<int, int>>> getUnreadCounts();

  /// تصفير كويزات مادة معيّنة.
  Future<Either<Failure, Unit>> markAllAsRead({required int subjectId});
}
