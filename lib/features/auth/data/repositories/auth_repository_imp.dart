import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/local_data_source/auth_local_data_source.dart';
import '../data_sources/remote_data_source/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
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

// 👇 طباعة للتأكد
      print('🔑 TOKEN RECEIVED: $token');

      await localDataSource.cacheToken(token);
      await localDataSource.cacheUser(user);

// 👇 نقرا التوكن مرة تانية من التخزين للتأكد إنو انخزن فعلاً
      final savedToken = await localDataSource.getToken();
      print('💾 TOKEN FROM STORAGE: $savedToken');

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clear();
      return const Right(unit);
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
}