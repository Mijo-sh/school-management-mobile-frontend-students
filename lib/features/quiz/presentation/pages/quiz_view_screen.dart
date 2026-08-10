import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../manager/practice_quizzes_cubit.dart';
import '../manager/practice_quizzes_state.dart';
import 'quiz_last_attempt_screen.dart';

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

  // دالة عرض الديالوغ مع الانتقال حصراً عند الضغط على "حسناً"
  void _showResultDialog(BuildContext context, double percentage, dynamic lastAttemptDetails) {
    final bool goodScore = percentage >= 50;
    final Color color = goodScore ? const Color(0xFF0F9D55) : Colors.red;
    final IconData icon =
    goodScore ? Icons.emoji_events_rounded : Icons.menu_book_rounded;
    final String title = goodScore ? 'أحسنت!' : 'واصل التدريب';
    final String message = goodScore
        ? 'أداء رائع في هذا التدريب، استمر بهذا المستوى!'
        : 'راجع الأسئلة التي أخطأت بها وأعد المحاولة، التدريب يصقل مهاراتك.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        title: title,
        message: message,
        percentage: percentage,
        color: color,
        icon: icon,
        celebrate: goodScore, // الاحتفال فقط إذا العلامة 50٪ أو أكثر
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            // ── هيدر ──
            CurvedHeaderBar(
                title: "اختبر معلوماتك",
                backgroundImage: 'assets/images/background_login.jpg'),
            Expanded(
              child: BlocConsumer<PracticeQuizzesCubit, PracticeQuizzesState>(
                buildWhen: (previous, current) =>
                current is QuizDetailsLoading ||
                    current is QuizDetailsLoaded ||
                    current is QuizDetailsError ||
                    current is QuizSubmitting,
                listener: (context, state) {
                  if (state is QuizResultReadyState) {
                    final double percentage = state
                        .lastAttemptDetails.attemptSummary.percentage
                        .toDouble();
                    final navigator = Navigator.of(context);

                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizLastAttemptScreen(
                          quizTitle: quizTitle,
                          lastAttemptDetails: state.lastAttemptDetails,
                        ),
                      ),
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showResultDialog(navigator.context, percentage,
                          state.lastAttemptDetails);
                    });
                  } else if (state is QuizSubmitError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is QuizDetailsLoading || state is QuizSubmitting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is QuizDetailsLoaded) {
                    final questions = state.quizDetail.questions;
                    if (questions.isEmpty) {
                      return const Center(
                          child: Text('لا توجد أسئلة في هذا الاختبار'));
                    }

                    final answeredCount = state.selectedAnswers.length;
                    final totalCount = questions.length;

                    return Column(
                      children: [
                        _ProgressBar(
                          answered: answeredCount,
                          total: totalCount,
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              final selectedOptionId =
                              state.selectedAnswers[question.id];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _QuestionCard(
                                  index: index,
                                  question: question,
                                  selectedOptionId: selectedOptionId,
                                  isReviewMode: isReviewMode,
                                ),
                              );
                            },
                          ),
                        ),
                        if (!isReviewMode)
                          _SubmitButton(
                            answered: answeredCount,
                            total: totalCount,
                            onSubmit: () => context
                                .read<PracticeQuizzesCubit>()
                                .submitAnswers(subjectId),
                          ),
                      ],
                    );
                  }

                  if (state is QuizDetailsError) {
                    return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.red)),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ديالوغ النتيجة مع الاحتفال ──
class _ResultDialog extends StatefulWidget {
  final String title;
  final String message;
  final double percentage;
  final Color color;
  final IconData icon;
  final bool celebrate;

  const _ResultDialog({
    required this.title,
    required this.message,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.celebrate,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (widget.celebrate) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.12),
                ),
                child: Icon(widget.icon, size: 50, color: widget.color),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'النسبة: ${widget.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'حسناً',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── الاحتفال فوق الديالوغ ──
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 25,
          gravity: 0.25,
          emissionFrequency: 0.05,
          colors: const [
            Color(0xFF0F9D55),
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.pink,
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int answered;
  final int total;
  const _ProgressBar({required this.answered, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double progress = total == 0 ? 0 : answered / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدمك في الاختبار',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '$answered / $total',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.primary,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: cs.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── كارد السؤال ──
class _QuestionCard extends StatelessWidget {
  final int index;
  final dynamic question;
  final int? selectedOptionId;
  final bool isReviewMode;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedOptionId,
    required this.isReviewMode,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool answered = selectedOptionId != null;
    final Color accentColor = answered ? const Color(0xFF0F9D55) : cs.primary;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/question.png',
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.questionText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                if (answered)
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF0F9D55)),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: accentColor.withOpacity(0.15)),
            const SizedBox(height: 8),
            ...question.options.map<Widget>((option) {
              final bool isSelected = selectedOptionId == option.id;
              return _OptionTile(
                option: option,
                isSelected: isSelected,
                isReviewMode: isReviewMode,
                accentColor: accentColor,
                onTap: isReviewMode
                    ? null
                    : () => context
                    .read<PracticeQuizzesCubit>()
                    .selectAnswer(question.id, option.id),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── خيار الإجابة ──
class _OptionTile extends StatelessWidget {
  final dynamic option;
  final bool isSelected;
  final bool isReviewMode;
  final Color accentColor;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isReviewMode,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.1)
              : cs.surfaceContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : cs.outlineVariant.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : cs.onSurface.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.optionText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color:
                  isSelected ? accentColor : cs.onSurface.withOpacity(0.85),
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── زر الإرسال ──
class _SubmitButton extends StatelessWidget {
  final int answered;
  final int total;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.answered,
    required this.total,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool allAnswered = answered == total;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border:
        Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: allAnswered
                    ? const Color(0xFF0F9D55)
                    : cs.surfaceContainerHighest,
                foregroundColor: allAnswered
                    ? Colors.white
                    : cs.onSurface.withOpacity(0.38),
                elevation: 0,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: allAnswered ? onSubmit : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allAnswered ? Icons.check_circle_rounded : null,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allAnswered ? "ارسال الاجابات" : "اجب على جميع الاسئلة",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}