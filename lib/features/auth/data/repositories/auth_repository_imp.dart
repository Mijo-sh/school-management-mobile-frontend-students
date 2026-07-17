import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/local_data_source/auth_local_data_source.dart';
import '../data_sources/remote_data_source/auth_remote_datasource.dart';
import '../../../app_intro/domain/repositories/app_session_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AppSessionRepository sessionRepository;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.sessionRepository,
  });

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      return Right(await remoteDataSource.sendOtp(phoneNumber));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> resendOtp(String phoneNumber) async {
    try {
      return Right(await remoteDataSource.resendOtp(phoneNumber));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final (user, token) = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      await _saveTokenToSession(token, user);
      await localDataSource.cacheUser(user);

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  Future<void> _saveTokenToSession(String token, UserEntity user) async {
    final sessionResult = await sessionRepository.getSession();

    await sessionResult.fold(
          (failure) async {
        throw CacheException();
      },
          (currentSession) async {
        final updated = currentSession.copyWith(
          token: token,
          role: user.primaryRole,
          tokenExpiresAt: DateTime.now().add(const Duration(days: 365)),
        );
        final saveResult = await sessionRepository.saveSession(updated);
        saveResult.fold(
              (failure) => throw CacheException(),
              (_) {},
        );
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clear();
      await sessionRepository.deleteSession();

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      return Right(await localDataSource.getUser());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<void> sendFcmToken(String fcmToken) {
    // TODO: implement sendFcmToken
    throw UnimplementedError();
  }
}