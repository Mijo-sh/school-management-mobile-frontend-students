import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/practice_quizzes_repository.dart';

class GetQuizzesUnreadCountUseCase {
  final PracticeQuizzesRepository repository;

  GetQuizzesUnreadCountUseCase(this.repository);

  /// يرجّع عدد غير المقروء لكل مادة: {grade_subject_id: count}
  Future<Either<Failure, Map<int, int>>> call() {
    return repository.getUnreadCounts();
  }
}
