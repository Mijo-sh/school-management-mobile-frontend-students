import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
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

  /// نداء واحد يرجّع عدد غير المقروء لكل مادة: {grade_subject_id: count}
  Future<Map<int, int>> getUnreadCounts();

  /// تصفير كويزات مادة معيّنة (يبقى لكل مادة على حدة).
  Future<void> markAllAsRead({required int subjectId});
}

class PracticeQuizzesRemoteDataSourceImpl extends BaseRemoteDataSource
    implements PracticeQuizzesRemoteDataSource {
  final Dio dio;

  PracticeQuizzesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SubjectModel>> getPracticeSubjects() {
    return execute(() async {
      final response = await dio.get('/api/user/practice-quizzes/student/subjects');
      final data = response.data['data'] as List;
      return data.map((json) => SubjectModel.fromJson(json)).toList();
    });
  }

  @override
  Future<List<QuizListItemModel>> getQuizzesBySubject(int subjectId) {
    return execute(() async {
      final response =
      await dio.get('/api/user/practice-quizzes/show/quiz/by/subjects/$subjectId');
      final data = response.data['data'] as List;
      return data.map((json) => QuizListItemModel.fromJson(json)).toList();
    });
  }

  @override
  Future<QuizDetailModel> getQuizDetails(int quizId) {
    return execute(() async {
      final response = await dio.get('/api/user/practice-quizzes/show/quiz/$quizId');
      final quizData = response.data['data']['quiz'];
      return QuizDetailModel.fromJson(quizData);
    });
  }

  @override
  Future<void> submitQuizAnswers({required List<SubmitAnswerEntity> answers}) {
    return execute(() async {
      final body = {
        "answers": SubmitAnswerModel.listToJson(answers),
      };
      await dio.post('/api/user/practice-quizzes/quiz/result/submit', data: body);
    });
  }

  @override
  Future<LastAttemptDetailsModel> getLastAttemptDetails(int quizId) {
    return execute(() async {
      final response =
      await dio.get('/api/user/practice-quizzes/show/last/quiz/attempt/$quizId');
      return LastAttemptDetailsModel.fromJson(response.data['data']);
    });
  }

  @override
  Future<Map<int, int>> getUnreadCounts() {
    return execute(() async {
      final response =
      await dio.get('/api/user/practice-quizzes/quiz/unread-count');
      // ملاحظة: data هي نفسها الـ List مباشرةً، و unread_count موجود داخل كل عنصر.
      final list = response.data['data'] as List;
      return {
        for (final item in list)
          (item['grade_subject_id'] as num).toInt():
          (item['unread_count'] as num?)?.toInt() ?? 0,
      };
    });
  }

  @override
  Future<void> markAllAsRead({required int subjectId}) {
    return execute(() async {
      await dio.post('/api/user/practice-quizzes/quiz/mark-all-read/$subjectId');
    });
  }
}