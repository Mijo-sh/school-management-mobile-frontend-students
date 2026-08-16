import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../exam/presentation/widgets/exam_unread_store.dart';
import '../../../shared/presentation/widgets/simble_curved_header.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/routing/route_name.dart';

class SchedulesHubPage extends StatelessWidget {
  /// null للطالب نفسه، أو id الابن عند ولي الأمر.
  final int? studentId;

  const SchedulesHubPage({super.key, this.studentId});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                children: [
                  // 1. كارد برنامج الأسبوع
                  _ScheduleCard(
                    title: 'برنامج الأسبوع',
                    subtitle: 'عرض الحصص اليومية والجدول الأسبوعي',
                    imagePath: 'assets/images/week_schedule.png',
                    gradient: const [Color(0xFF5B8DB8), Color(0xFF89C4E1)],
                    onTap: () {
                      context.push(RouteName.week_schedule, extra: studentId);
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. كارد برنامج المذاكرات (type = quiz)
                  _ScheduleCard(
                    title: 'برنامج المذاكرات',
                    subtitle: 'مواعيد المذاكرات والاختبارات القصيرة',
                    imagePath: 'assets/images/test_schedule.png',
                    gradient: const [Color(0xFF8A9E7A), Color(0xFFBDD4AD)],
                    badgeSelector: (store) => store.quizzesCount,
                    onTap: () {
                      context.push(RouteName.quizSchedule, extra: studentId);
                    },
                  ),
                  const SizedBox(height: 14),

                  // 3. كارد برنامج الامتحانات (type = exam)
                  _ScheduleCard(
                    title: 'برنامج الامتحانات',
                    subtitle: 'جدول الامتحانات الفصلية النهائية',
                    imagePath: 'assets/images/exam_schedule.png',
                    gradient: const [Color(0xFF9A8CA8), Color(0xFFC9BDD6)],
                    badgeSelector: (store) => store.examsCount,
                    onTap: () {
                      context.push(RouteName.examsSchedule, extra: studentId);
                    },
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

class _ScheduleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradient;
  final VoidCallback onTap;

  /// اختياري: دالة تختار العدّاد من الـ store لعرض البادج.
  /// لو null، ما في بادج (زي كارت برنامج الأسبوع).
  final int Function(ExamUnreadStore store)? badgeSelector;

  const _ScheduleCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.imagePath,
    this.badgeSelector,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: _isLoading ? null : _handleTap,
      child: Container(
        width: double.infinity,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
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
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.85),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            ],
          ),
        ),
      ),
    );

    if (widget.badgeSelector == null) return card;

    final store = di<ExamUnreadStore>();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -6,
          right: -6,
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final count = widget.badgeSelector!(store);
              if (count <= 0) return const SizedBox.shrink();
              return Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F9D55),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}