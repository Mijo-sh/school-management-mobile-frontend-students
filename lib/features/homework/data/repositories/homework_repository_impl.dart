import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/homework_item.dart';
import '../../domain/repositories/homework_repository.dart';
import '../data_sources/local_datasource/homework_local_data_source.dart';
import '../data_sources/remote_datasource/homework_remote_data_source.dart';
import '../models/homework_item_model.dart';

class HomeworkRepositoryImpl implements HomeworkRepository {
  final HomeworkRemoteDataSource remoteDataSource;
  final HomeworkLocalDataSource localDataSource;

  const HomeworkRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Paginated<HomeworkItem>>> getHomeworks({int? studentId, int page = 1}) async {
    try {
      final result = await remoteDataSource.getHomeworks(studentId: studentId, page: page);

      if (page == 1) {
        try {
          await localDataSource.cacheHomeworks(
            List<HomeworkItemModel>.from(result.items),
            studentId: studentId,
          );
        } catch (_) {}
      }

      return Right(result);
    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedHomeworks(studentId: studentId);
          return Right(Paginated(items: cached, currentPage: 1, lastPage: 1));
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({int? studentId}) async {
    try {
      final result = await remoteDataSource.getUnreadCount(studentId: studentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead({int? studentId}) async {
    try {
      await remoteDataSource.markAllAsRead(studentId: studentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }
}
