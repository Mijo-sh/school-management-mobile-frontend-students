import '../repositories/app_session_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_session.dart';
import 'package:dartz/dartz.dart';

class GetAppSessionUseCase {
  final AppSessionRepository repository;

  GetAppSessionUseCase({required this.repository});

  Future<Either<Failure, AppSession>> call() async {
    return await repository.getSession();
  }
}