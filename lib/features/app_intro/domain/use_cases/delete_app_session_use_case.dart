import '../repositories/app_session_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class DeleteAppSessionUseCase {
  final AppSessionRepository repository;

  DeleteAppSessionUseCase({required this.repository});

  Future<Either<Failure, Unit>> call() async {
    return await repository.deleteSession();
  }
}