import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/announcement_item.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementRepository repository;
  const GetAnnouncementsUseCase({required this.repository});

  Future<Either<Failure, List<AnnouncementItem>>> call({int? studentId}) {
    return repository.getAnnouncements(studentId: studentId);
  }
}
