import '../../domain/entities/activity_item.dart';

class ActivityItemModel extends ActivityItem {
  const ActivityItemModel({
    required super.id,
    required super.activityName,
    required super.activityDate,
    required super.startTime,
    required super.endTime,
    required super.isRead,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    return ActivityItemModel(
      id: json['id'] as int,
      activityName: json['activity_name']?.toString() ?? '',
      // "2026-09-15" — تاريخ بدون وقت، DateTime.parse بتقبلها مباشرة.
      activityDate: DateTime.parse(json['activity_date'] as String),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      // نفس احتياط is_raed/is_read يلي استخدمناه بباقي الميزات.
      isRead: (json['is_raed'] ?? json['is_read']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_name': activityName,
      'activity_date':
          '${activityDate.year.toString().padLeft(4, '0')}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'end_time': endTime,
      'is_read': isRead,
    };
  }
}
