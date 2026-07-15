import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_picture.dart';

abstract class ProfileRepository {

  Future<Either<Failure, ProfilePicture>> saveProfilePicture(File image);
  Future<Either<Failure, ProfilePicture?>> getProfilePicture();
  Future<Either<Failure, void>> deleteProfilePicture();
}
