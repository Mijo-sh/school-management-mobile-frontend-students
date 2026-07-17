import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/announcement_item.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, Paginated<AnnouncementItem>>> getAnnouncements({int? studentId, int page = 1});

  Future<Either<Failure, int>> getUnreadCount({int? studentId});

  Future<Either<Failure, Unit>> markAsRead({int? studentId});
}
