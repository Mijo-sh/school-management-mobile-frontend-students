import 'package:dartz/dartz.dart'; // إذا كنت تستخدم Dartz لـ Either (أو استخدم استثناءات مباشرة)
import '../../../../core/errors/failures.dart'; // مسار ملف الـ Failure لديك
import '../entities/school_rule.dart';

abstract class SchoolRulesRepository {
  Future<Either<Failure, List<SchoolRule>>> getSchoolRules();
}