import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/domain/entities/user_entity.dart';

class GetCachedUserUsecase {
  final AuthRepository repository;
  GetCachedUserUsecase(this.repository);

  Future<Either<Failure, UserEntity?>> call() => repository.getCachedUser();
}