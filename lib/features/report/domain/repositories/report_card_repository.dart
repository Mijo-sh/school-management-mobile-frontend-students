import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/report_card.dart';

/// حالة "لا يوجد جلاء" — تحمل رسالة الباك، وتُعرض بقلب الصفحة (مو خطأ).
class EmptyReportCardFailure extends Failure {
  final String messageText;
  EmptyReportCardFailure(this.messageText) : super(messageText);
}

abstract class ReportCardRepository {
  Future<Either<Failure, ReportCard>> getReportCard(
      {int? studentId, int? reportCardId});
  Future<Either<Failure, int>> getUnreadCount({int? studentId});
  Future<Either<Failure, Unit>> markAllAsRead({int? studentId});
}
