import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/finance_report.dart';
import '../../domain/repositories/finance_report_repository.dart';
import '../data_sources/remote/finance_report_remote_data_source.dart';

class FinanceReportRepositoryImpl implements FinanceReportRepository {
  final FinanceReportRemoteDataSource remoteDataSource;
  const FinanceReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FinanceReport>> getReport({
    required int studentId,
  }) async {
    try {
      final result = await remoteDataSource.getReport(studentId: studentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return Left(UnExpectedFailure());
    }
  }
}