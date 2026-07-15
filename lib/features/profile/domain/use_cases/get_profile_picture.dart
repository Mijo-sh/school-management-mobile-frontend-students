import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase.dart';
import '../entities/profile_picture.dart';
import '../repositories/profile_repository.dart';

class GetProfilePicture extends UseCase<ProfilePicture?, NoParams> {
  final ProfileRepository repository;

  GetProfilePicture(this.repository);

  @override
  Future<Either<Failure, ProfilePicture?>> call(NoParams params) {
    return repository.getProfilePicture();
  }
}