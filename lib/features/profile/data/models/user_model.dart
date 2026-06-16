import '../../../app_intro/domain/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
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
  });

  // هذه الدالة لتحويل البيانات الأساسية فقط
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date']) : null,
      photoUrl: json['photo_url'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? 'male',
      role: (json['role_name'] ?? json['role_id'].toString()) == '1' || json['role_name'] == 'student'
          ? UserRole.student
          : UserRole.parent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone_number': phoneNumber,
    'first_name': firstName,
    'last_name': lastName,
    'father_name': fatherName,
    'mother_name': motherName,
    'birth_date': birthDate?.toIso8601String(),
    'photo_url': photoUrl,
    'address': address,
    'gender': gender,
    'role_name': role == UserRole.student ? 'student' : 'parent',
  };
}