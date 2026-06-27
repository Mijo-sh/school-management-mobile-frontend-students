import '../../domain/entities/student_entity.dart';

class AcademicInfoModel extends AcademicInfo {
  const AcademicInfoModel({
    required super.gradeName,
    required super.semesterName,
    required super.classNumber,
  });

  factory AcademicInfoModel.fromJson(Map<String, dynamic> json) {
    return AcademicInfoModel(
      gradeName: json['grade_name']?.toString() ?? '',
      semesterName: json['semester_name']?.toString() ?? '',
      classNumber: json['class_number']?.toString() ?? '',
    );
  }
}