import 'package:equatable/equatable.dart';
import 'user_role.dart';

class UserEntity extends Equatable {
  final int id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String? motherName;
  final String? birthDate;
  final String? birthPlace;
  final String? address;
  final String? nationality;
  final String? gender;
  final String? photoUrl;
  final String? accountStatus;
  final String? recordStatus;
  final List<UserRole> roles;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.motherName,
    this.birthDate,
    this.birthPlace,
    this.address,
    this.nationality,
    this.gender,
    this.photoUrl,
    this.accountStatus,
    this.recordStatus,
    this.roles = const [],
  });

  UserRole get primaryRole =>
      roles.isNotEmpty ? roles.first : UserRole.unknown;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, phoneNumber, firstName, lastName, roles];
}