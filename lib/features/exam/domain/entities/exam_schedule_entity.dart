// lib/features/exam/domain/entities/exam_schedule_entity.dart

/// نوع البند: مذاكرة (quiz) أو امتحان (exam).
enum ExamType { quiz, exam, unknown }

ExamType examTypeFromString(String? raw) {
  switch (raw) {
    case 'quiz':
      return ExamType.quiz;
    case 'exam':
      return ExamType.exam;
    default:
      return ExamType.unknown;
  }
}

/// القيمة النصية المرسلة للباك-إند (query param type).
extension ExamTypeApi on ExamType {
  String get apiValue {
    switch (this) {
      case ExamType.quiz:
        return 'quiz';
      case ExamType.exam:
        return 'exam';
      case ExamType.unknown:
        return '';
    }
  }
}

/// بند واحد من جدول الامتحانات/المذاكرات.
class ExamScheduleItem {
  final int id;
  final String title;
  final ExamType type;
  final List<ExamSubjectInfo> subjects;
  final bool isRead;

  const ExamScheduleItem({
    required this.id,
    required this.title,
    required this.type,
    required this.subjects,
    required this.isRead,
  });

  bool get isQuiz => type == ExamType.quiz;
  bool get isExam => type == ExamType.exam;
}

/// معلومات المادة داخل البند (تاريخ، وقت، مقرر).
class ExamSubjectInfo {
  final String subjectName;
  final DateTime? examDate;
  final String startTime;
  final String endTime;
  final String syllabus;

  const ExamSubjectInfo({
    required this.subjectName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.syllabus,
  });
}
