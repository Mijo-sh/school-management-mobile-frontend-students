import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizLastAttemptScreen extends StatelessWidget {
  final String quizTitle;
  final LastAttemptDetailsEntity lastAttemptDetails;

  const QuizLastAttemptScreen({
    super.key,
    required this.quizTitle,
    required this.lastAttemptDetails,
  });

  @override
  Widget build(BuildContext context) {
    final summary = lastAttemptDetails.attemptSummary;
    final questions = lastAttemptDetails.questionsDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('استعراض الحل السابق: $quizTitle'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ملخص العلامة والنسبة المئوية في الأعلى
          Container(
            padding: const EdgeInsets.all(16),
            color: summary.percentage >= 50 ? Colors.green[100] : Colors.red[100],
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'العلامة: ${summary.earnedMark} / ${summary.totalMark}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'النسبة المئوية: ${summary.percentage}% | تاريخ الحل: ${summary.solvedAt}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),

          // تفاصيل الأسئلة والخيارات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: q.isCorrect ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'السؤال ${index + 1}: ${q.questionText}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              q.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: q.isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // عرض كافة الخيارات وتلوينها بدقة
                        ...q.allOptions.map((option) {
                          bool isUserChoice = option.id == q.selectedOptionId;
                          bool isCorrectChoice = option.isCorrect;

                          Color textColor = Colors.black87;
                          FontWeight fontWeight = FontWeight.normal;
                          IconData iconData = Icons.circle_outlined;
                          Color iconColor = Colors.grey;

                          if (isCorrectChoice) {
                            textColor = Colors.green;
                            fontWeight = FontWeight.bold;
                            iconData = Icons.check;
                            iconColor = Colors.green;
                          } else if (isUserChoice && !q.isCorrect) {
                            textColor = Colors.red;
                            fontWeight = FontWeight.bold;
                            iconData = Icons.close;
                            iconColor = Colors.red;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(iconData, size: 18, color: iconColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option.optionText,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}