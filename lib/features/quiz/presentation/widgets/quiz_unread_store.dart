import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/notification_types.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../domain/use_cases/get_quizzes_unread_count_usecase.dart';
import '../../domain/use_cases/mark_as_read_quiz_usecase.dart';

/// مخزن مركزي (Singleton) لعدّادات كويزات كل مادة على حدة.
///
/// بيخزّن Map: grade_subject_id -> عدد الكويزات غير المقروءة.
/// - loadAll(): نداء واحد يجيب عدّاد كل المواد دفعة (API موحّد).
/// - يسمع للإشعارات: أي كويز جديد بيعيد جلب الكل (نداء واحد رخيص).
/// - markSubjectRead(): تصفير مادة محليًا (تفاؤلي) + نداء السيرفر.
class QuizUnreadStore extends ChangeNotifier {
  final GetQuizzesUnreadCountUseCase getUnreadCounts;
  final MarkQuizzesAsReadUseCase markAsReadUseCase;
  final PushNotificationRepository pushNotificationRepository;

  /// grade_subject_id -> count
  final Map<int, int> _counts = {};

  StreamSubscription<Map<String, dynamic>>? _sub;

  QuizUnreadStore({
    required this.getUnreadCounts,
    required this.markAsReadUseCase,
    required this.pushNotificationRepository,
  }) {
    _sub = pushNotificationRepository.onForegroundMessage.listen(_onMessage);
  }

  int countFor(int subjectId) => _counts[subjectId] ?? 0;

  void _onMessage(Map<String, dynamic> data) {
    // نستخدم resolveNotificationType لتوحيد قراءة النوع (نفس منطق UnreadCountsStore)
    final type = resolveNotificationType(data);
    if (type != NotificationType.newPracticeQuiz) return;

    // نداء واحد يعيد جلب كل العدّادات (رخيص لأنه موحّد)
    loadAll();
  }

  Future<void> loadAll() async {
    final result = await getUnreadCounts();
    result.fold(
          (failure) => debugPrint('❌ خطأ عدّاد الكويزات: ${failure.message}'),
          (countsMap) {
        debugPrint('✅ عدّادات الكويزات وصلت: $countsMap');
        _counts
          ..clear()
          ..addAll(countsMap);
        notifyListeners();
      },
    );
  }

  /// تصفير عدّاد مادة (تفاؤلي: نصفّر فورًا ثم ننادي السيرفر).
  Future<void> markSubjectRead(int subjectId) async {
    _counts[subjectId] = 0;
    notifyListeners();
    await markAsReadUseCase(subjectId: subjectId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}