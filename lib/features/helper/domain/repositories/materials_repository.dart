import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/study_material.dart';

abstract class MaterialsRepository {
  Future<Either<Failure, Paginated<StudyMaterial>>> getMaterials({int page = 1});
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, Unit>> markAllAsRead();

  /// يحمّل بيانات الملف (bytes). الحفظ بالجهاز يصير بطبقة الـ presentation.
  Future<Either<Failure, List<int>>> downloadMaterial(int materialId);
}
