import '../../domain/entities/top_student.dart';

class TopStudentModel extends TopStudent {
  const TopStudentModel({
    required super.id,
    required super.fullName,
    required super.photoUrl,
    required super.gradeLevel,
    required super.classRoom,
    required super.totalMarks,
    required super.maxTotalMarks,
    required super.percentage,
    required super.result,
    required super.isMe,
    required super.isMyChild
  });

  factory TopStudentModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>? ?? {};
    final klass = json['class'] as Map<String, dynamic>? ?? {};
    final results = json['results'] as Map<String, dynamic>? ?? {};

    return TopStudentModel(
      id: student['id'] as int? ?? 0,
      fullName: student['fullName'] as String? ?? '',
      photoUrl: student['photoUrl'] as String? ?? '',
      gradeLevel: klass['grade_level'] as String? ?? '',
      classRoom: klass['class_room'] as String? ?? '',
      totalMarks: results['total_marks']?.toString() ?? '',
      maxTotalMarks: results['max_total_marks']?.toString() ?? '',
      percentage: results['percentage']?.toString() ?? '',
      result: results['result'] as String? ?? '',
      isMyChild: student['isMyChild'] as bool? ?? false,
      isMe: student['isMe'] as bool? ?? false,
    );
  }
}