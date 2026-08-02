import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/practice_quizzes_repository.dart';
import '../data_sources/remote/practice_quizzes_remote_data_source.dart';
import '../data_sources/local/practice_quizzes_local_data_source.dart'; // تأكدِ من مسار الـ Local Data Source لديكِ

class PracticeQuizzesRepositoryImpl implements PracticeQuizzesRepository {
  final PracticeQuizzesRemoteDataSource remoteDataSource;
  final PracticeQuizzesLocalDataSource localDataSource;

  PracticeQuizzesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<QuizListItemEntity>>> getQuizzesBySubject(int subjectId) async {
    try {
      // 1. محاولة جلب الكويزات من الـ API
      final quizzes = await remoteDataSource.getQuizzesBySubject(subjectId);

      // 2. تكييش (حفظ) البيانات محلياً للرجوع إليها عند انقطاع الإنترنت
      await localDataSource.cacheQuizzes(subjectId, quizzes);

      return Right(quizzes);
    } on ServerException catch (e) {
      // 3. في حال فشل السيرفر أو انقطاع النت، نحاول الجلب من الكاش المحلي
      try {
        final cachedQuizzes = await localDataSource.getCachedQuizzes(subjectId);
        return Right(cachedQuizzes);
      } catch (cacheError) {
        return Left(ServerFailure());
      }
    } catch (e) {
      try {
        final cachedQuizzes = await localDataSource.getCachedQuizzes(subjectId);
        return Right(cachedQuizzes);
      } catch (cacheError) {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, QuizDetailEntity>> getQuizDetails(int quizId) async {
    try {
      final quizDetails = await remoteDataSource.getQuizDetails(quizId);
      return Right(quizDetails);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> submitQuizAnswers({required List<SubmitAnswerEntity> answers}) async {
    try {
      await remoteDataSource.submitQuizAnswers(answers: answers);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
  @override
  Future<Either<Failure, LastAttemptDetailsEntity>> getLastAttemptDetails(int quizId) async {
    try {
      final remoteData = await remoteDataSource.getLastAttemptDetails(quizId);

      // تحويل Model إلى Entity
      final entity = LastAttemptDetailsEntity(
        attemptSummary: LastAttemptSummaryEntity(
          attemptId: remoteData.attemptSummary.attemptId,
          totalMark: remoteData.attemptSummary.totalMark,
          earnedMark: remoteData.attemptSummary.earnedMark,
          percentage: remoteData.attemptSummary.percentage,
          solvedAt: remoteData.attemptSummary.solvedAt,
        ),
        questionsDetails: remoteData.questionsDetails.map((q) => QuestionDetailReviewEntity(
          questionId: q.questionId,
          questionText: q.questionText,
          questionMark: q.questionMark,
          isCorrect: q.isCorrect,
          selectedOptionId: q.selectedOptionId,
          selectedOptionText: q.selectedOptionText,
          correctOptionId: q.correctOptionId,
          correctOptionText: q.correctOptionText,
          allOptions: q.allOptions.map((o) => ReviewOptionEntity(
            id: o.id,
            optionText: o.optionText,
            isCorrect: o.isCorrect,
          )).toList(),
        )).toList(),
      );

      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}