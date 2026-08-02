import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../quiz/data/data_sources/local/practice_quizzes_local_data_source.dart';
import '../../../quiz/data/data_sources/remote/practice_quizzes_remote_data_source.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subjects_repository.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final PracticeQuizzesRemoteDataSource remoteDataSource;
  final PracticeQuizzesLocalDataSource localDataSource;

  SubjectsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SubjectEntity>>> getPracticeSubjects() async {
    try {
      // 1. محاولة جلب المواد من الـ API
      final remoteSubjects = await remoteDataSource.getPracticeSubjects();

      // 2. تكييش (حفظ) المواد محلياً لاستخدامها في وضع عدم الاتصال (Offline)
      await localDataSource.cacheSubjects(remoteSubjects);

      return Right(remoteSubjects);
    } on ServerException catch (e) {
      // 3. في حال فشل الاتصال، نقوم بالقراءة من الكاش المحلي
      try {
        final cachedSubjects = await localDataSource.getCachedSubjects();
        return Right(cachedSubjects);
      } catch (cacheError) {
        return Left(ServerFailure());
      }
    } catch (e) {
      try {
        final cachedSubjects = await localDataSource.getCachedSubjects();
        return Right(cachedSubjects);
      } catch (cacheError) {
        return Left(ServerFailure());
      }
    }
  }
}