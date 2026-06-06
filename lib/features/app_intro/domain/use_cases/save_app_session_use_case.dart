import '../repositories/app_session_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_session.dart';
import 'package:dartz/dartz.dart';

class SaveAppSessionUseCase {
  final AppSessionRepository repository;

  SaveAppSessionUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(AppSession session) async {
    return await repository.saveSession(session);
  }
}