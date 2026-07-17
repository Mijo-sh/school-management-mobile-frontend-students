import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/announcement_item.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../data_sources/local/announcement_local_data_source.dart';
import '../data_sources/remote/announcement_remote_data_source.dart';
import '../models/announcement_item_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;
  const AnnouncementRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Paginated<AnnouncementItem>>> getAnnouncements({int? studentId, int page = 1}) async {
    try {
      final result = await remoteDataSource.getAnnouncements(studentId: studentId, page: page);

      if (page == 1) {
        try {
          // الـ Cast الآمن لتوافق الـ Local DB 👈
          final modelsList = result.items.cast<AnnouncementItemModel>();
          await localDataSource.cacheAnnouncements(modelsList, studentId: studentId);
        } catch (_) {}
      }

      return Right(Paginated<AnnouncementItem>(
        items: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));

    } on ServerException catch (e) {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedAnnouncements(studentId: studentId);
          return Right(Paginated<AnnouncementItem>(
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
