// resend_otp_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUsecase {
  final AuthRepository repository;
  ResendOtpUsecase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) {
      return const Left(ValidationFailure('الرجاء إدخال رقم الهاتف'));
    }
    return repository.resendOtp(phone);
  }
}