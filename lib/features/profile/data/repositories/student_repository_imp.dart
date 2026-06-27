import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../data_sources/remote_data_source/student_remote_data_source.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;
  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AcademicInfo>> getAcademicInfo() async {
    try {
      return Right(await remoteDataSource.getAcademicInfo());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}