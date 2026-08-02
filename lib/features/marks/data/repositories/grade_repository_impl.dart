import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/grade_item.dart';
import '../../domain/repositories/grade_repository.dart';
import '../data_sources/local/grade_local_data_source.dart';
import '../data_sources/remote/grade_remote_data_source.dart';
import '../models/grade_item_model.dart';

class GradeRepositoryImpl implements GradeRepository {
  final GradeRemoteDataSource remoteDataSource;
  final GradeLocalDataSource localDataSource;
  const GradeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Paginated<GradeItem>>> getGrades({int? studentId, int page = 1}) async {
    try {
      final result = await remoteDataSource.getGrades(studentId: studentId, page: page);

      if (page == 1) {
        try {
          final modelsList = result.items.cast<GradeItemModel>();
          await localDataSource.cacheGrades(modelsList, studentId: studentId);
        } catch (_) {}
      }

      return Right(Paginated<GradeItem>(
        items: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedGrades(studentId: studentId);
          return Right(Paginated<GradeItem>(
            items: cached,
            currentPage: 1,
            lastPage: 1,
          ));
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      } else {
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