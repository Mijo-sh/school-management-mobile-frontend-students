import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/child_card.dart';

abstract class GuardianRepository {
  Future<Either<Failure, List<ChildCard>>> getChildren();
}