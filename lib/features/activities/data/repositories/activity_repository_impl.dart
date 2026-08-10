import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../data_sources/local/activity_local_data_source.dart';
import '../data_sources/remote/activity_remote_data_source.dart';
import '../models/activity_item_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final ActivityLocalDataSource localDataSource;
  const ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Paginated<ActivityItem>>> getActivities({int? studentId, int page = 1}) async {
    try {
      final result = await remoteDataSource.getActivities(studentId: studentId, page: page);

      if (page == 1) {
        try {
          final modelsList = result.items.cast<ActivityItemModel>();
          await localDataSource.cacheActivities(modelsList, studentId: studentId);
        } catch (_) {}
      }

      return Right(Paginated<ActivityItem>(
        items: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedActivities(studentId: studentId);
          return Right(Paginated<ActivityItem>(
            items: cached,
            currentPage: 1,
            lastPage: 1,
          ));
        } on EmptyCacheException {
          return Left(ServerFailure(e.message));
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
    }  on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }
}
