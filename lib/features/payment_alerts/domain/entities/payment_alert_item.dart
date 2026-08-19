import 'package:equatable/equatable.dart';

import '../../../shared/presentation/manager/readable_feed_item.dart';
import 'payment_alert_type.dart';

class PaymentAlertItem extends Equatable implements ReadableFeedItem {
  final int id;
  final PaymentAlertType type;
  final String title;
  final String description;
  final Map<String, dynamic> meta;
  final DateTime createdAt;
  final bool isRead;

  const PaymentAlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.meta,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props =>
      [id, type, title, description, meta, createdAt, isRead];
}