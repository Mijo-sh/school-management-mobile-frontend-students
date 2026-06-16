import '../../../app_intro/domain/enums/user_role.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

class StudentModel extends UserModel { // يرث من UserModel مباشرة
  final String className;
  final String section;

  const StudentModel({
    required super.id, required super.phoneNumber, required super.firstName,
    required super.lastName, required super.fatherName, required super.motherName,
    super.birthDate, required super.photoUrl, required super.address,
    required super.gender, required super.role,
    required this.className,
    required this.section,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
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
    role: UserRole.student,
    className: json['class_name'] ?? '',
    section: json['section'] ?? '',
  );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['class_name'] = className;
    map['section'] = section;
    return map;
  }
}