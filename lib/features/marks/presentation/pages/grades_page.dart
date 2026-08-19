import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/grades_cubit.dart';

class GradesPage extends StatelessWidget {
  final int? studentId;

  const GradesPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<GradesCubit>(param1: studentId)..loadGrades(),
      child: const _GradesView(),
    );
  }
}

class _GradesView extends StatefulWidget {
  const _GradesView();

  @override
  State<_GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<_GradesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<GradesCubit>().loadNextPage();
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

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return  Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(
              title: 'سجل العلامات',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
            Expanded(
              child: BlocBuilder<GradesCubit, GradesState>(
                builder: (context, state) {
                  if (state is GradesLoading || state is GradesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GradesError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () => context.read<GradesCubit>().loadGrades(),
                    );
                  }

                  final loaded = state as GradesLoaded;
                  final sorted = [...loaded.items]
                    ..sort((a, b) => a.date.compareTo(b.date));
                  final displayList = sorted.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.school_rounded,
                      message: 'ما في علامات مضافة حاليًا',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length + (loaded.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final item = displayList[index];

                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].date) != _dateLabel(item.date);

                      // أيقونة دائرية مميزة للعلامات
                      final leadingIcon = Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Center(
                          child: Image.asset("assets/images/grades_student.png")
                        ),
                      );

                      // شرائح تفاصيل العلامة (المادة، التقييم، العلامة العظمى، المعلم)
                      final chips = [
                        _chip(cs, 'المعلم', item.teacherName),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(item.date)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: item.subjectName,
                              description: "لقد نال الطالب على علامة ${item.mark.toInt()} من ${item.maxMark.toInt()} في ${item.assessmentName}",
                              timeLabel: _timeLabel(item.date),
                              isUnread: !item.isRead,
                              leadingIcon: leadingIcon,
                              detailsChips: chips,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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
        style: TextStyle(fontSize: 11.5, color: cs.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}