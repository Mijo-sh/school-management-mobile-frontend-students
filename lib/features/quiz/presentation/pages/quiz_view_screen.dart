import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/practice_quizzes_cubit.dart';
import '../manager/practice_quizzes_state.dart';

class QuizViewScreen extends StatelessWidget {
  final String quizTitle;
  final int subjectId;
  final bool isReviewMode;

  const QuizViewScreen({
    super.key,
    required this.quizTitle,
    required this.subjectId,
    required this.isReviewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isReviewMode ? 'استعراض الحل السابق: $quizTitle' : quizTitle),
        centerTitle: true,
      ),
      body: BlocConsumer<PracticeQuizzesCubit, PracticeQuizzesState>(
        buildWhen: (previous, current) {
          // منع إعادة بناء الشاشة بالكامل عند اختيار إجابة (لتجنب فتح واجهات متكررة)،
          // والسماح بإعادة البناء فقط عند حالات التحميل، الأخطاء، أو نجاح الإرسال
          return current is QuizDetailsLoading ||
              current is QuizDetailsLoaded ||
              current is QuizDetailsError ||
              current is QuizSubmitting;
        },
        listener: (context, state) {
          if (state is QuizSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال إجابات الاختبار بنجاح!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is QuizSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizDetailsLoading || state is QuizSubmitting) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuizDetailsLoaded) {
            final questions = state.quizDetail.questions;
            if (questions.isEmpty) {
              return const Center(child: Text('لا توجد أسئلة في هذا الاختبار'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final selectedOptionId = state.selectedAnswers[question.id];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السؤال ${index + 1}: ${question.questionText}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...question.options.map((option) {
                                return RadioListTile<int>(
                                  title: Text(option.optionText),
                                  value: option.id,
                                  groupValue: selectedOptionId,
                                  onChanged: isReviewMode
                                      ? null
                                      : (val) {
                                    if (val != null) {
                                      context.read<PracticeQuizzesCubit>().selectAnswer(question.id, val);
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!isReviewMode)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        context.read<PracticeQuizzesCubit>().submitAnswers(subjectId);
                      },
                      child: const Text('إرسال الإجابات', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
              ],
            );
          } else if (state is QuizDetailsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}