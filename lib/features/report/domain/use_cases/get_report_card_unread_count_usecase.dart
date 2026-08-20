import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/report_card_repository.dart';

class GetReportCardUnreadCountUseCase {
  final ReportCardRepository repository;
  const GetReportCardUnreadCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}