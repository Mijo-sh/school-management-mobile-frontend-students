import '../../domain/entities/payment_alert_item.dart';
import '../../domain/entities/payment_alert_type.dart';

class PaymentAlertItemModel extends PaymentAlertItem {
  const PaymentAlertItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.meta,
    required super.createdAt,
    required super.isRead,
  });

  factory PaymentAlertItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentAlertItemModel(
      id: json['id'] as int,
      type: PaymentAlertType.fromApiValue(json['type'] as String?),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      meta: (json['meta'] as Map<String, dynamic>?) ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      // منخلي fallback للاثنين احتياطًا متل ما بالفيتشر القديم
      isRead: (json['is_read'] ?? json['is_raed']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name, // payment / payed / general — بترجع صح بالـ fromApiValue
      'title': title,
      'description': description,
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}