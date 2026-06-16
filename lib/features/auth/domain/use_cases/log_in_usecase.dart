
import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/features/profile/domain/entities/user_entity.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
class VerifyOtpParams {
  final String phoneNumber;
  final String otpCode;

  const VerifyOtpParams({
    required this.phoneNumber,
    required this.otpCode,
  });
}
class LoginUseCase  {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params ) async{
    return await repository.logIn(params.phoneNumber, params.otpCode);
  }
}

