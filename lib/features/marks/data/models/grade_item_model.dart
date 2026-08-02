import '../../domain/entities/grade_item.dart';

class GradeItemModel extends GradeItem {
  const GradeItemModel({
    required super.id,
    required super.subjectName,
    required super.assessmentName,
    required super.assessmentType,
    required super.mark,
    required super.maxMark,
    required super.teacherName,
    required super.isRead,
    required super.date,
  });

  factory GradeItemModel.fromJson(Map<String, dynamic> json) {
    return GradeItemModel(
      id: json['id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      assessmentName: json['assessment_name'] as String? ?? '',
      assessmentType: json['assessment_type'] as String? ?? '',
      mark: (json['mark'] as num?)?.toDouble() ?? 0.0,
      maxMark: (json['max_mark'] as num?)?.toDouble() ?? 100.0,
      teacherName: json['teacher_name'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_name': subjectName,
      'assessment_name': assessmentName,
      'assessment_type': assessmentType,
      'mark': mark,
      'max_mark': maxMark,
      'teacher_name': teacherName,
      'is_read': isRead,
      'date': date.toIso8601String(),
    };
  }
}