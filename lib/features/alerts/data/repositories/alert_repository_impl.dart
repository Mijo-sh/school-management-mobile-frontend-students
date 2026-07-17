import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../../domain/entities/alert_item.dart';
import '../../domain/repositories/alert_repository.dart';
import '../data_sources/local/alert_local_data_source.dart';
import '../data_sources/remote/alert_remote_data_source_example.dart';
import '../models/alert_item_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;
  final AlertLocalDataSource localDataSource;

  const AlertRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, Paginated<AlertItem>>> getAlerts({int? studentId, int page = 1}) async {
    try {
      // 1. جلب البيانات من السيرفر (ترجع PaginatedModel<AlertItemModel>)
      final result = await remoteDataSource.getAlerts(studentId: studentId, page: page);

      // 2. تحديث التخزين المحلي للكاش فقط في حالة طلب الصفحة الأولى
      if (page == 1) {
        try {
          // نقوم بعمل cast آمن من List<AlertItem> إلى List<AlertItemModel> لتخزينها
          final modelsList = result.items.cast<AlertItemModel>();
          await localDataSource.cacheAlerts(modelsList, studentId: studentId);
        } catch (_) {}
      }

      // 3. إرجاع النتيجة كـ Paginated<AlertItem> باستخدام 'items' 👇
      return Right(Paginated<AlertItem>(
        items: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      ));

    } on ServerException catch (e) {
      // 4. في حال فشل الاتصال بالسيرفر (مثال: انقطاع الإنترنت):
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedAlerts(studentId: studentId);
          return Right(Paginated<AlertItem>(
            items: cached,
            currentPage: 1,
            lastPage: 1, // تعتبر الصفحة الأخيرة لعدم إمكانية تحميل المزيد أوفلاين
          ));
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      } else {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({int? studentId}) async {
    try {
      final result = await remoteDataSource.getUnreadCount(studentId: studentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead({int? studentId}) async {
    try {
      await remoteDataSource.markAsRead(studentId: studentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnExpectedFailure(e.toString()));
    }
  }
}