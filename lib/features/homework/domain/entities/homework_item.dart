import 'package:equatable/equatable.dart';

import '../../../shared/presentation/manager/readable_feed_item.dart';


class HomeworkItem extends Equatable implements ReadableFeedItem {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String subjectName;
  final String gradeLevelName;

  @override
  final bool isRead;

  const HomeworkItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.subjectName,
    required this.gradeLevelName,
    required this.isRead,
  });

  HomeworkItem copyWith({bool? isRead}) {
    return HomeworkItem(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      createdAt: createdAt,
      subjectName: subjectName,
      gradeLevelName: gradeLevelName,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, dueDate, createdAt, subjectName, gradeLevelName, isRead];
}
