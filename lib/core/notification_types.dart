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
  static const String payment = 'payment';

  // جلاء (كشف علامات الفصل)
  static const String reportCard = 'report_card'; // 👈 جديد
}

/// يستخرج نوع الإشعار الموحّد من الـ data.
/// التنبيهات بالباك بترسل alert_type بدل type، فبنميّزها هون.
String? resolveNotificationType(Map<String, dynamic> data) {
  final type = data['type']?.toString();
  if (type != null && type.isNotEmpty) {
    // 👇 لو الجلاء إجا كـ type مباشرة
    if (type == 'report_card') return NotificationType.reportCard;
    return type;
  }

  final alertType = data['alert_type']?.toString();
  if (alertType != null && alertType.isNotEmpty) {
    // التنبيهات المالية: payment / payed → عدّاد paymentAlerts
    if (alertType == 'payment' || alertType == 'payed') {
      return NotificationType.payment;
    }
    // 👇 الجلاء لو إجا ضمن alert_type
    if (alertType == 'report_card' || alertType == 'card') {
      return NotificationType.reportCard;
    }
    // أي alert_type تاني (homework/absence/behavior/late/escape/general) → تنبيه عادي
    return NotificationType.alert;
  }

  return null;
}