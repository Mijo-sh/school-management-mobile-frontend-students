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
  const AlertsLoaded(this.alerts);

  int get unreadCount => alerts.where((a) => !a.isRead).length;

  @override
  List<Object?> get props => [alerts];
}

class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}
