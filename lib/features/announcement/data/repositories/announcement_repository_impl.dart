import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/announcement_item.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../data_sources/local/announcement_local_data_source.dart';
import '../data_sources/remote/announcement_remote_data_source.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;
  const AnnouncementRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AnnouncementItem>>> getAnnouncements({int? studentId}) async {
    try {
      final result = await remoteDataSource.getAnnouncements(studentId: studentId);

      try {
        await localDataSource.cacheAnnouncements(result, studentId: studentId);
      } catch (_) {}

      return Right(result);
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedAnnouncements(studentId: studentId);
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
  Future<Either<Failure, Unit>> markAsRead({int? studentId}) async {
    try {
      await remoteDataSource.markAsRead(studentId: studentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }
}
