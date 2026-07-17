import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class GetProfilePhotoUrlUseCase {
  final ProfileRepository repository;
  const GetProfilePhotoUrlUseCase({required this.repository});

  Future<Either<Failure, String?>> call({int? studentId}) {
    return repository.getPhotoUrl(studentId: studentId);
  }
}
