import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/errors/failures.dart';
import '../../../profile/data/models/user_mapper.dart';
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
      final message = await remoteDataSource.sendOtp(phoneNumber: phoneNumber);
      return Right(message);
    } catch (e, stackTrace) {
      debugPrint('sendOtp error: $e\n$stackTrace');
      return Left(ServerFailure(/*e.toString()*/));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> logIn(
      String phoneNumber,
      String otpCode,
      ) async {
    try {
      final remoteData = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );

      // Laravel Sanctum يرجع: { token: '...', user: {...} }
      final token = remoteData['token'] as String;
      final userData = remoteData['user'] as Map<String, dynamic>;

      await localDataSource.saveToken(token);

      final userModel = UserMapper.fromJson(userData);
      await localDataSource.cacheUser(userModel);

      // ✅ لا يوجد cast — UserModel يرث من UserEntity مباشرة
      return Right(userModel);
    } catch (e, stackTrace) {
      debugPrint('logIn error: $e\n$stackTrace');
      return Left(ServerFailure(/*e.toString()*/));
    }
  }

  @override
  Future<Either<Failure, Unit>> logOut() async {
    try {
      await localDataSource.clearSession();
      return const Right(unit);
    } catch (e, stackTrace) {
      debugPrint('logOut error: $e\n$stackTrace');
      return Left(CacheFailure(/*e.toString()*/));
    }
  }
}