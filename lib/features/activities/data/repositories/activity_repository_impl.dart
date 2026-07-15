import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../data_sources/local/activity_local_data_source.dart';
import '../data_sources/remote/activity_remote_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final ActivityLocalDataSource localDataSource;
  const ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<ActivityItem>>> getActivities({int? studentId}) async {
    try {
      final result = await remoteDataSource.getActivities(studentId: studentId);

      try {
        await localDataSource.cacheActivities(result, studentId: studentId);
      } catch (_) {}

      return Right(result);
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedActivities(studentId: studentId);
        return Right(cached);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
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
