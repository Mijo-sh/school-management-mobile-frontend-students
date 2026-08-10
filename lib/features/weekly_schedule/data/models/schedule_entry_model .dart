
import '../../domain/entities/schedule_entry.dart';

class ScheduleEntryModel extends ScheduleEntry {
  const ScheduleEntryModel({
    required super.periodIndex,
    super.subjectName,
    super.teacherName,
    super.classroom,
    required super.startTime,
    required super.endTime,
  });

  factory ScheduleEntryModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEntryModel(
      periodIndex: (json['period_index'] as num?)?.toInt() ?? 0,
      subjectName: json['subject_name'] as String?,
      teacherName: json['teacher_name'] as String?,
      classroom: json['classroom'] as String?,
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'period_index': periodIndex,
        'subject_name': subjectName,
        'teacher_name': teacherName,
        'classroom': classroom,
        'start_time': startTime,
        'end_time': endTime,
      };
}
