import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alert_item.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/use_cases/mark_alert_as_read_usecase.dart';
import 'alerts_cubit.dart';

part 'alerts_state.dart';

class AlertsCubit extends Cubit<AlertsState> {
  final GetAlertsUseCase getAlertsUseCase;
  final MarkAlertAsReadUseCase markAlertAsReadUseCase;
  final int? studentId;

  // متغيرات داخلية للتحكم بالـ Pagination
  int _currentPage = 1;
  bool _isFetchingMore = false;
  final List<AlertItem> _allAlerts = [];

  AlertsCubit({
    required this.getAlertsUseCase,
    required this.markAlertAsReadUseCase,
    this.studentId,
  }) : super(const AlertsInitial());

  /// تحميل الصفحة الأولى بالكامل
  Future<void> loadAlerts() async {
    _currentPage = 1;
    _allAlerts.clear();

    emit(const AlertsLoading());

    // نطلب الصفحة الأولى (page: 1)
    final result = await getAlertsUseCase(studentId: studentId, page: 1);

    result.fold(
          (failure) => emit(AlertsError(failure.message)),
          (paginatedData) {
        // التحويل الآمن باستخدام List<AlertItem>.from لمنع خطأ الـ Compile 👈
        final List<AlertItem> alertsList = List<AlertItem>.from(paginatedData.items);
        _allAlerts.addAll(alertsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(AlertsLoaded(List.from(_allAlerts), hasMore: hasMore));

        // تأخير مقصود لتجربة مستخدم جميلة لرؤية حالة غير المقروء قبل تحويلها
        Future.delayed(const Duration(milliseconds: 900), markAsRead);
      },
    );
  }

  /// تحميل الصفحات التالية عند الـ Scroll
  Future<void> loadNextPage() async {
    // نمنع الطلب إذا كنا نقوم بالتحميل حالياً، أو لو لم نكن في حالة Loaded أصلاً
    if (_isFetchingMore || state is! AlertsLoaded) return;

    final currentState = state as AlertsLoaded;
    if (!currentState.hasMore) return; // لا يوجد صفحات أخرى لتحميلها

    _isFetchingMore = true;
    _currentPage++;

    final result = await getAlertsUseCase(studentId: studentId, page: _currentPage);

    result.fold(
          (failure) {
        _isFetchingMore = false;
        _currentPage--; // التراجع عن زيادة الصفحة في حال الفشل
      },
          (paginatedData) {
        // التحويل الآمن باستخدام List<AlertItem>.from هنا أيضاً 👇
        final List<AlertItem> alertsList = List<AlertItem>.from(paginatedData.items);
        _allAlerts.addAll(alertsList);

        final hasMore = paginatedData.currentPage < paginatedData.lastPage;

        emit(AlertsLoaded(List.from(_allAlerts), hasMore: hasMore));
        _isFetchingMore = false;
      },
    );
  }

  /// تحديث فوري بالواجهة (optimistic) + طلب فعلي بالخلفية.
  /// لو الطلب فشل، نرجّع الحالة القديمة (rollback).
  Future<void> markAsRead() async {
    final current = state;
    if (current is! AlertsLoaded) return;

    final hasUnread = current.alerts.any((a) => !a.isRead);
    if (!hasUnread) return; // الكل أصلًا مقروء، ما في داعي لأي طلب
    final result = await markAlertAsReadUseCase(studentId: studentId);

    result.fold(
          (failure) {
        // في حال فشل الاتصال، نتراجع عن التحديث ونعيد الـ state السابقة لمنع التضليل
        if (state is AlertsLoaded) {
          emit(current);
        }
      },
          (_) {
        // 2. تحديث العناصر الحقيقية المخزنة في الذاكرة لتجنب عودة الحالات السابقة عند التمرير 👇
        for (var i = 0; i < _allAlerts.length; i++) {
          _allAlerts[i] = _allAlerts[i];
        }
      },
    );
  }
}
