import '../repositories/app_session_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class CompleteOnboardingUseCase {
  final AppSessionRepository repository;

  CompleteOnboardingUseCase({required this.repository});

  Future<Either<Failure, Unit>> call() async {
    return await repository.completeOnboarding();
  }
}