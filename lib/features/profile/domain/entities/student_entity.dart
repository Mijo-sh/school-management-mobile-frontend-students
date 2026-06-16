import 'package:school_management_mobile_frontend_students/features/profile/domain/entities/user_entity.dart';

class StudentEntity extends UserEntity {
  final String className;
  final String section;

  const StudentEntity({
    required super.id,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    super.birthDate,
    required super.photoUrl,
    required super.address,
    required super.gender,
    required super.role,
    required this.className,
    required this.section,
  });
}