
import '../../domain/entities/activity_item.dart';

class ActivityItemModel extends ActivityItem {
  const ActivityItemModel({
    required super.id,
    required super.activityName,
    required super.type,
    required super.activityDate,
    required super.startTime,
    required super.endTime,
    super.description,
    required super.createdAt,
    required super.isRead,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    // معالجة الحقول المتداخلة بأمان وتفادي الـ Null Pointer Exceptions
    final gradeLevelMap = json['grade_level'] as Map<String, dynamic>?;
    final classroomMap = json['classroom'] as Map<String, dynamic>?;

    return ActivityItemModel(
      id: json['id'] as int? ?? 0,
      activityName: json['activity_name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      activityDate: DateTime.tryParse(json['activity_date'] as String? ?? '') ??
          DateTime.now(),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? _parseCustomDateTime(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_name': activityName,
      'type': type,
      'activity_date': activityDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}

DateTime _parseCustomDateTime(String raw) {
  final parts = raw.split('-');
  if (parts.length != 6) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
    int.parse(parts[3]),
    int.parse(parts[4]),
    int.parse(parts[5]),
  );
}