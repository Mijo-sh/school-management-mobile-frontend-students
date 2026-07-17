import 'package:equatable/equatable.dart';

class ActivityItem extends Equatable {
  final int id;
  final String activityName;
  final String type;
  final DateTime activityDate;
  final String startTime;
  final String endTime;
  final String? description;
  final DateTime createdAt;
  final bool isRead;

  const ActivityItem({
    required this.id,
    required this.activityName,
    required this.type,
    required this.activityDate,
    required this.startTime,
    required this.endTime,
    this.description,
    required this.createdAt,
    required this.isRead,
  });


  @override
  List<Object?> get props => [
    id,
    activityName,
    type,
    activityDate,
    startTime,
    endTime,
    description,
    createdAt,
    isRead,
  ];
}