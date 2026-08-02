import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../subject/data/models/subject_model.dart';
import '../../models/quiz_list_item_model.dart';

abstract class PracticeQuizzesLocalDataSource {
  Future<List<SubjectModel>> getCachedSubjects();
  Future<void> cacheSubjects(List<SubjectModel> subjects);

  Future<List<QuizListItemModel>> getCachedQuizzes(int subjectId);
  Future<void> cacheQuizzes(int subjectId, List<QuizListItemModel> quizzes);
}

class PracticeQuizzesLocalDataSourceImpl implements PracticeQuizzesLocalDataSource {
  final SharedPreferences sharedPreferences;

  PracticeQuizzesLocalDataSourceImpl({required this.sharedPreferences});

  static const String cachedSubjectsKey = 'CACHED_PRACTICE_SUBJECTS';
  static const String cachedQuizzesKeyPrefix = 'CACHED_QUIZZES_SUBJECT_';

  @override
  Future<List<SubjectModel>> getCachedSubjects() async {
    final jsonString = sharedPreferences.getString(cachedSubjectsKey);
    if (jsonString != null) {
      final List decodedList = json.decode(jsonString);
      return decodedList.map((jsonItem) => SubjectModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('No cached subjects found');
    }
  }

  @override
  Future<void> cacheSubjects(List<SubjectModel> subjects) async {
    final jsonList = subjects.map((sub) => sub.toJson()).toList();
    await sharedPreferences.setString(cachedSubjectsKey, json.encode(jsonList));
  }

  @override
  Future<List<QuizListItemModel>> getCachedQuizzes(int subjectId) async {
    final jsonString = sharedPreferences.getString('$cachedQuizzesKeyPrefix$subjectId');
    if (jsonString != null) {
      final List decodedList = json.decode(jsonString);
      return decodedList.map((jsonItem) => QuizListItemModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('No cached quizzes found for this subject');
    }
  }

  @override
  Future<void> cacheQuizzes(int subjectId, List<QuizListItemModel> quizzes) async {
    final jsonList = quizzes.map((quiz) => {
      'id': quiz.id,
      'title': quiz.title,
      'description': quiz.description,
      'total_mark': quiz.totalMark,
      'attempts_count': quiz.attemptsCount,
      'high_score': quiz.highScore,
      'progress_msg': quiz.progressMsg,
      'created_at': quiz.createdAt,
    }).toList();
    await sharedPreferences.setString('$cachedQuizzesKeyPrefix$subjectId', json.encode(jsonList));
  }
}