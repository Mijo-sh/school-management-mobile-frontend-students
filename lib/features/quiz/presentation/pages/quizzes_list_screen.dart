import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/quiz/presentation/pages/quiz_last_attempt_screen.dart';
import 'package:school_management_mobile_frontend_students/features/quiz/presentation/pages/quiz_view_screen.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
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
  // الاشتراك بستريم الإشعارات — لتحديث القائمة تلقائياً عند وصول كويز جديد لنفس المادة.
  StreamSubscription<Map<String, dynamic>>? _notificationSub;

  @override
  void initState() {
    super.initState();
    context.read<PracticeQuizzesCubit>().fetchQuizzesBySubject(widget.subjectId);

    // الاستماع لإشعارات foreground: لو وصل كويز جديد لنفس المادة المفتوحة، نحدّث القائمة.
    _notificationSub =
        di<PushNotificationRepository>().onForegroundMessage.listen(_onNotification);
  }

  void _onNotification(Map<String, dynamic> data) {
    final type = resolveNotificationType(data);
    if (type != NotificationType.newPracticeQuiz) return;

    // نتأكد إنه الإشعار يخص نفس المادة المفتوحة (إن وُجد grade_subject_id بالحمولة).
    final incomingSubjectId =
    int.tryParse(data['grade_subject_id']?.toString() ?? '');

    // لو الحمولة ما فيها معرّف المادة، نحدّث احتياطاً؛ ولو فيها، نحدّث فقط عند التطابق.
    final bool sameSubject =
        incomingSubjectId == null || incomingSubjectId == widget.subjectId;

    if (sameSubject && mounted) {
      context.read<PracticeQuizzesCubit>().fetchQuizzesBySubject(widget.subjectId);
    }
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  // دالة عرض الديالوغ بناءً على المعدل أو النسبة المئوية
  void _showResultDialog(BuildContext context, double percentage) {
    final bool goodScore = percentage >= 50;
    final Color color = goodScore ? const Color(0xFF0F9D55) : Colors.red;
    final IconData icon = goodScore
        ? Icons.emoji_events_rounded
        : Icons.menu_book_rounded;
    final String title = goodScore ? 'أحسنت!' : 'واصل التدريب';
    final String message = goodScore
        ? 'أداء رائع في هذا التدريب، استمر بهذا المستوى!'
        : 'راجع الأسئلة التي أخطأت بها وأعد المحاولة، التدريب يصقل مهاراتك.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                ),
                child: Icon(icon, size: 50, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'النسبة: ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
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
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // إغلاق الديالوغ
                    Navigator.of(context).pop(); // العودة لقائمة الكويزات
                  },
                  child: const Text(
                    'حسناً',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── هيدر الصفحة ──
          CurvedHeaderBar(title: "${widget.subjectName}", backgroundImage: "assets/images/background_login.jpg",),
          Expanded(
            child: BlocConsumer<PracticeQuizzesCubit, PracticeQuizzesState>(
              buildWhen: (previous, current) =>
              current is QuizzesLoading ||
                  current is QuizzesLoaded ||
                  current is QuizzesError,
              listener: (context, state) {
                final cubit = context.read<PracticeQuizzesCubit>();

                if (state is LastAttemptLoadedState) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: QuizLastAttemptScreen(
                          quizTitle: 'استعراض الحل السابق',
                          lastAttemptDetails: state.lastAttemptDetails,
                        ),
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) cubit.fetchQuizzesBySubject(widget.subjectId);
                  });
                }

                if (state is QuizDetailsError || state is QuizzesError) {
                  final message = state is QuizDetailsError
                      ? state.message
                      : (state as QuizzesError).message;
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
                    return Center(
                      child: Text(
                        'لا توجد اختبارات متاحّة لهذه المادة',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.5), fontSize: 14),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: state.quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = state.quizzes[index];
                      final bool hasAttempted = quiz.attemptsCount > 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _QuizCard(
                          quiz: quiz,
                          hasAttempted: hasAttempted,
                          subjectId: widget.subjectId,
                          onQuizSubmitted: (percentage) {
                            _showResultDialog(context, percentage);
                          },
                        ),
                      );
                    },
                  );
                }

                if (state is QuizzesError) {
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
    );
  }
}

// ── كارد الكويز ──
class _QuizCard extends StatefulWidget {
  final dynamic quiz;
  final bool hasAttempted;
  final int subjectId;
  final Function(double) onQuizSubmitted;

  const _QuizCard({
    required this.quiz,
    required this.hasAttempted,
    required this.subjectId,
    required this.onQuizSubmitted,
  });

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  bool _isLoadingStart = false;
  bool _isLoadingReview = false;

  Future<void> _startQuiz(BuildContext context) async {
    setState(() => _isLoadingStart = true);
    final cubit = context.read<PracticeQuizzesCubit>();
    await cubit.fetchQuizDetails(widget.quiz.id);
    if (!mounted) return;
    setState(() => _isLoadingStart = false);

    if (cubit.state is QuizDetailsLoaded) {
      // الانتقال باستخدام rootNavigator لإخفاء الناف بار السفلي تماماً
      final result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: QuizViewScreen(
              quizTitle: widget.quiz.title,
              subjectId: widget.subjectId,
              isReviewMode: false,
            ),
          ),
        ),
      );

      // في حال رجعت النتيجة أو العلامة من شاشة الكويز، يمكنك استقبالها وعرض الديالوغ
      if (result != null && result is Map && result.containsKey('percentage')) {
        widget.onQuizSubmitted(result['percentage']);
      }

      if (context.mounted) {
        cubit.fetchQuizzesBySubject(widget.subjectId);
      }
    }
  }

  Future<void> _reviewQuiz(BuildContext context) async {
    setState(() => _isLoadingReview = true);
    final cubit = context.read<PracticeQuizzesCubit>();
    await cubit.fetchLastAttemptDetails(widget.quiz.id);
    if (!mounted) return;
    setState(() => _isLoadingReview = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color accentColor = widget.hasAttempted ? const Color(0xFF0F9D55) : cs.primary;
    final Color bgColor = widget.hasAttempted
        ? const Color(0xFF0F9D55).withOpacity(0.06)
        : cs.primary.withOpacity(0.06);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
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
              children: [
                Container(
                  width: 55,
                  height: 55,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.12),
                  ),
                  child: Image.asset(
                    'assets/images/quiz.png',
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.quiz_rounded, color: accentColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.quiz.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (widget.hasAttempted)
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF0F9D55)),
              ],
            ),
            if (widget.quiz.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.quiz.description,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.7),
                    height: 1.4),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: [
                _Chip(
                  label: 'أعلى علامة: ${widget.quiz.highScore} / ${widget.quiz.totalMark}',
                  color: cs.primary,
                ),
                _Chip(
                  label: 'المحاولات: ${widget.quiz.attemptsCount}',
                  color: widget.hasAttempted
                      ? const Color(0xFF0F9D55)
                      : cs.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: accentColor.withOpacity(0.2)),
            const SizedBox(height: 10),
            if (widget.hasAttempted)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'إعادة الحل',
                      icon: Icons.refresh_rounded,
                      color: cs.primary,
                      isLoading: _isLoadingStart,
                      onTap: () => _startQuiz(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'عرض الحل السابق',
                      icon: Icons.visibility_rounded,
                      color: const Color(0xFF0F9D55),
                      outlined: true,
                      isLoading: _isLoadingReview,
                      onTap: () => _reviewQuiz(context),
                    ),
                  ),
                ],
              )
            else
              _ActionButton(
                label: 'بدء الاختبار',
                icon: Icons.play_arrow_rounded,
                color: cs.primary,
                fullWidth: true,
                isLoading: _isLoadingStart,
                onTap: () => _startQuiz(context),
              ),
          ],
        ),
      ),
    );
  }
}

// ── chip صغير ──
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11.5, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── زر الأكشن ──
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool fullWidth;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: color.withOpacity(outlined ? 0.7 : 0.25), width: 1),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}