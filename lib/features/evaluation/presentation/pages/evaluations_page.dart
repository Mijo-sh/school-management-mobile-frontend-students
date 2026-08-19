import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/evaluations_cubit.dart';

class EvaluationsPage extends StatelessWidget {
  final int? studentId;

  const EvaluationsPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<EvaluationsCubit>(param1: studentId)..loadEvaluations(),
      child: const _EvaluationsView(),
    );
  }
}

class _EvaluationsView extends StatefulWidget {
  const _EvaluationsView();

  @override
  State<_EvaluationsView> createState() => _EvaluationsViewState();
}

class _EvaluationsViewState extends State<_EvaluationsView> {
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
      context.read<EvaluationsCubit>().loadNextPage();
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
              title: 'التقييمات',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
            Expanded(
              child: BlocBuilder<EvaluationsCubit, EvaluationsState>(
                builder: (context, state) {
                  if (state is EvaluationsLoading || state is EvaluationsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EvaluationsError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () => context.read<EvaluationsCubit>().loadEvaluations(),
                    );
                  }

                  final loaded = state as EvaluationsLoaded;
                  final sorted = [...loaded.items]
                    ..sort((a, b) {
                      final timeCompare = a.createdAt.compareTo(b.createdAt);
                      if (timeCompare != 0) return timeCompare;
                      // نفس الوقت → رتّب على الـ id (ثابت ومتوقّع)
                      return a.id.compareTo(b.id);
                    });
                  final displayList = sorted.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.grade_outlined,
                      message: 'ما في تقييمات حاليًا',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].createdAt) != _dateLabel(item.createdAt);

                      final leadingIcon = Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Image.asset(
                          'assets/images/${item.rating.assetName}.png',
                          errorBuilder: (_, __, ___) => Icon(Icons.grade_rounded, color: cs.primary),
                        ),
                      );

                      final chips = [
                        _chip(cs, 'المادة', item.subjectName),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(item.createdAt)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: item.rating.translationKey.tr(context),
                              description: item.notes,
                              timeLabel: _timeLabel(item.createdAt),
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
