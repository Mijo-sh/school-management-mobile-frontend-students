import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<Either<Failure, AcademicInfo>> getAcademicInfo();
}