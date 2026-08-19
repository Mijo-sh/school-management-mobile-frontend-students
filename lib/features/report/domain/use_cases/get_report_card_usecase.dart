import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/report_card.dart';
import '../repositories/report_card_repository.dart';

class GetReportCardUseCase {
  final ReportCardRepository repository;
  const GetReportCardUseCase({required this.repository});

  Future<Either<Failure, ReportCard>> call(
      {int? studentId, int? reportCardId}) {
    return repository.getReportCard(
        studentId: studentId, reportCardId: reportCardId);
  }
}