// domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../profile/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> logIn(String phoneNumber, String otpCode);
  Future<Either<Failure, Unit>> logOut();
}