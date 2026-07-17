import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../data_sources/local_data_source/student_local_datasource.dart';
import '../data_sources/remote_data_source/student_remote_data_source.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;
  final StudentLocalDataSource localDataSource; // تم التعديل هنا

  StudentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AcademicInfo>> getAcademicInfo() async {
    try {
      // 1. جلب البيانات من الشبكة
      final remoteData = await remoteDataSource.getAcademicInfo();

      // 2. تخزين البيانات باستخدام الدالة المخصصة في الـ LocalDataSource
      await localDataSource.cacheAcademicInfo(remoteData as AcademicInfoModel);

      return Right(remoteData);
    } on ServerException catch (e) {
      // 3. محاولة جلب البيانات من الكاش الخاص بالطالب عند الفشل
      final localData = await localDataSource.getCachedAcademicInfo();

      if (localData != null) {
        return Right(localData);
      }

      // إذا لم يوجد كاش، نرجع الـ Failure
      return Left(ServerFailure(e.message));
    }
  }
}