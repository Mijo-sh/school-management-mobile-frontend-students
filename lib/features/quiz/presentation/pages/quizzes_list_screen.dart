import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/quiz/presentation/pages/quiz_last_attempt_screen.dart';
import 'package:school_management_mobile_frontend_students/features/quiz/presentation/pages/quiz_view_screen.dart';
import '../manager/practice_quizzes_cubit.dart';
import '../manager/practice_quizzes_state.dart';

class QuizzesListScreen extends StatefulWidget {
  final String subjectName;
  final int subjectId;

  const QuizzesListScreen({super.key, required this.subjectName, required this.subjectId});

  @override
  State<QuizzesListScreen> createState() => _QuizzesListScreenState();
}

class _QuizzesListScreenState extends State<QuizzesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PracticeQuizzesCubit>().fetchQuizzesBySubject(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('كويزات: ${widget.subjectName}'),
        centerTitle: true,
      ),
      body: BlocConsumer<PracticeQuizzesCubit, PracticeQuizzesState>(
        buildWhen: (previous, current) {
          return current is QuizzesLoading || current is QuizzesLoaded || current is QuizzesError;
        },
        listener: (context, state) {
          final quizzesCubit = context.read<PracticeQuizzesCubit>();

          // استعراض الحل السابق يعتمد على الـ listener لأنه حالة فريدة
          if (state is LastAttemptLoadedState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: quizzesCubit,
                  child: QuizLastAttemptScreen(
                    quizTitle: "استعراض الحل السابق",
                    lastAttemptDetails: state.lastAttemptDetails,
                  ),
                ),
              ),
            ).then((_) {
              if (context.mounted) quizzesCubit.fetchQuizzesBySubject(widget.subjectId);
            });
          }

          if (state is QuizDetailsError || state is QuizzesError) {
            final message = state is QuizDetailsError ? state.message : (state as QuizzesError).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizzesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizzesLoaded) {
            if (state.quizzes.isEmpty) {
              return const Center(child: Text('لا توجد اختبارات متاحّة لهذه المادة'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.quizzes.length,
              itemBuilder: (context, index) {
                final quiz = state.quizzes[index];
                final bool hasAttempted = quiz.attemptsCount > 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(quiz.description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('أعلى علامة: ${quiz.highScore} / ${quiz.totalMark}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text('عدد المحاولات: ${quiz.attemptsCount}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (hasAttempted) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final quizzesCubit = context.read<PracticeQuizzesCubit>();

                                    // جلب تفاصيل الاختبار أولاً ثم الانتقال للشاشة مرة واحدة
                                    await quizzesCubit.fetchQuizDetails(quiz.id);
                                    if (!context.mounted) return;

                                    if (quizzesCubit.state is QuizDetailsLoaded) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: quizzesCubit,
                                            child: QuizViewScreen(
                                              quizTitle: quiz.title,
                                              subjectId: widget.subjectId,
                                              isReviewMode: false,
                                            ),
                                          ),
                                        ),
                                      ).then((_) {
                                        if (context.mounted) quizzesCubit.fetchQuizzesBySubject(widget.subjectId);
                                      });
                                    }
                                  },
                                  child: const Text('إعادة الحل'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                    side: const BorderSide(color: Colors.orange),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    context.read<PracticeQuizzesCubit>().fetchLastAttemptDetails(quiz.id);
                                  },
                                  child: const Text('عرض الحل السابق'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                final quizzesCubit = context.read<PracticeQuizzesCubit>();

                                await quizzesCubit.fetchQuizDetails(quiz.id);
                                if (!context.mounted) return;

                                if (quizzesCubit.state is QuizDetailsLoaded) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: quizzesCubit,
                                        child: QuizViewScreen(
                                          quizTitle: quiz.title,
                                          subjectId: widget.subjectId,
                                          isReviewMode: false,
                                        ),
                                      ),
                                    ),
                                  ).then((_) {
                                    if (context.mounted) quizzesCubit.fetchQuizzesBySubject(widget.subjectId);
                                  });
                                }
                              },
                              child: const Text('بدء الاختبار'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is QuizzesError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}