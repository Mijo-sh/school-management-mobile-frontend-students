import 'package:equatable/equatable.dart';

/// حصّة واحدة ببرنامج الأسبوع.
class ScheduleEntry extends Equatable {
  final int periodIndex;
  final String? subjectName;
  final String? teacherName;
  final String? classroom;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"

  const ScheduleEntry({
    required this.periodIndex,
    this.subjectName,
    this.teacherName,
    this.classroom,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props =>
      [periodIndex, subjectName, teacherName, classroom, startTime, endTime];
}

/// البرنامج: خريطة اليوم -> حصص ذلك اليوم.
/// مثال: { "sunday": [حصة, حصة], "monday": [...] }
typedef WeeklySchedule = Map<String, List<ScheduleEntry>>;
