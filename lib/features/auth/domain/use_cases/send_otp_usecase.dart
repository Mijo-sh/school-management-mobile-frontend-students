import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/errors/failures.dart';

class SendOtpUsecase {
  final AuthRepository repository;

  SendOtpUsecase(this.repository);
  Future<Either<Failure,String>> call(String phoneNumber) async{
    return await repository.sendOtp(phoneNumber);
  }


}