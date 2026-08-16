import 'package:dartz/dartz.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/schedule_entry.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../data_sources/local/schedule_local_data_source .dart';
import '../data_sources/remote/schedule_remote_data_source.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final ScheduleLocalDataSource localDataSource;

  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, WeeklySchedule>> getWeeklySchedule(int? studentId) async {
    try {
      final schedule = await remoteDataSource.getWeeklySchedule(studentId);
      try {
        await localDataSource.cacheWeekly(studentId, schedule);
      } catch (_) {}
      return Right(schedule);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
      // } on EmptyCacheException {
      //   return Left(ServerFailure(e.message));
      // } on CacheException {
      //   return Left(ServerFailure(e.message));
      // }
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, WeeklySchedule>> getTomorrowSchedule(int? studentId) async {
    try {
      final schedule = await remoteDataSource.getTomorrowSchedule(studentId);
      return Right(schedule);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return Left(UnExpectedFailure());
    }
  }
}