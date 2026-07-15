import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/announcement_item.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementItem>>> getAnnouncements({int? studentId});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}
