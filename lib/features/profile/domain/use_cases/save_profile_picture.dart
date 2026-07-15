import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase.dart';
import '../entities/profile_picture.dart';
import '../repositories/profile_repository.dart';

class SaveProfilePicture
    extends UseCase<ProfilePicture, SaveProfilePictureParams> {
  final ProfileRepository repository;

   SaveProfilePicture(this.repository);

  @override
  Future<Either<Failure, ProfilePicture>> call(
    SaveProfilePictureParams params,
  ) {
    return repository.saveProfilePicture(params.image);
  }
}

class SaveProfilePictureParams extends Equatable {
  final File image;

  const SaveProfilePictureParams(this.image);

  @override
  List<Object?> get props => [image.path];
}
