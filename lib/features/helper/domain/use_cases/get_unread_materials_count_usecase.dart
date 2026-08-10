import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/materials_repository.dart';

class GetUnreadMaterialsCountUseCase {
  final MaterialsRepository repository;
  GetUnreadMaterialsCountUseCase(this.repository);

  Future<Either<Failure, int>> call() => repository.getUnreadCount();
}
