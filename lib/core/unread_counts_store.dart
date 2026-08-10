import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:school_management_mobile_frontend_students/features/homework/domain/use_cases/get_unread_homeworks_count_usecase.dart';
import 'package:school_management_mobile_frontend_students/features/marks/domain/use_cases/get_unread_grades_count_usecase.dart';

import '../../features/alerts/domain/use_cases/get_unread_alerts_count_usecase.dart';
import '../../features/activities/domain/use_cases/get_unread_activities_count_usecase.dart';
import '../features/announcement/domain/use_cases/get_unread_announcements_count_usecase.dart';
import '../features/evaluation/domain/use_cases/get_unread_evaluations_count_usecase.dart';
import '../features/helper/domain/use_cases/get_unread_materials_count_usecase.dart';
import 'notification_types.dart';
import 'notifications/domain/repositories/push_notification_repository.dart';

class UnreadCountsStore extends ChangeNotifier {
  final GetUnreadAlertsCountUseCase getAlertsCount;
  final GetUnreadAnnouncementsCountUseCase getAnnouncementsCount;
  final GetUnreadActivitiesCountUseCase getActivitiesCount;
  final GetUnreadEvaluationsCountUseCase getEvaluationsCount;
  final GetUnreadHomeworksCountUseCase getHomeworksCount;
  final GetUnreadGradesCountUseCase getGradesCount;
  final GetUnreadMaterialsCountUseCase getMaterialsCount;

  final PushNotificationRepository pushNotificationRepository;
  UnreadCountsStore({
    required this.getAlertsCount,
    required this.getAnnouncementsCount,
    required this.getActivitiesCount,
    required this.getEvaluationsCount,
    required this.getHomeworksCount,
    required this.getGradesCount,
    required this.getMaterialsCount,
    required this.pushNotificationRepository,
  }) {
    _foregroundSub =
        pushNotificationRepository.onForegroundMessage.listen(_onMessage);
  }

  int alerts = 0;
  int announcements = 0;
  int activities = 0;
  int evaluations = 0;
  int homeworks = 0;
  int grades = 0;
  int materials = 0;

  bool isLoaded = false;

  int? _lastStudentId;
  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  void _onMessage(Map<String, dynamic> data) {
    final type = resolveNotificationType(data);
    switch (type) {
      case NotificationType.activity:
        _refreshActivities();
        break;
      case NotificationType.announcement:
        _refreshAnnouncements();
        break;
      case NotificationType.newEvaluation:
      case NotificationType.updateEvaluation:
        _refreshEvaluations();
        break;
      case NotificationType.newHomework:
      case NotificationType.updateHomework:
        _refreshHomeworks();
        break;
      case NotificationType.newMark:
      case NotificationType.updateMark:
        _refreshGrades();
        break;
      case NotificationType.alert:
        _refreshAlerts();
        break;
      case NotificationType.newStudyMaterial:
        _refreshMaterials();
        break;
      case NotificationType.newPracticeQuiz:
        // الكويز له QuizUnreadStore منفصل
        break;
      default:
        break;
    }
  }

  Future<void> loadAll({int? studentId}) async {
    _lastStudentId = studentId;

    final results = await Future.wait([
      getAlertsCount(studentId: studentId),
      getAnnouncementsCount(studentId: studentId),
      getActivitiesCount(studentId: studentId),
      getEvaluationsCount(studentId: studentId),
      getHomeworksCount(studentId: studentId),
      getGradesCount(studentId: studentId),
      getMaterialsCount(),
    ]);

    alerts = results[0].fold((_) => 0, (c) => c);
    announcements = results[1].fold((_) => 0, (c) => c);
    activities = results[2].fold((_) => 0, (c) => c);
    evaluations = results[3].fold((_) => 0, (c) => c);
    homeworks = results[4].fold((_) => 0, (c) => c);
    grades = results[5].fold((_) => 0, (c) => c);
    materials = results[6].fold((_) => 0, (c) => c);

    isLoaded = true;
    notifyListeners();
  }

  Future<void> _refreshAlerts() async {
    final r = await getAlertsCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { alerts = c; notifyListeners(); });
  }

  Future<void> _refreshAnnouncements() async {
    final r = await getAnnouncementsCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { announcements = c; notifyListeners(); });
  }

  Future<void> _refreshActivities() async {
    final r = await getActivitiesCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { activities = c; notifyListeners(); });
  }

  Future<void> _refreshEvaluations() async {
    final r = await getEvaluationsCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { evaluations = c; notifyListeners(); });
  }

  Future<void> _refreshHomeworks() async {
    final r = await getHomeworksCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { homeworks = c; notifyListeners(); });
  }

  Future<void> _refreshGrades() async {
    final r = await getGradesCount(studentId: _lastStudentId);
    r.fold((_) {}, (c) { grades = c; notifyListeners(); });
  }

  Future<void> _refreshMaterials() async {
    final r = await getMaterialsCount();
    r.fold((_) {}, (c) { materials = c; notifyListeners(); });
  }

  void clearAlerts() { alerts = 0; notifyListeners(); }
  void clearAnnouncements() { announcements = 0; notifyListeners(); }
  void clearActivities() { activities = 0; notifyListeners(); }
  void clearEvaluations() { evaluations = 0; notifyListeners(); }
  void clearHomeworks() { homeworks = 0; notifyListeners(); }
  void clearGrades() { grades = 0; notifyListeners(); }
  void clearMaterials() { materials = 0; notifyListeners(); }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }
}
