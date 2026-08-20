import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/report_card_repository.dart';

class MarkAllReportCardAsReadUseCase {
  final ReportCardRepository repository;
  const MarkAllReportCardAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAllAsRead(studentId: studentId);
  }
}