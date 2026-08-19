import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/finance_report.dart';
import '../repositories/finance_report_repository.dart';

class GetFinanceReportUseCase {
  final FinanceReportRepository repository;
  const GetFinanceReportUseCase({required this.repository});

  Future<Either<Failure, FinanceReport>> call({required int studentId}) {
    return repository.getReport(studentId: studentId);
  }
}