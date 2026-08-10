import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/paginated.dart';
import '../entities/study_material.dart';
import '../repositories/materials_repository.dart';

class GetMaterialsUseCase {
  final MaterialsRepository repository;
  GetMaterialsUseCase(this.repository);

  Future<Either<Failure, Paginated<StudyMaterial>>> call({int page = 1}) {
    return repository.getMaterials(page: page);
  }
}
