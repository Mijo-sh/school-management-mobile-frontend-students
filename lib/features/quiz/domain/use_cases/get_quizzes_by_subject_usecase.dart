import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/quiz_entity.dart';
import '../repositories/practice_quizzes_repository.dart';

class GetQuizzesBySubjectUseCase {
  final PracticeQuizzesRepository repository;

  GetQuizzesBySubjectUseCase(this.repository);

  Future<Either<Failure, List<QuizListItemEntity>>> call(int subjectId) async {
    return await repository.getQuizzesBySubject(subjectId);
  }
}