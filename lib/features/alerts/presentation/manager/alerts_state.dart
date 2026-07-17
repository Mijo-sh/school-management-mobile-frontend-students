part of 'alerts_cubit.dart';

abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object?> get props => [];
}

class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

class AlertsLoaded extends AlertsState {
  final List<AlertItem> alerts;
  final bool hasMore; // مضاف لمعرفة إن كان هناك صفحات أخرى بالـ API 👇

  const AlertsLoaded(this.alerts, {this.hasMore = false});

  int get unreadCount => alerts.where((a) => !a.isRead).length;

  // نسخ الحالة الحالية مع تعديل بعض القيم
  AlertsLoaded copyWith({
    List<AlertItem>? alerts,
    bool? hasMore,
  }) {
    return AlertsLoaded(
      alerts ?? this.alerts,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [alerts, hasMore]; // إضافة الـ hasMore هنا
}

class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}