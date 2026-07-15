import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, String>> resendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String otp,
  });
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserEntity?>> getCachedUser();
  Future<void> sendFcmToken(String fcmToken);

}