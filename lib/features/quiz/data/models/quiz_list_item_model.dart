import '../../domain/entities/quiz_entity.dart';

class QuizListItemModel extends QuizListItemEntity {
  const QuizListItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.totalMark,
    required super.attemptsCount,
    required super.highScore,
    required super.progressMsg,
    required super.createdAt,
  });

  factory QuizListItemModel.fromJson(Map<String, dynamic> json) {
    return QuizListItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      totalMark: json['total_mark'] ?? 0,
      attemptsCount: json['attempts_count'] ?? 0,
      highScore: json['high_score'] ?? 0,
      progressMsg: json['progress_msg'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}