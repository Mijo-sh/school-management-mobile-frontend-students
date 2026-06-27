import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_card.dart';
import '../../domain/repositories/quardian_repository.dart';
import '../data_sources/remote_data_source/guardian_remote_data_source.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;
  GuardianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChildCard>>> getChildren() async {
    try {
      return Right(await remoteDataSource.getChildren());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}