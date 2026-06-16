import 'package:dartz/dartz.dart';
import 'package:school_management_mobile_frontend_students/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/errors/failures.dart';

class LogOutUsecase {
  final AuthRepository repository;

  LogOutUsecase(this.repository);
  Future<Either<Failure, Unit>> call ()async{
    return await repository.logOut();
  }



}