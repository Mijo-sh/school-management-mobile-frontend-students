import '../../domain/repositories/app_session_repository.dart';
import '../data_sources/app_session_local_data_source.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_session.dart';
import '../../../../core/errors/failures.dart';
import '../models/app_session_model.dart';
import 'package:dartz/dartz.dart';

class AppSessionRepositoryImpl implements AppSessionRepository {
  final AppSessionLocalDataSource localDataSource;

  AppSessionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSession>> getSession() async {
    try {
      final session = await localDataSource.getCachedSession();
      return Right(session);

    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSession(AppSession session) async {
    try {
      await localDataSource.cacheSession(AppSessionModel.fromEntity(session));
      return Right(unit);

    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSession() async {
    try {
      await localDataSource.clearSession();
      return Right(unit);

    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> completeOnboarding() async {
    try {
      await localDataSource.completeOnboarding();
      return Right(unit);

    } on CacheException {
      return Left(CacheFailure());
    }
  }
}