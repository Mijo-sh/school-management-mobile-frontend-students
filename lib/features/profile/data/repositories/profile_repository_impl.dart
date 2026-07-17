import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_picture.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/local_data_source/profile_local_data_source.dart';
import '../data_sources/remote_data_source/image_remote_data_source.dart';
import '../data_sources/remote_data_source/profile_photo_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;
  final ProfilePhotoRemoteDataSource photoRemoteDataSource; // 👈 جديد
  final NetworkInfo networkInfo;

  const ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.photoRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfilePicture>> saveProfilePicture(
    File image,
  ) async {
    final String localPath;
    try {
      localPath = await localDataSource.saveProfilePicture(image);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }

    String? remoteUrl;
    if (await networkInfo.isConnected) {
      try {
        remoteUrl = await remoteDataSource.uploadProfilePicture(image);
        await localDataSource.saveRemoteUrl(remoteUrl);
      } on ServerException {
        remoteUrl = null;
      } catch (_) {
        remoteUrl = null;
      }
    }

    return Right(ProfilePicture(localPath: localPath, remoteUrl: remoteUrl));
  }

  @override
  Future<Either<Failure, ProfilePicture?>> getProfilePicture() async {
    try {
      final localPath = await localDataSource.getProfilePicturePath();
      if (localPath == null) return const Right(null);

      final remoteUrl = await localDataSource.getRemoteUrl();
      return Right(ProfilePicture(localPath: localPath, remoteUrl: remoteUrl));
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture() async {
    try {
      await localDataSource.deleteProfilePicture();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  // 👇 الدالة الجديدة المدموجة — من فيتشر ProfilePhoto القديم
  @override
  Future<Either<Failure, String?>> getPhotoUrl({int? studentId}) async {
    try {
      final url = await photoRemoteDataSource.getPhotoUrl(studentId: studentId);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }
}
