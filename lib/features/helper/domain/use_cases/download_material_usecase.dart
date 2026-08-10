import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/materials_repository.dart';

class DownloadMaterialUseCase {
  final MaterialsRepository repository;
  DownloadMaterialUseCase(this.repository);

  Future<Either<Failure, List<int>>> call(int materialId) {
    return repository.downloadMaterial(materialId);
  }
}
