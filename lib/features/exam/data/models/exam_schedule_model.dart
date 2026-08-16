// lib/features/exam/data/models/exam_schedule_model.dart

import '../../domain/entities/exam_schedule_entity.dart';

class ExamScheduleModel extends ExamScheduleItem {
  const ExamScheduleModel({
    required super.id,
    required super.title,
    required super.type,
    required super.subjects,
    required super.isRead,
  });

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) {
    final subjectsJson = (json['subjects'] as List?) ?? const [];
    return ExamScheduleModel(
      id: (json['exam_id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      type: examTypeFromString(json['type']?.toString()),
      isRead: json['is_read'] == true,
      subjects: subjectsJson
          .map((s) => ExamSubjectModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExamSubjectModel extends ExamSubjectInfo {
  const ExamSubjectModel({
    required super.subjectName,
    required super.examDate,
    required super.startTime,
    required super.endTime,
    required super.syllabus,
  });

  factory ExamSubjectModel.fromJson(Map<String, dynamic> json) {
    return ExamSubjectModel(
      subjectName: json['subject_name']?.toString() ?? '',
      examDate: DateTime.tryParse(json['exam_date']?.toString() ?? ''),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      syllabus: json['syllabus']?.toString() ?? '',
    );
  }
}
