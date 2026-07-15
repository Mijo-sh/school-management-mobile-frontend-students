import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String phoneNumber,
    required String otp,
  }) async {
    if (otp.trim().isEmpty) {
      return const Left(ValidationFailure('الرجاء إدخال رمز التحقق'));
    }
    return repository.login(phoneNumber: phoneNumber.trim(), otp: otp.trim());
  }
}