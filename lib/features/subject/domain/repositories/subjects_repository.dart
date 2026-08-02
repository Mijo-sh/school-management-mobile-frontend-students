import 'package:dartz/dartz.dart'; // أو استخدام الـ Either الخاص بك للأخطاء
import '../../../../core/errors/failures.dart';
import '../entities/subject_entity.dart';

abstract class SubjectsRepository {
  Future<Either<Failure, List<SubjectEntity>>> getPracticeSubjects();
}