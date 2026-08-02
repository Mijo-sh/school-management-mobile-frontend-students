class LastAttemptDetailsModel {
  final LastAttemptSummaryModel attemptSummary;
  final List<QuestionDetailReviewModel> questionsDetails;

  LastAttemptDetailsModel({
    required this.attemptSummary,
    required this.questionsDetails,
  });

  factory LastAttemptDetailsModel.fromJson(Map<String, dynamic> json) {
    return LastAttemptDetailsModel(
      attemptSummary: LastAttemptSummaryModel.fromJson(json['attempt_summary']),
      questionsDetails: (json['questions_details'] as List)
          .map((e) => QuestionDetailReviewModel.fromJson(e))
          .toList(),
    );
  }
}

class LastAttemptSummaryModel {
  final int attemptId;
  final int totalMark;
  final int earnedMark;
  final int percentage;
  final String solvedAt;

  LastAttemptSummaryModel({
    required this.attemptId,
    required this.totalMark,
    required this.earnedMark,
    required this.percentage,
    required this.solvedAt,
  });

  factory LastAttemptSummaryModel.fromJson(Map<String, dynamic> json) {
    return LastAttemptSummaryModel(
      attemptId: json['attempt_id'],
      totalMark: json['total_mark'],
      earnedMark: json['earned_mark'],
      percentage: json['percentage'],
      solvedAt: json['solved_at'],
    );
  }
}

class QuestionDetailReviewModel {
  final int questionId;
  final String questionText;
  final int questionMark;
  final bool isCorrect;
  final int selectedOptionId;
  final String selectedOptionText;
  final int correctOptionId;
  final String correctOptionText;
  final List<ReviewOptionModel> allOptions;

  QuestionDetailReviewModel({
    required this.questionId,
    required this.questionText,
    required this.questionMark,
    required this.isCorrect,
    required this.selectedOptionId,
    required this.selectedOptionText,
    required this.correctOptionId,
    required this.correctOptionText,
    required this.allOptions,
  });

  factory QuestionDetailReviewModel.fromJson(Map<String, dynamic> json) {
    return QuestionDetailReviewModel(
      questionId: json['question_id'],
      questionText: json['question_text'],
      questionMark: json['question_mark'],
      isCorrect: json['is_correct'],
      selectedOptionId: json['selected_option_id'] ?? 0,
      selectedOptionText: json['selected_option_text'] ?? '',
      correctOptionId: json['correct_option_id'] ?? 0,
      correctOptionText: json['correct_option_text'] ?? '',
      allOptions: (json['all_options'] as List)
          .map((e) => ReviewOptionModel.fromJson(e))
          .toList(),
    );
  }
}

class ReviewOptionModel {
  final int id;
  final String optionText;
  final bool isCorrect;

  ReviewOptionModel({
    required this.id,
    required this.optionText,
    required this.isCorrect,
  });

  factory ReviewOptionModel.fromJson(Map<String, dynamic> json) {
    return ReviewOptionModel(
      id: json['id'],
      optionText: json['option_text'],
      isCorrect: json['is_correct'],
    );
  }
}