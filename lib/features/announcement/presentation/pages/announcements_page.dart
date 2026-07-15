// presentation/features/announcements/announcements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../domain/entities/announcement_item.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/announcements_cubit.dart';

class AnnouncementsPage extends StatelessWidget {
  final int? studentId;

  const AnnouncementsPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<AnnouncementsCubit>(param1: studentId)..loadAnnouncements(),
      child: const _AnnouncementsView(),
    );
  }
}

class _AnnouncementsView extends StatelessWidget {
  const _AnnouncementsView();

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(title: 'الإعلانات'),
            Expanded(
              child: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
                builder: (context, state) {
                  if (state is AnnouncementsLoading || state is AnnouncementsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AnnouncementsError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () => context.read<AnnouncementsCubit>().loadAnnouncements(),
                    );
                  }

                  final loaded = state as AnnouncementsLoaded;

                  // 1. ترتيب تصاعدي ثم عكس القائمة
                  final sortedAndReversed = [...loaded.announcements]
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  final displayList = sortedAndReversed.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.campaign_outlined,
                      message: 'ما في إعلانات حاليًا',
                    );
                  }

                  return ListView.builder(
                    reverse: true, // البدء من الأسفل 👇
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Image.asset(
                          'assets/images/announcements.png',
                          errorBuilder: (_, __, ___) => Icon(Icons.campaign_rounded, color: cs.primary),
                        ),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(item.createdAt)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: item.title,
                              timeLabel: _timeLabel(item.createdAt),
                              isUnread: !item.isRead,
                              leadingIcon: leadingIcon,
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
}