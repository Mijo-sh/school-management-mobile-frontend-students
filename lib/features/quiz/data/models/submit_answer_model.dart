import '../../domain/entities/quiz_entity.dart';

class SubmitAnswerModel extends SubmitAnswerEntity {
  const SubmitAnswerModel({
    required super.questionId,
    required super.optionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'option_id': optionId,
    };
  }

  static List<Map<String, dynamic>> listToJson(List<SubmitAnswerEntity> answers) {
    return answers.map((answer) => {
      'question_id': answer.questionId,
      'option_id': answer.optionId,
    }).toList();
  }
}