// lib/features/exam/presentation/stores/exam_unread_store.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/notification_types.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../domain/entities/exam_schedule_entity.dart';
import '../../domain/entities/exam_unread_counts.dart';
import '../../domain/use_cases/get_unread_exams_count_usecase.dart';
import '../../domain/use_cases/mark_all_exams_read_usecase.dart';

/// مخزن مركزي (Singleton) لعدّادات غير المقروء للامتحانات والمذاكرات.
///
/// - يحمل ExamUnreadCounts (exams + quizzes منفصلين).
/// - loadCounts(): نداء واحد يجيب العدّادين.
/// - يسمع للإشعارات (new/update_exam_schedule) ويعيد الجلب.
/// - markTypeRead(type): تصفير النوع المطلوب محليًا (تفاؤلي) + نداء السيرفر.
class ExamUnreadStore extends ChangeNotifier {
  final GetUnreadExamsCountUseCase getUnreadCounts;
  final MarkAllExamsReadUseCase markAllReadUseCase;
  final PushNotificationRepository pushNotificationRepository;

  ExamUnreadCounts _counts = ExamUnreadCounts.empty;
  StreamSubscription<Map<String, dynamic>>? _sub;

  // آخر studentId مستخدم (للطالب = null، لولي الأمر = id الطالب المختار)
  int? _lastStudentId;

  ExamUnreadStore({
    required this.getUnreadCounts,
    required this.markAllReadUseCase,
    required this.pushNotificationRepository,
  }) {
    _sub = pushNotificationRepository.onForegroundMessage.listen(_onMessage);
  }

  int get examsCount => _counts.exams;
  int get quizzesCount => _counts.quizzes;
  ExamUnreadCounts get counts => _counts;

  void _onMessage(Map<String, dynamic> data) {
    final type = resolveNotificationType(data);
    // أي تغيير على جدول الامتحانات (جديد أو تحديث) → نعيد جلب العدّادات.
    if (type == NotificationType.newExamSchedule ||
        type == NotificationType.updateExamSchedule) {
      loadCounts(studentId: _lastStudentId);
    }
  }

  Future<void> loadCounts({int? studentId}) async {
    _lastStudentId = studentId;
    final result = await getUnreadCounts(studentId: studentId);
    result.fold(
      (failure) => debugPrint('❌ خطأ عدّاد الامتحانات: ${failure.message}'),
      (counts) {
        debugPrint('✅ عدّادات الامتحانات: exams=${counts.exams}, quizzes=${counts.quizzes}');
        _counts = counts;
        notifyListeners();
      },
    );
  }

  /// تصفير نوع معيّن (تفاؤلي): نصفّر النوع المطلوب فورًا ثم ننادي السيرفر.
  Future<void> markTypeRead(ExamType type, {int? studentId}) async {
    // تصفير محلي فوري للنوع المطلوب فقط
    _counts = ExamUnreadCounts(
      exams: type == ExamType.exam ? 0 : _counts.exams,
      quizzes: type == ExamType.quiz ? 0 : _counts.quizzes,
    );
    notifyListeners();

    await markAllReadUseCase(type: type, studentId: studentId ?? _lastStudentId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
