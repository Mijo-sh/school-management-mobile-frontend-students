import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/top_student.dart';
import '../../domain/repositories/top_students_repository.dart';
import '../data_sources/remote/top_students_remote_data_source.dart';

class TopStudentsRepositoryImpl implements TopStudentsRepository {
  final TopStudentsRemoteDataSource remoteDataSource;
  const TopStudentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TopStudent>>> getTopStudents({
    required int semesterId,
    int? studentId,
  }) async {
    try {
      final result = await remoteDataSource.getTopStudents(
        semesterId: semesterId,
        studentId: studentId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    } catch (e, st) {
      // 👇 مؤقتاً للتشخيص
      debugPrint('❌ [TopStudents] خطأ غير متوقع: $e');
      debugPrint('$st');
      return Left(UnExpectedFailure());
    }
  }
}