import 'package:equatable/equatable.dart';
import '../../../shared/presentation/manager/readable_feed_item.dart';
import 'evaluation_rating.dart';

class EvaluationItem extends Equatable implements ReadableFeedItem {
  final int id;
  final EvaluationRating rating;

  final String ratingArabic;

  final String notes;
  final DateTime createdAt;
  final String subjectName;

  @override
  final bool isRead;

  const EvaluationItem({
    required this.id,
    required this.rating,
    required this.ratingArabic,
    required this.notes,
    required this.createdAt,
    required this.subjectName,
    required this.isRead,
  });

  EvaluationItem copyWith({bool? isRead}) {
    return EvaluationItem(
      id: id,
      rating: rating,
      ratingArabic: ratingArabic,
      notes: notes,
      createdAt: createdAt,
      subjectName: subjectName,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, rating, ratingArabic, notes, createdAt, subjectName, isRead];
}
