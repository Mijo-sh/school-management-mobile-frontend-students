import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_card.dart';
import '../../domain/repositories/quardian_repository.dart';
import '../data_sources/local_data_source/guardian_local_datasource.dart';
import '../data_sources/remote_data_source/guardian_remote_data_source.dart';
import '../models/child_of_parent.dart';

class GuardianRepositoryImpl implements GuardianRepository {
  final GuardianRemoteDataSource remoteDataSource;
  final GuardianLocalDataSource localDataSource;

  GuardianRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<ChildCard>>> getChildren() async {
    try {
      // 1. جلب البيانات من الـ Remote
      final remoteList = await remoteDataSource.getChildren();

      // 2. تخزين البيانات باستخدام الدالة المخصصة (تحويل الـ Entity إلى Model داخلياً)
      // ملاحظة: تأكد أنك تحولها لـ List<ChildCardModel>
      final modelList = remoteList.map((e) => e as ChildCardModel).toList();
      await localDataSource.cacheChildren(modelList);

      return Right(remoteList);
    } on ServerException catch (e) {
      // 3. محاولة جلب البيانات من الكاش عند الفشل
      final cachedList = await localDataSource.getCachedChildren();

      if (cachedList != null) {
        return Right(cachedList); // إرجاع القائمة المسترجعة من الكاش
      }

      return Left(ServerFailure(e.message));
    }
  }
}