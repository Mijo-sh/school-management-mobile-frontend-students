import '../../domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.gradeSubjectId,
    required super.subjectName,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      gradeSubjectId: json['grade_subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade_subject_id': gradeSubjectId,
      'subject_name': subjectName,
    };
  }
}