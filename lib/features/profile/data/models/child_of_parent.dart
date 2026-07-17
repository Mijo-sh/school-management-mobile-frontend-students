import '../../domain/entities/child_card.dart';

class ChildCardModel extends ChildCard {
  const ChildCardModel({
    required super.id,
    required super.firstName,
    required super.fatherName,
    required super.lastName,
    super.studentPhotoUrl,
    required super.gradeName,
    required super.classNumber,
    required super.gender,
  });

  factory ChildCardModel.fromJson(Map<String, dynamic> json) {
    return ChildCardModel(
      id: int.parse(json['id'].toString()),
      firstName: json['first_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      studentPhotoUrl: json['student_photo_url']?.toString(),
      gradeName: json['grade_name']?.toString() ?? '',
      classNumber: json['class_room_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'father_name': fatherName,
      'last_name': lastName,
      'student_photo_url': studentPhotoUrl,
      'grade_name': gradeName,
      'class_room_name': classNumber,
      'gender': gender,
    };
  }
}