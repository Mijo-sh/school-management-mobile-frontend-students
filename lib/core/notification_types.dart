/// أنواع الإشعارات الموحّدة، مجمّعة من الباك-إند.
class NotificationType {
  // نشاط
  static const String activity = 'activity';

  // إعلان
  static const String announcement = 'announcement';

  // كويز (له QuizUnreadStore منفصل)
  static const String newPracticeQuiz = 'new_practice_quiz';

  // تقييم
  static const String newEvaluation = 'new_evaluation';
  static const String updateEvaluation = 'update_evaluation';

  // وظيفة
  static const String newHomework = 'new_homework';
  static const String updateHomework = 'update_homework';

  // علامة
  static const String newMark = 'new_mark';
  static const String updateMark = 'update_mark';

  // تنبيه (بالباك بيستخدم alert_type مش type)
  static const String alert = 'alert';

  // مادة مساعدة
  static const String newStudyMaterial = 'new_study_material';

  static const String newExamSchedule = 'new_exam_schedule';
  static const String updateExamSchedule = 'update_exam_schedule';

}

/// يستخرج نوع الإشعار الموحّد من الـ data.
/// التنبيهات بالباك بترسل alert_type بدل type، فبنميّزها هون.
String? resolveNotificationType(Map<String, dynamic> data) {
  final type = data['type']?.toString();
  if (type != null && type.isNotEmpty) return type;

  if (data['alert_type'] != null) return NotificationType.alert;

  return null;
}
