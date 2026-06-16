import '../../../app_intro/domain/enums/user_role.dart';
import 'user_model.dart';

class ParentModel extends UserModel { // يرث من UserModel مباشرة
  final String nationalId;
  final List<String> childrenIds;

  const ParentModel({
    required super.id, required super.phoneNumber, required super.firstName,
    required super.lastName, required super.fatherName, required super.motherName,
    super.birthDate, required super.photoUrl, required super.address,
    required super.gender, required super.role,
    required this.nationalId,
    required this.childrenIds,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => ParentModel(
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
    role: UserRole.parent,
    nationalId: json['national_id'] ?? '',
    childrenIds: (json['children_ids'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['national_id'] = nationalId;
    map['children_ids'] = childrenIds;
    return map;
  }
}