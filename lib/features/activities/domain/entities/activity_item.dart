import 'package:equatable/equatable.dart';

class ActivityItem extends Equatable {
  final int id;
  final String activityName;
  final DateTime activityDate;

  final String startTime;
  final String endTime;

  final bool isRead;

  const ActivityItem({
    required this.id,
    required this.activityName,
    required this.activityDate,
    required this.startTime,
    required this.endTime,
    required this.isRead,
  });

  @override
  List<Object?> get props => [id, activityName, activityDate, startTime, endTime, isRead];
}
