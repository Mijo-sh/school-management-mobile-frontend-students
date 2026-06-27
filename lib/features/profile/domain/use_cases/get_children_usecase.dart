import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/child_card.dart';
import '../repositories/quardian_repository.dart';

class GetChildrenUsecase {
  final GuardianRepository repository;
  GetChildrenUsecase(this.repository);

  Future<Either<Failure, List<ChildCard>>> call() =>
      repository.getChildren();
}