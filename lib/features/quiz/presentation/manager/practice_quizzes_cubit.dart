import 'package:bloc/bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/use_cases/get_last_attempt_details_usecase.dart';
import 'practice_quizzes_state.dart';

import '../../domain/use_cases/get_quiz_details_usecase.dart';
import '../../domain/use_cases/get_quizzes_by_subject_usecase.dart';
import '../../domain/use_cases/submit_quiz_answers_usecase.dart';

class PracticeQuizzesCubit extends Cubit<PracticeQuizzesState> {
  final GetQuizzesBySubjectUseCase getQuizzesBySubjectUseCase;
  final GetQuizDetailsUseCase getQuizDetailsUseCase;
  final SubmitQuizAnswersUseCase submitQuizAnswersUseCase;
  final GetLastAttemptDetailsUseCase getLastAttemptDetailsUseCase;

  Map<int, int> lastSubmittedAnswers = {};

  PracticeQuizzesCubit({
    required this.getQuizzesBySubjectUseCase,
    required this.getQuizDetailsUseCase,
    required this.submitQuizAnswersUseCase,
    required this.getLastAttemptDetailsUseCase,
  }) : super(PracticeQuizzesInitial());

  Future<void> fetchQuizzesBySubject(int subjectId) async {
    emit(QuizzesLoading());
    final result = await getQuizzesBySubjectUseCase(subjectId);
    result.fold(
          (failure) => emit(QuizzesError(failure.message)),
          (quizzes) => emit(QuizzesLoaded(quizzes)),
    );
  }

  Future<void> fetchQuizDetails(int quizId) async {
    emit(QuizDetailsLoading());
    final result = await getQuizDetailsUseCase(quizId);

    result.fold(
          (failure) => emit(QuizDetailsError(failure.message)),
          (quizDetail) => emit(QuizDetailsLoaded(quizDetail: quizDetail, selectedAnswers: {})),
    );
  }

  void selectAnswer(int questionId, int optionId) {
    if (state is QuizDetailsLoaded) {
      final currentState = state as QuizDetailsLoaded;
      final updatedAnswers = Map<int, int>.from(currentState.selectedAnswers);
      updatedAnswers[questionId] = optionId;
      emit(currentState.copyWith(selectedAnswers: updatedAnswers));
    }
  }

  Future<void> submitAnswers(int subjectId) async {
    if (state is! QuizDetailsLoaded) return;
    final currentState = state as QuizDetailsLoaded;

    lastSubmittedAnswers = Map.from(currentState.selectedAnswers);

    final List<SubmitAnswerEntity> answersList = currentState.selectedAnswers.entries.map((entry) {
      return SubmitAnswerEntity(
        questionId: entry.key,
        optionId: entry.value,
      );
    }).toList();

    emit(QuizSubmitting());
    final result = await submitQuizAnswersUseCase(answers: answersList);

    result.fold(
          (failure) => emit(QuizSubmitError(failure.message)),
          (_) {
        emit(QuizSubmitSuccess());
        fetchQuizzesBySubject(subjectId);
      },
    );
  }

  Future<void> fetchLastAttemptDetails(int quizId) async {
    emit(QuizDetailsLoading());
    final result = await getLastAttemptDetailsUseCase(quizId);

    result.fold(
          (failure) => emit(QuizDetailsError(failure.message)),
          (lastAttemptDetails) => emit(LastAttemptLoadedState(lastAttemptDetails)),
    );
  }
}