
import '../../../app_intro/domain/enums/user_role.dart';

class UserEntity {
  final String id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final DateTime? birthDate;
  final String photoUrl;
  final String address;
  final String gender;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    this.birthDate,
    required this.photoUrl,
    required this.address,
    required this.gender,
    required this.role,
  });

  String get fullName => '$firstName $lastName';
}