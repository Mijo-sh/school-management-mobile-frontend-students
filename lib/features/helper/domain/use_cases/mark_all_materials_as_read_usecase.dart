import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/materials_repository.dart';

class MarkAllMaterialsAsReadUseCase {
  final MaterialsRepository repository;
  MarkAllMaterialsAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.markAllAsRead();
}
