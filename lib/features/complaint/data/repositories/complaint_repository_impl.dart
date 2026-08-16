// lib/features/complaint/data/repositories/complaint_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/complaint_entities.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../data_sources/complaint_remote_data_source.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  const ComplaintRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ComplaintCategory>>> getOptions() async {
    try {
      final result = await remoteDataSource.getOptions();
      return Right(result);
    } on ServerException catch (e) {
      print('⚠️ [REPOSITORY getOptions] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      print('⚠️ [REPOSITORY getOptions] UnexpectedException: ${e.message}');
      return Left(UnExpectedFailure(e.message));
    } catch (e) {
      print('❌ [REPOSITORY getOptions] General Catch Error: $e');
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Complaint>>> getComplaints(int studentId) async {
    try {
      final result = await remoteDataSource.getComplaints(studentId);
      return Right(result);
    } on ServerException catch (e) {
      print('⚠️ [REPOSITORY getComplaints] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      print('⚠️ [REPOSITORY getComplaints] UnexpectedException: ${e.message}');
      return Left(UnExpectedFailure(e.message));
    } catch (e) {
      print('❌ [REPOSITORY getComplaints] General Catch Error: $e');
      return  Left(UnExpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createComplaint(ComplaintToCreate complaint) async {
    try {
      await remoteDataSource.createComplaint(complaint);
      return const Right(unit);
    } on ServerException catch (e) {
      // 🔍 تتبع خطأ السيرفر أثناء الإضافة
      print('⚠️ [REPOSITORY createComplaint] ServerException message: ${e.message}');
      return Left(ServerFailure(e.message));
    } on UnexpectedException catch (e) {
      print('⚠️ [REPOSITORY createComplaint] UnexpectedException: ${e.message}');
      return Left(UnExpectedFailure(e.message));
    } catch (e) {
      // ❌ إذا ظهرت هذه الطباعة، فهعني أن الخطأ ليس ServerException بل خطأ برمجي أو بارسنغ غير متوقع!
      print('❌ [REPOSITORY createComplaint] General Catch Error (Here is where message is lost!): $e');
      return  Left(UnExpectedFailure());
    }
  }
}