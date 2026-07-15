// presentation/features/activities/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/activities_cubit.dart';

class ActivitiesPage extends StatelessWidget {
  final int? studentId;

  const ActivitiesPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ActivitiesCubit>(param1: studentId)..loadActivities(),
      child: const _ActivitiesView(),
    );
  }
}

class _ActivitiesView extends StatelessWidget {
  const _ActivitiesView();

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'غدًا';
    if (diff == -1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour24 = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'ص' : 'م';
    return '$hour12:$minute $period';
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(title: 'الأنشطة'),
            Expanded(
              child: BlocBuilder<ActivitiesCubit, ActivitiesState>(
                builder: (context, state) {
                  if (state is ActivitiesLoading || state is ActivitiesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ActivitiesError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () => context.read<ActivitiesCubit>().loadActivities(),
                    );
                  }

                  final loaded = state as ActivitiesLoaded;

                  // 1. نرتبها تصاعدياً بالتاريخ، ثم نعكس المصفوفة لتتوافق مع reverse: true
                  final sortedAndReversed = [...loaded.activities]
                    ..sort((a, b) => a.activityDate.compareTo(b.activityDate));
                  final displayList = sortedAndReversed.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.event_busy_rounded,
                      message: 'ما في أنشطة حاليًا',
                    );
                  }

                  return ListView.builder(
                    reverse: true, // البدء من الأسفل 👇
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];

                      // بما أن المصفوفة معكوسة، شرط إظهار التاريخ يعتمد على العنصر التالي في القائمة المعكوسة (الذي يسبقه زمنياً)
                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].activityDate) != _dateLabel(item.activityDate);

                      final leadingIcon = Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Image.asset(
                          'assets/images/activities.png',
                          errorBuilder: (_, __, ___) => Icon(Icons.emoji_events_rounded, color: cs.primary),
                        ),
                      );

                      final chips = [
                        _chip(cs, 'التاريخ', _formatDate(item.activityDate)),
                        _chip(cs, 'الوقت', '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}'),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(item.activityDate)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: item.activityName.replaceAll('_', ' '),
                              timeLabel: '',
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