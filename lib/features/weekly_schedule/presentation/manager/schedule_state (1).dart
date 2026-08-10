import '../../domain/entities/schedule_entry.dart';

abstract class ScheduleState {
  const ScheduleState(); // 👈 إضافة المُنشئ الثابت للأب
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final WeeklySchedule schedule;
  final String? warningMessage;

  const ScheduleLoaded(this.schedule, {this.warningMessage});
}

class ScheduleError extends ScheduleState {
  final String message;
  const ScheduleError(this.message);
}