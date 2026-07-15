import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/announcement_repository.dart';

class GetUnreadAnnouncementsCountUseCase {
  final AnnouncementRepository repository;
  const GetUnreadAnnouncementsCountUseCase({required this.repository});

  Future<Either<Failure, int>> call({int? studentId}) {
    return repository.getUnreadCount(studentId: studentId);
  }
}
