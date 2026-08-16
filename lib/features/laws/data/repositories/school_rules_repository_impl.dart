// lib/features/school_rules/data/repositories/school_rules_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/school_rule.dart';
import '../../domain/repositories/school_rules_repository.dart';
import '../data_sources/local/school_rules_local_data_source.dart';
import '../data_sources/remote/school_rules_remote_data_source.dart';

class SchoolRulesRepositoryImpl implements SchoolRulesRepository {
  final SchoolRulesRemoteDataSource remoteDataSource;
  final SchoolRulesLocalDataSource localDataSource;

  SchoolRulesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<SchoolRule>>> getSchoolRules() async {
    try {
      // 1. محاولة جلب البيانات من الـ API
      final remoteRules = await remoteDataSource.getSchoolRules();

      // 2. تخزين البيانات بنجاح محلياً للاستخدام لاحقاً[cite: 9]
      await localDataSource.cacheSchoolRules(remoteRules);

      return Right(remoteRules);
    } on ServerException catch (e) {
      // في حال فشل السيرفر، نحاول جلب آخر نسخة مخزنة محلياً
      try {
        final localRules = await localDataSource.getLastSchoolRules();
        return Right(localRules);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on UnexpectedException catch (e) {
      try {
        final localRules = await localDataSource.getLastSchoolRules();
        return Right(localRules);
      } on CacheException {
        return Left(UnExpectedFailure(e.message));
      }
    } catch (_) {
      try {
        final localRules = await localDataSource.getLastSchoolRules();
        return Right(localRules);
      } on CacheException {
        return  Left(UnExpectedFailure());
      }
    }
  }
}