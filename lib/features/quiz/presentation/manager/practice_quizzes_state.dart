import '../../domain/entities/quiz_entity.dart';

abstract class PracticeQuizzesState {}

class PracticeQuizzesInitial extends PracticeQuizzesState {}

// حالات قائمة الكويزات
class QuizzesLoading extends PracticeQuizzesState {}
class QuizzesLoaded extends PracticeQuizzesState {
  final List<QuizListItemEntity> quizzes;
  QuizzesLoaded(this.quizzes);
}
class QuizzesError extends PracticeQuizzesState {
  final String message;
  QuizzesError(this.message);
}

// حالات تفاصيل الكويز
class QuizDetailsLoading extends PracticeQuizzesState {}
class QuizDetailsLoaded extends PracticeQuizzesState {
  final QuizDetailEntity quizDetail;
  final Map<int, int> selectedAnswers;

  QuizDetailsLoaded({
    required this.quizDetail,
    required this.selectedAnswers,
  });

  QuizDetailsLoaded copyWith({
    QuizDetailEntity? quizDetail,
    Map<int, int>? selectedAnswers,
  }) {
    return QuizDetailsLoaded(
      quizDetail: quizDetail ?? this.quizDetail,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}
class QuizDetailsError extends PracticeQuizzesState {
  final String message;
  QuizDetailsError(this.message);
}

// حالات الإرسال
class QuizSubmitting extends PracticeQuizzesState {}
class QuizSubmitSuccess extends PracticeQuizzesState {}
class QuizSubmitError extends PracticeQuizzesState {
  final String message;
  QuizSubmitError(this.message);
}
class LastAttemptLoadedState extends PracticeQuizzesState {
  final LastAttemptDetailsEntity lastAttemptDetails;
  LastAttemptLoadedState(this.lastAttemptDetails);
}