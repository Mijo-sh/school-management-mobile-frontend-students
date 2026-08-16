import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/widgets/simble_curved_header.dart';
import '../../../../core/routing/route_name.dart';
import '../../../subject/presentation/manager/subjects_cubit.dart';
import '../manager/practice_quizzes_cubit.dart';
import '../widgets/quiz_unread_store.dart';
import '../widgets/subject_quiz_badge.dart';
import '../../../../core/injector/injector_container.dart';

// قائمة الـ gradients اللي رح تتوزع على الكاردات بالتسلسل
const List<List<Color>> _cardGradients = [
  [Color(0xFF7B9EA6), Color(0xFFB2CDD4)],
  [Color(0xFF8A9E7A), Color(0xFFBDD4AD)],
  [Color(0xFF9A8CA8), Color(0xFFC9BDD6)],
  [Color(0xFF9E8F7A), Color(0xFFD4C4AD)],
  [Color(0xFF5B8DB8), Color(0xFF89C4E1)],
  [Color(0xFF6BAF92), Color(0xFFA8D5BA)],
  [Color(0xFFB07BAC), Color(0xFFD4A8D0)],
  [Color(0xFFD4845A), Color(0xFFEDB48E)],
];

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          const SimbleCurvedHeader(
            title: 'الكويزات',
          ),
          Expanded(
            child: BlocBuilder<SubjectsCubit, SubjectsState>(
              builder: (context, state) {
                if (state is SubjectsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SubjectsLoaded) {
                  if (state.subjects.isEmpty) {
                    return const Center(child: Text('لا توجد مواد متاحّة حالياً'));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.subjects.length,
                          itemBuilder: (context, index) {
                            final subject = state.subjects[index];
                            final gradient =
                                _cardGradients[index % _cardGradients.length];
                            final imageName = '${subject.subjectName}.png';

                            return _SubjectCard(
                              subject: subject,
                              gradient: gradient,
                              imageName: imageName,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else if (state is SubjectsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
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

class _SubjectCard extends StatefulWidget {
  const _SubjectCard({
    required this.subject,
    required this.gradient,
    required this.imageName,
  });

  final dynamic subject;
  final List<Color> gradient;
  final String imageName;

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool _isLoading = false;

  Future<void> _handleTap(BuildContext context) async {
    setState(() => _isLoading = true);

    final subjectId = widget.subject.gradeSubjectId;

    // تصفير عدّاد كويزات هذه المادة فورًا (تفاؤلي) — البادج يختفي مباشرة
    di<QuizUnreadStore>().markSubjectRead(subjectId);

    // إتاحة وقت قصير لبدء الـ Cubit وتجهيزه
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // إنشاء الـ Cubit وتمريره عبر الـ router (نفس نمط باقي الشاشات)
    final cubit = di<PracticeQuizzesCubit>();

    if (!context.mounted) return;
    context.push(
      StudentRouteName.practiceQuizzesList,
      extra: {
        'cubit': cubit,
        'subjectName': widget.subject.subjectName,
        'subjectId': subjectId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/background_login.jpg',
                    fit: BoxFit.cover,
                    color: Colors.white,
                    colorBlendMode: BlendMode.difference,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.25),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/${widget.imageName}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.subject.subjectName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ],
                ),
              ),

              // ── بادج عدّاد الكويزات غير المقروءة (بالركن العلوي) ──
              Positioned(
                top: 8,
                right: 8,
                child: SubjectQuizBadge(
                  subjectId: widget.subject.gradeSubjectId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
