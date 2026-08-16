// lib/features/evaluation/data/repositories/evaluation_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/evaluation_item.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../data_sources/local_datasource/evaluation_local_data_source.dart';
import '../data_sources/remote_datasource/evaluation_remote_data_source.dart';
import '../models/evaluation_item_model.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationRemoteDataSource remoteDataSource;
  final EvaluationLocalDataSource localDataSource;

  const EvaluationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Paginated<EvaluationItem>>> getEvaluations({int? studentId, int page = 1}) async {
    try {
      final result = await remoteDataSource.getEvaluations(studentId: studentId, page: page);

      // نخزّن محليًا بس أول صفحة (الأحدث) — نفس منطق باقي الفيتشرز.[cite: 8]
      if (page == 1) {
        try {
          await localDataSource.cacheEvaluations(
            List<EvaluationItemModel>.from(result.items),
            studentId: studentId,
          );
        } catch (_) {}
      }

      return Right(result);
    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedEvaluations(studentId: studentId);
          return Right(Paginated(items: cached, currentPage: 1, lastPage: 1));
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      }
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({int? studentId}) async {
    try {
      final result = await remoteDataSource.getUnreadCount(studentId: studentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead({int? studentId}) async {
    try {
      await remoteDataSource.markAllAsRead(studentId: studentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }
}