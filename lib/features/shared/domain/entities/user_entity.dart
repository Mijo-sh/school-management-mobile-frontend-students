import 'package:equatable/equatable.dart';
import 'user_role.dart';

class UserEntity extends Equatable {
  final int id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String birthDate;
  final String birthPlace;
  final String address;
  final String nationality;
  final String gender;
  final String photoUrl;
  final String accountStatus;
  final String recordStatus;
  final List<UserRole> roles;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.birthDate,
    required this.birthPlace,
    required this.address,
    required this.nationality,
    required this.gender,
    required this.photoUrl,
    required this.accountStatus,
    required this.recordStatus,
    this.roles = const [],
  });

  UserRole get primaryRole =>
      roles.isNotEmpty ? roles.first : UserRole.unknown;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, phoneNumber, firstName, lastName, roles];
}