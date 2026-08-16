// lib/features/exam/domain/entities/exam_unread_counts.dart

/// عدّادات غير المقروء مفصولة: امتحانات + مذاكرات.
class ExamUnreadCounts {
  final int exams;
  final int quizzes;

  const ExamUnreadCounts({required this.exams, required this.quizzes});

  /// المجموع (لو احتجتيه لبادج موحّد بمكان ثاني).
  int get total => exams + quizzes;

  static const empty = ExamUnreadCounts(exams: 0, quizzes: 0);
}
