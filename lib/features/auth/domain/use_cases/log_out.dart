import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogOutUsecase {
  final AuthRepository repository;
  LogOutUsecase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.logout();
}