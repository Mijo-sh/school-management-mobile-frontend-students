import '../../domain/entities/alert_item.dart';
import '../../domain/entities/alert_type.dart';

class AlertItemModel extends AlertItem {
  const AlertItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.meta,
    required super.createdAt,
    required super.isRead,
  });
  factory AlertItemModel.fromJson(Map<String, dynamic> json) {
    // معالجة آمنة لحقل meta سواء أرسله السيرفر Map أو List أو null
    Map<String, dynamic> parsedMeta = {};
    final rawMeta = json['meta'];
    if (rawMeta is Map<String, dynamic>) {
      parsedMeta = rawMeta;
    }

    return AlertItemModel(
      id: json['id'] as int,
      type: AlertType.fromApiValue(json['type'] as String?),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      meta: parsedMeta, // استخدام الـ meta المعالجة بأمان
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: (json['is_raed'] ?? json['is_read']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}