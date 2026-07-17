import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/announcement_item.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementRepository repository;
  const GetAnnouncementsUseCase({required this.repository});
  Future<Either<Failure, Paginated<AnnouncementItem>>> call({int? studentId, int page = 1}) {
    return repository.getAnnouncements(studentId: studentId, page: page);
  }
}
