import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    super.fatherName,
    super.motherName,
    super.birthDate,
    super.birthPlace,
    super.address,
    super.nationality,
    super.gender,
    super.photoUrl,
    super.accountStatus,
    super.recordStatus,
    super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['roles'] as List<dynamic>? ?? [];
    return UserModel(
      id: json['id'] as int,
      phoneNumber: json['phone_number']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      birthDate: json['birth_date']?.toString(),
      birthPlace: json['birth_place']?.toString(),
      address: json['address']?.toString(),
      nationality: json['nationality']?.toString(),
      gender: json['gender']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      accountStatus: json['account_status']?.toString(),
      recordStatus: json['record_status']?.toString(),
      roles: rolesJson
          .map((e) => UserRole.fromString(e.toString()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone_number': phoneNumber,
    'first_name': firstName,
    'last_name': lastName,
    'father_name': fatherName,
    'mother_name': motherName,
    'birth_date': birthDate,
    'birth_place': birthPlace,
    'address': address,
    'nationality': nationality,
    'gender': gender,
    'photo_url': photoUrl,
    'account_status': accountStatus,
    'record_status': recordStatus,
    'roles': roles.map((e) => e.name).toList(),
  };
}