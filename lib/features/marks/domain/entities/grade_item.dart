import 'package:equatable/equatable.dart';
import '../../../shared/presentation/manager/readable_feed_item.dart';

class GradeItem extends Equatable implements ReadableFeedItem {
  final int id;
  final String subjectName;
  final String assessmentName;
  final String assessmentType;
  final double mark;
  final double maxMark;
  final String teacherName;
  final bool isRead;
  final DateTime date;

  const GradeItem({
    required this.id,
    required this.subjectName,
    required this.assessmentName,
    required this.assessmentType,
    required this.mark,
    required this.maxMark,
    required this.teacherName,
    required this.isRead,
    required this.date,
  });

  @override
  List<Object?> get props => [
    id,
    subjectName,
    assessmentName,
    assessmentType,
    mark,
    maxMark,
    teacherName,
    isRead,
    date,
  ];
}