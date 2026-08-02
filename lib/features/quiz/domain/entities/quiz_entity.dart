class QuizListItemEntity {
  final int id;
  final String title;
  final String description;
  final int totalMark;
  final int attemptsCount;
  final int highScore;
  final String progressMsg;
  final String createdAt;

  const QuizListItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.totalMark,
    required this.attemptsCount,
    required this.highScore,
    required this.progressMsg,
    required this.createdAt,
  });
}

class QuizDetailEntity {
  final int id;
  final int gradeSubjectId;
  final int teacherId;
  final String title;
  final String description;
  final bool isActive;
  final List<QuestionEntity> questions;

  const QuizDetailEntity({
    required this.id,
    required this.gradeSubjectId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.isActive,
    required this.questions,
  });
}

class QuestionEntity {
  final int id;
  final int practiceQuizId;
  final String questionText;
  final int mark;
  final List<OptionEntity> options;

  const QuestionEntity({
    required this.id,
    required this.practiceQuizId,
    required this.questionText,
    required this.mark,
    required this.options,
  });
}

class OptionEntity {
  final int id;
  final int questionId;
  final String optionText;

  const OptionEntity({
    required this.id,
    required this.questionId,
    required this.optionText,
  });
}

// كيان لتخزين نتيجة السؤال بعد الإرسال (Feedback)
class QuizFeedbackEntity {
  final int questionId;
  final int selectedOptionId;
  final bool isCorrect;
  final int correctOptionId;

  const QuizFeedbackEntity({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.correctOptionId,
  });
}

class QuizSubmitResultEntity {
  final int attemptId;
  final int totalMark;
  final int earnedMark;
  final int percentage;
  final List<QuizFeedbackEntity> feedback;

  const QuizSubmitResultEntity({
    required this.attemptId,
    required this.totalMark,
    required this.earnedMark,
    required this.percentage,
    required this.feedback,
  });
}

class SubmitAnswerEntity {
  final int questionId;
  final int optionId;

  const SubmitAnswerEntity({
    required this.questionId,
    required this.optionId,
  });
}
class LastAttemptSummaryEntity {
  final int attemptId;
  final int totalMark;
  final int earnedMark;
  final int percentage;
  final String solvedAt;

  const LastAttemptSummaryEntity({
    required this.attemptId,
    required this.totalMark,
    required this.earnedMark,
    required this.percentage,
    required this.solvedAt,
  });
}

class ReviewOptionEntity {
  final int id;
  final String optionText;
  final bool isCorrect;

  const ReviewOptionEntity({
    required this.id,
    required this.optionText,
    required this.isCorrect,
  });
}

class QuestionDetailReviewEntity {
  final int questionId;
  final String questionText;
  final int questionMark;
  final bool isCorrect;
  final int selectedOptionId;
  final String selectedOptionText;
  final int correctOptionId;
  final String correctOptionText;
  final List<ReviewOptionEntity> allOptions;

  const QuestionDetailReviewEntity({
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
}

class LastAttemptDetailsEntity {
  final LastAttemptSummaryEntity attemptSummary;
  final List<QuestionDetailReviewEntity> questionsDetails;

  const LastAttemptDetailsEntity({
    required this.attemptSummary,
    required this.questionsDetails,
  });
}