import 'package:equatable/equatable.dart';

import 'alert_type.dart';

class AlertItem extends Equatable {
  final int id;
  final AlertType type;
  final String title;
  final String description;
  final Map<String, dynamic> meta;

  final DateTime createdAt;
  final bool isRead;

  const AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.meta,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [id, type, title, description, meta, createdAt, isRead];
}
