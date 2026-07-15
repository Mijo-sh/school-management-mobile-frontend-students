import '../../domain/entities/announcement_item.dart';

class AnnouncementItemModel extends AnnouncementItem {
  const AnnouncementItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.isRead,
  });

  factory AnnouncementItemModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementItemModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: (json['is_raed'] ?? json['is_read']) as bool? ?? false,
    );
  }

  /// للتخزين المحلي بس (SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}