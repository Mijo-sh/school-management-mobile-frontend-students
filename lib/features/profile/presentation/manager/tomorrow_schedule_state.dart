
import '../../../weekly_schedule/domain/entities/schedule_entry.dart';

abstract class TomorrowScheduleState {}

class TomorrowInitial extends TomorrowScheduleState {}
class TomorrowLoading extends TomorrowScheduleState {}
class TomorrowLoaded extends TomorrowScheduleState {
  /// اسم اليوم (مثلاً "tuesday") وحصصه.
  final String dayKey;
  final List<ScheduleEntry> entries;
  TomorrowLoaded({required this.dayKey, required this.entries});
}
class TomorrowError extends TomorrowScheduleState {
  final String message;
  TomorrowError(this.message);
}
