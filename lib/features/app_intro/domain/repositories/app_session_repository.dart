import '../../../../core/errors/failures.dart';
import '../entities/app_session.dart';
import 'package:dartz/dartz.dart';

abstract class AppSessionRepository {
  Future<Either<Failure, AppSession>> getSession();
  Future<Either<Failure, Unit>> saveSession(AppSession session);
  Future<Either<Failure, Unit>> deleteSession();
  Future<Either<Failure, Unit>> completeOnboarding();
}