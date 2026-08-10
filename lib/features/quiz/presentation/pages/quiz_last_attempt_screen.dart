import 'package:flutter/material.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/widgets/curved_header_bar.dart';
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
    final cs = Theme.of(context).colorScheme;
    final summary = lastAttemptDetails.attemptSummary;
    final questions = lastAttemptDetails.questionsDetails;
    final bool passed = summary.percentage >= 50;
    final int correctCount = questions.where((q) => q.isCorrect).length;
    final int wrongCount = questions.length - correctCount;

    return SafeArea(child: Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          CurvedHeaderBar(title:  "النتيجة النهائية",backgroundImage: 'assets/images/background_login.jpg',),
          _ScoreSummary(
            summary: summary,
            passed: passed,
            correctCount: correctCount,
            wrongCount: wrongCount,
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuestionResultCard(index: index, q: q),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}

// ── ملخص العلامة ──
class _ScoreSummary extends StatelessWidget {
  final dynamic summary;
  final bool passed;
  final int correctCount;
  final int wrongCount;
  const _ScoreSummary({
    required this.summary,
    required this.passed,
    required this.correctCount,
    required this.wrongCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = passed ? const Color(0xFF0F9D55) :(isDark? const Color(0xFFF87171): cs.error)
    ;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.6),
        ),
        child: Row(
          children: [
            // دائرة النسبة
            // دائرة النسبة (progress ring يتعبّى حسب النسبة)
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الحلقة الخلفية الباهتة (المسار الكامل)
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.withOpacity(0.15),
                      ),
                    ),
                  ),
                  // الحلقة الملوّنة يلي تتعبّى حسب النسبة
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: (summary.percentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 5,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  // النص بالنص
                  Text(
                    '${summary.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العلامة: ${summary.earnedMark} / ${summary.totalMark}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تاريخ الحل: ${summary.solvedAt}',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.55)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [

                      _CountChip(
                        color: const Color(0xFF0F9D55),
                        icon: Icons.check_circle_rounded,
                        label: 'صحيحة: $correctCount',
                      ),
                      const SizedBox(width: 8),
                      _CountChip(
                        color: isDark? const Color(0xFFF87171):cs.error,
                        icon: Icons.cancel_rounded,
                        label: 'خاطئة: $wrongCount',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── شيب صغير لعرض عدد (صحيحة/خاطئة) ──
class _CountChip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const _CountChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── كارد نتيجة السؤال ──
class _QuestionResultCard extends StatelessWidget {
  final int index;
  final dynamic q;
  const _QuestionResultCard({required this.index, required this.q});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool correct = q.isCorrect;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = correct ? const Color(0xFF0F9D55) :( isDark? const Color(0xFFF87171): cs.error)
    ;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── رقم السؤال + نص + أيقونة النتيجة ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      correct ? 'assets/images/true.png' : 'assets/images/false.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        correct ? Icons.check_rounded : Icons.close_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.questionText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: accentColor.withOpacity(0.15)),
            const SizedBox(height: 8),

            // ── الخيارات ──
            ...q.allOptions.map<Widget>((option) {
              final bool isUserChoice = option.id == q.selectedOptionId;
              final bool isCorrectChoice = option.isCorrect;

              Color optionColor;
              IconData iconData;
              bool highlight = false;

              if (isCorrectChoice) {
                optionColor = const Color(0xFF0F9D55);
                iconData = Icons.check_rounded;
                highlight = true;
              } else if (isUserChoice && !q.isCorrect) {
                optionColor =( isDark? const Color(0xFFF87171):cs.error);
                iconData = Icons.close_rounded;
                highlight = true;
              } else {
                optionColor = cs.onSurface.withOpacity(0.35);
                iconData = Icons.circle_outlined;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: highlight
                      ? optionColor.withOpacity(0.08)
                      : cs.surfaceContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: highlight
                        ? optionColor.withOpacity(0.5)
                        : cs.outlineVariant.withOpacity(0.3),
                    width: highlight ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(iconData, size: 17, color: optionColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.optionText,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: highlight
                              ? optionColor
                              : cs.onSurface.withOpacity(0.5),
                          fontWeight: highlight
                              ? FontWeight.w600
                              : FontWeight.normal,
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
  }
}