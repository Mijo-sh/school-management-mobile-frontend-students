import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:school_management_mobile_frontend_students/features/homework/domain/use_cases/get_unread_homeworks_count_usecase.dart';
import 'package:school_management_mobile_frontend_students/features/marks/domain/use_cases/get_unread_grades_count_usecase.dart';

import '../../features/alerts/domain/use_cases/get_unread_alerts_count_usecase.dart';
import '../../features/activities/domain/use_cases/get_unread_activities_count_usecase.dart';
import '../features/announcement/domain/use_cases/get_unread_announcements_count_usecase.dart';
import '../features/evaluation/domain/use_cases/get_unread_evaluations_count_usecase.dart';
import 'notifications/domain/repositories/push_notification_repository.dart';

/// مخزن مركزي (Singleton عبر الـ DI، مش Provider بالشجرة) لعدادات
/// التنبيهات/الإعلانات/الأنشطة/التقييمات غير المقروءة الأربعة مع بعض.
///
/// ليش Singleton مش BlocProvider؟ لأنو AlertsPage/AnnouncementsPage/
/// ActivitiesPage/EvaluationsPage بتنفتح كـ routes منفصلة فوق الـ
/// shell بالكامل (مش جوا تبويبات StatefulShellRoute)، فمش إخوة بنفس
/// شجرة الـ widgets مع ServicesPage — أي BlocProvider محطوط بالـ
/// shell ما رح يوصلها. نفس المبدأ بالضبط المستخدم بـ SelectedChildHolder.
class UnreadCountsStore extends ChangeNotifier {
  final GetUnreadAlertsCountUseCase getAlertsCount;
  final GetUnreadAnnouncementsCountUseCase getAnnouncementsCount;
  final GetUnreadActivitiesCountUseCase getActivitiesCount;
  final GetUnreadEvaluationsCountUseCase getEvaluationsCount;
  final GetUnreadHomeworksCountUseCase getHomeworksCount;
  final GetUnreadGradesCountUseCase getGradesCount;

  final PushNotificationRepository pushNotificationRepository;
  UnreadCountsStore({
    required this.getAlertsCount,
    required this.getAnnouncementsCount,
    required this.getActivitiesCount,
    required this.getEvaluationsCount,
    required this.getHomeworksCount,
    required this.getGradesCount,
    required this.pushNotificationRepository,
  }) {
    // نستمع مرة وحدة بس، طول عمر التطبيق (Singleton) — أي إشعار
    // يوصل والتطبيق مفتوح، منعيد جلب العدادات الأربعة تلقائيًا.
    _foregroundSub = pushNotificationRepository.onForegroundMessage.listen((_) {
      loadAll(studentId: _lastStudentId);
    });
  }

  int alerts = 0;
  int announcements = 0;
  int activities = 0;
  int evaluations = 0;
  int homeworks=0;
  int grades =0;
  /// بيصير true بعد أول تحميل ناجح — تفيد لو حابب تفرّق بصريًا بين
  /// "لسا ما حمّلنا" و"حمّلنا وطلع صفر".
  bool isLoaded = false;

  int? _lastStudentId;
  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  /// [studentId] null = المستخدم الحالي، موجود = ابن معيّن (ولي أمر).
  Future<void> loadAll({int? studentId}) async {
    _lastStudentId = studentId;

    final results = await Future.wait([
      getAlertsCount(studentId: studentId),
      getAnnouncementsCount(studentId: studentId),
      getActivitiesCount(studentId: studentId),
      getEvaluationsCount(studentId: studentId),
      getHomeworksCount(studentId: studentId),
      getGradesCount(studentId: studentId)


    ]);

    alerts = results[0].fold((_) => 0, (c) => c);
    announcements = results[1].fold((_) => 0, (c) => c);
    activities = results[2].fold((_) => 0, (c) => c);
    evaluations = results[3].fold((_) => 0, (c) => c);
    homeworks = results[4].fold((_) => 0, (c) => c);
    grades = results[5].fold((_) => 0, (c) => c);

    isLoaded = true;

    notifyListeners();
  }

  /// ينده بعد نجاح "تصفير الكل" بأي من الشاشات الأربعة، حتى البادج
  /// يتحدث فورًا بدون ما ينتظر أي إشعار جديد.
  void refreshNow() => loadAll(studentId: _lastStudentId);

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }
}