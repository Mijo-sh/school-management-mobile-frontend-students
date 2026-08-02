import '../../domain/entities/quiz_entity.dart';

class QuizDetailModel extends QuizDetailEntity {
  const QuizDetailModel({
    required super.id,
    required super.gradeSubjectId,
    required super.teacherId,
    required super.title,
    required super.description,
    required super.isActive,
    required super.questions,
  });

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    var questionsList = (json['questions'] as List?)
        ?.map((q) => QuestionModel.fromJson(q))
        .toList() ??
        [];

    return QuizDetailModel(
      id: json['id'] ?? 0,
      gradeSubjectId: json['grade_subject_id'] ?? 0,
      teacherId: json['teacher_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      questions: questionsList,
    );
  }
}

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.practiceQuizId,
    required super.questionText,
    required super.mark,
    required super.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var optionsList = (json['options'] as List?)
        ?.map((o) => OptionModel.fromJson(o))
        .toList() ??
        [];

    return QuestionModel(
      id: json['id'] ?? 0,
      practiceQuizId: json['practice_quiz_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      mark: json['mark'] ?? 0,
      options: optionsList,
    );
  }
}

class OptionModel extends OptionEntity {
  const OptionModel({
    required super.id,
    required super.questionId,
    required super.optionText,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      optionText: json['option_text'] ?? '',
    );
  }
}