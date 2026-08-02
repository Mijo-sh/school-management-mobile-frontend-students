import 'package:equatable/equatable.dart';

import '../../../shared/presentation/manager/readable_feed_item.dart';

class AnnouncementItem extends Equatable implements ReadableFeedItem{
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isRead,
  });



  @override
  List<Object?> get props => [id, title, description, createdAt, isRead];
}
