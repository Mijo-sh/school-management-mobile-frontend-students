import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../../domain/entities/homework_item.dart';
import '../manager/homeworks_cubit.dart';
import '../../../../core/homework/homework_completion_store.dart';

class HomeworksPage extends StatelessWidget {
  final int? studentId;

  const HomeworksPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<HomeworksCubit>(param1: studentId)..loadHomeworks(),
      child: _HomeworksView(studentId: studentId),
    );
  }
}

class _HomeworksView extends StatefulWidget {
  final int? studentId;
  const _HomeworksView({required this.studentId});

  @override
  State<_HomeworksView> createState() => _HomeworksViewState();
}

class _HomeworksViewState extends State<_HomeworksView> {
  final ScrollController _scrollController = ScrollController();
  late final ConfettiController _confettiController =
  ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeworksCubit>().loadNextPage();
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDueDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  int _daysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool _isOverdue(DateTime dueDate) => _daysUntilDue(dueDate) < 0;

  Path _balloonPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    final bodyRect = Rect.fromLTWH(0, 0, width, height * 0.75);
    path.addOval(bodyRect);

    final knotWidth = width * 0.18;
    final knotTop = height * 0.72;
    path.moveTo((width - knotWidth) / 2, knotTop);
    path.lineTo((width + knotWidth) / 2, knotTop);
    path.lineTo(width / 2, height);
    path.close();

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool canToggleCompletion = widget.studentId == null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Column(
            children: [
              const CurvedHeaderBar(
                title: 'الوظائف',
                backgroundImage: 'assets/images/background_login.jpg',
              ),
              Expanded(
                child: BlocBuilder<HomeworksCubit, HomeworksState>(
                  builder: (context, state) {
                    if (state is HomeworksLoading ||
                        state is HomeworksInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is HomeworksError) {
                      return UnifiedErrorView(
                        message: state.message,
                        onRetry: () =>
                            context.read<HomeworksCubit>().loadHomeworks(),
                      );
                    }

                    final loaded = state as HomeworksLoaded;
                    final sorted = [...loaded.items]
                      ..sort((a, b) {
                        final timeCompare = a.createdAt.compareTo(b.createdAt);
                        if (timeCompare != 0) return timeCompare;
                        return a.id.compareTo(b.id);
                      });

                    final displayList = sorted.reversed.toList();

                    if (displayList.isEmpty) {
                      return const UnifiedEmptyView(
                        icon: Icons.assignment_outlined,
                        message: 'ما في وظائف حاليًا',
                      );
                    }

                    return _HomeworkListView(
                      items: displayList,
                      studentId: widget.studentId,
                      canToggleCompletion: canToggleCompletion,
                      scrollController: _scrollController,
                      dateLabelOf: _dateLabel,
                      timeLabelOf: _timeLabel,
                      chipBuilder: _chip,
                      urgencyChipBuilder: _urgencyChip,
                      isOverdueCheck: _isOverdue,
                      onCompleted: () => _confettiController.play(),
                      emptyMessage: 'ما في وظائف حاليًا',
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              createParticlePath: _balloonPath,
              minimumSize: const Size(12, 16),
              maximumSize: const Size(20, 26),
              emissionFrequency: 0.35,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Color(0xFF6B4EE6),
                Color(0xFFEF9F27),
                Color(0xFFE05C5C),
                Color(0xFF0F9D55),
                Color(0xFF185FA5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(ColorScheme cs, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
            fontSize: 11.5, color: cs.primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _urgencyChip(ColorScheme cs, DateTime dueDate) {
    final diff = _daysUntilDue(dueDate);
    late final Color color;
    late final String text;

    if (diff < 0) {
      color = cs.error;
      text = 'التسليم: ${_formatDueDate(dueDate)}';
    } else if (diff == 1) {
      color = const Color(0xFFEF9F27);
      text = 'التسليم: غدًا';
    } else {
      color = cs.primary;
      text = 'التسليم: ${_formatDueDate(dueDate)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HomeworkListView extends StatelessWidget {
  final List<HomeworkItem> items;
  final int? studentId;
  final bool canToggleCompletion;
  final ScrollController scrollController;
  final String Function(DateTime) dateLabelOf;
  final String Function(DateTime) timeLabelOf;
  final Widget Function(ColorScheme, String, String) chipBuilder;
  final Widget Function(ColorScheme, DateTime) urgencyChipBuilder;
  final bool Function(DateTime) isOverdueCheck;
  final VoidCallback onCompleted;
  final String emptyMessage;

  const _HomeworkListView({
    required this.items,
    required this.studentId,
    required this.canToggleCompletion,
    required this.scrollController,
    required this.dateLabelOf,
    required this.timeLabelOf,
    required this.chipBuilder,
    required this.urgencyChipBuilder,
    required this.isOverdueCheck,
    required this.onCompleted,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = di<HomeworkCompletionStore>();

    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            style: TextStyle(
                color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
      );
    }

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return ListView.builder(
          controller: scrollController,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final showDateLabel = index == items.length - 1 ||
                dateLabelOf(items[index + 1].createdAt) !=
                    dateLabelOf(item.createdAt);

            final leadingIcon = Container(
              width: 45,
              height: 45,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: cs.primary.withOpacity(0.12)),
              child: Image.asset(
                'assets/images/homeworks.png',
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.assignment_rounded, color: cs.primary),
              ),
            );

            final done = store.isCompleted(item.id, studentId: studentId);

            final chips = [
              chipBuilder(cs, 'المادة', item.subjectName),
              urgencyChipBuilder(cs, item.dueDate),
            ];

            // 🕒 إظهار الساعة والدقائق فقط في أسفل الكارد
            final timeStr = timeLabelOf(item.createdAt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDateLabel)
                  DateDividerChip(label: dateLabelOf(item.createdAt)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HomeworkCard(
                    item: item,
                    leadingIcon: leadingIcon,
                    chips: chips,
                    isDone: done,
                    canToggleCompletion: canToggleCompletion,
                    isOverdue: isOverdueCheck(item.dueDate),
                    studentId: studentId,
                    onCompleted: onCompleted,
                    timeLabel: timeStr,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final HomeworkItem item;
  final Widget leadingIcon;
  final List<Widget> chips;
  final bool isDone;
  final bool canToggleCompletion;
  final bool isOverdue;
  final int? studentId;
  final VoidCallback onCompleted;
  final String timeLabel;

  const _HomeworkCard({
    required this.item,
    required this.leadingIcon,
    required this.chips,
    required this.isDone,
    required this.canToggleCompletion,
    required this.isOverdue,
    required this.studentId,
    required this.onCompleted,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isUnread = !item.isRead;

    final Color accentColor = isDone
        ? const Color(0xFF0F9D55)
        : (isUnread ? cs.primary : cs.primary.withOpacity(0.8));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF0F9D55).withOpacity(0.07)
            : (isUnread ? cs.primary.withOpacity(0.08) : cs.surfaceContainer),
        borderRadius: BorderRadius.circular(26),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: accentColor, width: isUnread || isDone ? 1.8 : 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leadingIcon,
                const SizedBox(width: 8),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: isDone
                          ? cs.onSurface.withOpacity(0.45)
                          : cs.onSurface,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: cs.onSurface.withOpacity(0.4),
                      decorationThickness: 2,
                    ),
                    child: Text(item.title, textAlign: TextAlign.right),
                  ),
                ),
                if (isDone) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF0F9D55)),
                ] else if (isUnread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration:
                    BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(isDone ? 0.45 : 0.75),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: chips,
            ),
            if (canToggleCompletion) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: accentColor.withOpacity(0.2)),
              const SizedBox(height: 8),
              _CompletionRow(
                homeworkId: item.id,
                studentId: studentId,
                isOverdue: isOverdue,
                onCompleted: onCompleted,
              ),
            ] else if (isDone) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: accentColor.withOpacity(0.2)),
              const SizedBox(height: 8),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: Color(0xFF0F9D55)),
                  SizedBox(width: 8),
                  Text(
                    'تم حل الوظيفة (مقفولة)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F9D55)),
                  ),
                ],
              ),
            ],
            // ── عرض الوقت (الساعة والدقائق فقط) في أسفل الكارد ──
            const SizedBox(height: 8),
            Divider(color: cs.outlineVariant.withOpacity(0.2), height: 1),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 4),
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
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

class _CompletionRow extends StatelessWidget {
  final int homeworkId;
  final int? studentId;
  final bool isOverdue;
  final VoidCallback onCompleted;

  const _CompletionRow({
    required this.homeworkId,
    required this.studentId,
    required this.isOverdue,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = di<HomeworkCompletionStore>();

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final done = store.isCompleted(homeworkId, studentId: studentId);
        final bool locked = isOverdue;

        if (locked) {
          final color = done ? const Color(0xFF0F9D55) : cs.error;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.lock_clock_rounded,
                  size: 18,
                  color: color),
              const SizedBox(width: 8),
              Text(
                'لقد انتهى وقت التسليم',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: locked
              ? null
              : () {
            final wasCompleted = done;
            store.toggle(homeworkId, studentId: studentId);
            if (!wasCompleted) onCompleted();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? const Color(0xFF0F9D55) : Colors.transparent,
                    border: Border.all(
                      color: done
                          ? const Color(0xFF0F9D55)
                          : cs.primary.withOpacity(locked ? 0.4 : 1),
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  done
                      ? (locked ? 'تم حل الوظيفة (مقفولة)' : 'تم حل الوظيفة')
                      : 'تم حل الوظيفة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? const Color(0xFF0F9D55)
                        : cs.onSurface.withOpacity(locked ? 0.35 : 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}