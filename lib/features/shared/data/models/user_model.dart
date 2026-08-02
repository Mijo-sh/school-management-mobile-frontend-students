import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.birthDate,
    required super.birthPlace,
    required super.address,
    required super.nationality,
    required super.gender,
    required super.photoUrl,
    required super.accountStatus,
    required super.recordStatus,
    required super.roles,
  });

  /* STREAMING_CHUNK: Implementing copyWith to allow direct updates to photoUrl */
  // دالة copyWith لتعديل حقول معينة بأمان (مثل رابط الصورة الشخصية) 👈
  UserModel copyWith({
    int? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? fatherName,
    String? motherName,
    String? birthDate,
    String? birthPlace,
    String? address,
    String? nationality,
    String? gender,
    String? photoUrl,
    String? accountStatus,
    String? recordStatus,
    List<UserRole>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      accountStatus: accountStatus ?? this.accountStatus,
      recordStatus: recordStatus ?? this.recordStatus,
      roles: roles ?? this.roles,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['roles'] as List<dynamic>? ?? [];
    return UserModel(
      id: json['id'] as int,
      phoneNumber: json['phone_number']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString()?? '',
      motherName: json['mother_name']?.toString()?? '',
      birthDate: json['birth_date']?.toString()?? '',
      birthPlace: json['birth_place']?.toString()?? '',
      address: json['address']?.toString()?? '',
      nationality: json['nationality']?.toString()?? '',
      gender: json['gender']?.toString()?? '',
      photoUrl: json['photo_url']?.toString()?? '',
      accountStatus: json['account_status']?.toString()?? '',
      recordStatus: json['record_status']?.toString()?? '',
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