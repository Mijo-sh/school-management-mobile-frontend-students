import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alert_item.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/use_cases/mark_alert_as_read_usecase.dart';

part 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  final GetAlertsUseCase getAlertsUseCase;
  final MarkAlertAsReadUseCase markAlertAsReadUseCase;

  /// [studentId] يُمرَّر مرة وحدة وقت إنشاء الكيوبت (من ChildShellPage
  /// أو من الطالب نفسو بدون قيمة)، ونعيد استخدامه بكل نداء.
  final int? studentId;

  AlertsCubit({
    required this.getAlertsUseCase,
    required this.markAlertAsReadUseCase,
    this.studentId,
  }) : super(const AlertsInitial());

  Future<void> loadAlerts() async {
    emit(const AlertsLoading());
    final result = await getAlertsUseCase(studentId: studentId);
    result.fold(
          (failure) => emit(AlertsError(failure.message)),
          (alerts) {
        emit(AlertsLoaded(alerts));
        // تأخير بسيط مقصود — حتى تشوف حالة "غير مقروء" فعليًا بعينك
        // لحظة وحدة قبل ما تتحول لـ"مقروء" تلقائيًا. بدون هالتأخير،
        // فلاتر بيجمع التحديثين المتتاليين ويرسم بس النتيجة النهائية.
        Future.delayed(const Duration(milliseconds: 900), markAsRead);
      },
    );
  }

  /// تحديث فوري بالواجهة (optimistic) + طلب فعلي بالخلفية.
  /// لو الطلب فشل، نرجّع الحالة القديمة (rollback) بصمت.
  Future<void> markAsRead() async {
    final current = state;
    if (current is! AlertsLoaded) return;

    final hasUnread = current.alerts.any((a) => !a.isRead);
    if (!hasUnread) return; // الكل أصلًا مقروء، ما في داعي أي طلب


    // الطلب الفعلي بالخلفية (studentId جاي من حقل الكيوبت نفسو)
    final result = await markAlertAsReadUseCase(studentId: studentId);
    result.fold(
          (failure) {
        if (state is AlertsLoaded) emit(current); // rollback بصمت
      },
          (_) {},
    );
  }
}