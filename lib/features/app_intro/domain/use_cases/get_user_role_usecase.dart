import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/user_role.dart';
import 'get_app_session_use_case.dart';

class GetUserRoleUsecase {
  final GetAppSessionUseCase getAppSession;
  GetUserRoleUsecase(this.getAppSession);

  Future<Either<Failure, UserRole>> call() async {
    final result = await getAppSession();
    return result.fold(
          (failure) => Left(failure),
          (session) => Right(session.role ?? UserRole.unknown),
    );
  }
}