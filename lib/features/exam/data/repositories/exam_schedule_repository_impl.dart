// lib/features/exam/data/repositories/exam_schedule_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/exam_schedule_entity.dart';
import '../../domain/entities/exam_unread_counts.dart';
import '../../domain/repositories/exam_schedule_repository.dart';
import '../data_sources/remote/exam_schedule_remote_data_source.dart';

class ExamScheduleRepositoryImpl implements ExamScheduleRepository {
  final ExamScheduleRemoteDataSource remoteDataSource;

  const ExamScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ExamScheduleItem>>> getExamSchedule({int? studentId}) async {
    try {
      final items = await remoteDataSource.getExamSchedule(studentId: studentId);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ExamUnreadCounts>> getUnreadCounts({int? studentId}) async {
    try {
      final counts = await remoteDataSource.getUnreadCounts(studentId: studentId);
      return Right(counts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead({required ExamType type, int? studentId}) async {
    try {
      await remoteDataSource.markAllAsRead(type: type, studentId: studentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left(UnExpectedFailure(e.message));
    }
  }
}
