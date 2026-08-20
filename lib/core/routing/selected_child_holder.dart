import '../../features/profile/domain/entities/child_card.dart';

class SelectedChildHolder {
  ChildCard? current;

  /// تمسح الابن المختار — تُستدعى عند تسجيل الخروج حتى ما تتسرّب
  /// بيانات ولي الأمر لجلسة مستخدم جديد (مثلاً طالب).
  void clear() => current = null;
}