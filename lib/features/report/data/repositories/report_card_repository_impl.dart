import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/report_card.dart';
import '../../domain/repositories/report_card_repository.dart';
import '../data_sources/local/report_card_local_data_source.dart';
import '../data_sources/remote/report_card_remote_data_source.dart';

class ReportCardRepositoryImpl implements ReportCardRepository {
  final ReportCardRemoteDataSource remoteDataSource;
  final ReportCardLocalDataSource localDataSource;
  const ReportCardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, ReportCard>> getReportCard(
      {int? studentId, int? reportCardId}) async {
    try {
      final result = await remoteDataSource.getReportCard(
        studentId: studentId,
        reportCardId: reportCardId,
      );

      // فراغ → رسالة الباك، بدون كاش وبدون fallback
      if (result.reportCard == null) {
        return Left(EmptyReportCardFailure(result.message));
      }

      // خزّن آخر نسخة ناجحة
      try {
        await localDataSource.cacheReportCard(
          result.reportCard!,
          studentId: studentId,
          reportCardId: reportCardId,
        );
      } catch (_) {}

      return Right(result.reportCard!);
    } on ServerException catch (e) {
      // شبكة/سيرفر → fallback على الكاش
      try {
        final cached = await localDataSource.getCachedReportCard(
          studentId: studentId,
          reportCardId: reportCardId,
        );
        return Right(cached);
      } on EmptyCacheException {
        return Left(ServerFailure(e.message));
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return Left(UnExpectedFailure());
    }
  }
}