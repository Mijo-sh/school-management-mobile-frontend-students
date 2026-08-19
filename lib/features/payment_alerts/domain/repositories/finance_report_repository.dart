import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/finance_report.dart';

abstract class FinanceReportRepository {
  Future<Either<Failure, FinanceReport>> getReport({required int studentId});
}