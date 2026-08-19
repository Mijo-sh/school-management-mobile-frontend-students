import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../domain/entities/top_student.dart';
import '../manager/top_students_cubit.dart';
import '../widgets/top_student_avatar.dart'; // 👈 عدّل المسار حسب مكان الـ avatar

class TopStudentsPage extends StatelessWidget {
  final int? studentId;
  final int firstTermId;
  final int secondTermId;

  const TopStudentsPage({
    super.key,
    this.studentId,
    required this.firstTermId,
    required this.secondTermId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<TopStudentsCubit>(param1: studentId)
        ..loadTopStudents(semesterId: firstTermId),
      child: _TopStudentsView(
        firstTermId: firstTermId,
        secondTermId: secondTermId,
      ),
    );
  }
}

class _TopStudentsView extends StatefulWidget {
  final int firstTermId;
  final int secondTermId;

  const _TopStudentsView({
    required this.firstTermId,
    required this.secondTermId,
  });

  @override
  State<_TopStudentsView> createState() => _TopStudentsViewState();
}

class _TopStudentsViewState extends State<_TopStudentsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ConfettiController _confettiController;

  // حتى ما نكرّر الاحتفال لنفس الفصل
  final Set<int> _celebratedSemesters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final semesterId =
    _tabController.index == 0 ? widget.firstTermId : widget.secondTermId;
    context.read<TopStudentsCubit>().loadTopStudents(semesterId: semesterId);
  }

  // يفحص إذا في طالب مميّز ويطلق الاحتفال مرة وحدة لكل فصل
  void _maybeCelebrate(List<TopStudent> students) {
    final semesterId =
    _tabController.index == 0 ? widget.firstTermId : widget.secondTermId;

    if (_celebratedSemesters.contains(semesterId)) return;

    final hasHighlighted = students.any((s) => s.isHighlighted);
    if (hasHighlighted) {
      _celebratedSemesters.add(semesterId);
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return  Stack(
        children: [
          Scaffold(
            backgroundColor: cs.surface,
            body: Column(
              children: [
                const CurvedHeaderBar(
                  title: 'أوائل الصف',
                  backgroundImage: 'assets/images/background_login.jpg',
                ),
                // ── التبويبات ──
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: cs.onPrimary,
                    unselectedLabelColor: cs.onSurface.withOpacity(0.6),
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'الفصل الأول'),
                      Tab(text: 'الفصل الثاني'),
                    ],
                  ),
                ),
                // ── المحتوى ──
                Expanded(
                  child: BlocConsumer<TopStudentsCubit, TopStudentsState>(
                    listener: (context, state) {
                      if (state is TopStudentsLoaded) {
                        _maybeCelebrate(state.students);
                      }
                    },
                    builder: (context, state) {
                      if (state is TopStudentsLoading ||
                          state is TopStudentsInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is TopStudentsError) {
                        return _ErrorView(
                          cs: cs,
                          message: state.message,
                          onRetry: () {
                            final semesterId = _tabController.index == 0
                                ? widget.firstTermId
                                : widget.secondTermId;
                            context
                                .read<TopStudentsCubit>()
                                .refresh(semesterId: semesterId);
                          },
                        );
                      }

                      final students = (state as TopStudentsLoaded).students;
                      if (students.isEmpty) {
                        return _EmptyView(cs: cs);
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: students.length,
                        itemBuilder: (_, i) => _TopStudentCard(
                          cs: cs,
                          rank: i + 1,
                          student: students[i],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // ── الكونفيتي فوق كل شي ──
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              gravity: 0.25,
              emissionFrequency: 0.05,
              colors: const [
                Color(0xFFD4AF37),
                Colors.orangeAccent,
                Colors.pinkAccent,
                Colors.lightBlueAccent,
                Colors.greenAccent,
              ],
            ),
          ),
        ],
    );
  }
}
// ── قائمة فارغة ──
class _EmptyView extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyView({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 60, color: cs.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'لا يوجد أوائل لهذا الفصل',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

// ── واجهة الخطأ ──
class _ErrorView extends StatelessWidget {
  final ColorScheme cs;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.cs,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: cs.error),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
// ── كارد طالب من الأوائل ──
class _TopStudentCard extends StatelessWidget {
  final ColorScheme cs;
  final int rank;
  final TopStudent student;

  const _TopStudentCard({
    required this.cs,
    required this.rank,
    required this.student,
  });

  Color _rankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFD4AF37);
      case 2:
        return const Color(0xFF9DA5B0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor();
    final highlighted = student.isHighlighted;

    // لون التمييز الاحتفالي
    const celebrateColor = Color(0xFFD4AF37); // ذهبي

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // خلفية متدرجة خفيفة للمميّز، عادية لغيره
        gradient: highlighted
            ? LinearGradient(
          colors: [
            celebrateColor.withOpacity(0.22),
            celebrateColor.withOpacity(0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        )
            : null,
        color: highlighted ? null : cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        boxShadow: highlighted
            ? [
          BoxShadow(
            color: celebrateColor.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlighted ? celebrateColor : cs.primary.withOpacity(0.4),
            width: highlighted ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط التهنئة يظهر فقط للمميّز
            if (highlighted) ...[
              Row(
                children: [
                  const Icon(Icons.celebration_rounded,
                      size: 18, color: celebrateColor),
                  const SizedBox(width: 6),
                  Text(
                    student.isMe
                        ? 'مبروك! أنت من الأوائل 🎉'
                        : 'مبروك! ابنك من الأوائل 🎉',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: Color(0xFFB8860B), // ذهبي غامق للنص
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                // شارة الترتيب
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 1.5),
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // صورة الطالب
                // صورة الطالب
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withOpacity(0.12),
                  ),
                  child: TopStudentAvatar(
                    photoUrl: student.photoUrl,
                    size: 44,
                    fallback: Icon(Icons.person_rounded, color: cs.primary),
                  ),
                ),                const SizedBox(width: 12),
                // الاسم والصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(  // 👈 كان Flexible، خليه Expanded
                            child: Text(
                              student.fullName,
                              maxLines: 1,                        // 👈 سطر واحد
                              overflow: TextOverflow.ellipsis,    // 👈 ... لو طويل
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (highlighted) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: celebrateColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                student.isMe ? 'أنت' : 'ابنك',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        student.classRoom,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // النسبة
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: highlighted
                        ? celebrateColor.withOpacity(0.15)
                        : cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    student.percentage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color:
                      highlighted ? const Color(0xFFB8860B) : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}