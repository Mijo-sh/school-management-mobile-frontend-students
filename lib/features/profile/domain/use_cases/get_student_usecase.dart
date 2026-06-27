import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class GetAcademicInfoUsecase {
  final StudentRepository repository;
  GetAcademicInfoUsecase(this.repository);

  Future<Either<Failure, AcademicInfo>> call() =>
      repository.getAcademicInfo();
}