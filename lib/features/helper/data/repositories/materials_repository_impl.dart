import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/study_material.dart';
import '../../domain/repositories/materials_repository.dart';
import '../data_sources/remote/materials_remote_data_source.dart';

class MaterialsRepositoryImpl implements MaterialsRepository {
  final MaterialsRemoteDataSource remoteDataSource;
  const MaterialsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Paginated<StudyMaterial>>> getMaterials({int page = 1}) async {
    try {
      final result = await remoteDataSource.getMaterials(page: page);
      return Right(Paginated<StudyMaterial>(
        items: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadMaterial(int materialId) async {
    try {
      final bytes = await remoteDataSource.downloadMaterial(materialId);
      return Right(bytes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (_) {
      return  Left(UnExpectedFailure());
    }
  }
}
