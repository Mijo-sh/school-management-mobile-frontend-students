import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../subject/data/models/subject_model.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../models/last_attempt_model.dart';
import '../../models/quiz_detail_model.dart';
import '../../models/quiz_list_item_model.dart';
import '../../models/submit_answer_model.dart';

abstract class PracticeQuizzesRemoteDataSource {
  Future<List<SubjectModel>> getPracticeSubjects();
  Future<List<QuizListItemModel>> getQuizzesBySubject(int subjectId);
  Future<QuizDetailModel> getQuizDetails(int quizId);
  Future<void> submitQuizAnswers({required List<SubmitAnswerEntity> answers});
  Future<LastAttemptDetailsModel> getLastAttemptDetails(int quizId);
}

class PracticeQuizzesRemoteDataSourceImpl implements PracticeQuizzesRemoteDataSource {
  final Dio dio;

  PracticeQuizzesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SubjectModel>> getPracticeSubjects() async {
    final response = await dio.get('/api/user/practice-quizzes/student/subjects');
    final data = response.data['data'] as List;
    return data.map((json) => SubjectModel.fromJson(json)).toList();
  }

  @override
  Future<List<QuizListItemModel>> getQuizzesBySubject(int subjectId) async {
    final response = await dio.get('/api/user/practice-quizzes/show/quiz/by/subjects/$subjectId');
    final data = response.data['data'] as List;
    return data.map((json) => QuizListItemModel.fromJson(json)).toList();
  }

  @override
  Future<QuizDetailModel> getQuizDetails(int quizId) async {
    final response = await dio.get('/api/user/practice-quizzes/show/quiz/$quizId');
    final quizData = response.data['data']['quiz'];
    return QuizDetailModel.fromJson(quizData);
  }

  @override
  Future<void> submitQuizAnswers({required List<SubmitAnswerEntity> answers}) async {
    final body = {
      "answers": SubmitAnswerModel.listToJson(answers),
    };
    await dio.post('/api/user/practice-quizzes/quiz/result/submit', data: body);
  }
  Future<LastAttemptDetailsModel> getLastAttemptDetails(int quizId) async {
    final response = await dio.get('/api/user/practice-quizzes/show/last/quiz/attempt/$quizId');

    if (response.data['status'] == true) {
      return LastAttemptDetailsModel.fromJson(response.data['data']);
    } else {
      throw ServerException(message: response.data['message']);
    }
  }
}