import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/announcement_repository.dart';

class MarkAnnouncementAsReadUseCase {
  final AnnouncementRepository repository;
  const MarkAnnouncementAsReadUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({int? studentId}) {
    return repository.markAsRead(studentId: studentId);
  }
}
