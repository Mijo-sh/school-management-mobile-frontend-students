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

class _ActivitiesView extends StatefulWidget {
  const _ActivitiesView();

  @override
  State<_ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<_ActivitiesView> {
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
      context.read<ActivitiesCubit>().loadNextPage();
    }
  }

  // 👇 نفس الدالتين حرفيًا من alerts_page.dart — بس على createdAt.
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

  // شرائح تفاصيل الفعالية نفسها (موعدها الفعلي) — منفصلة عن
  // createdAt، معلومة إضافية بس زي meta بـ alerts.
  String _formatEventTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour24 = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'ص' : 'م';
    return '$hour12:$minute $period';
  }

  String _formatEventDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(
              title: 'الانشطة',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
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
                  final sorted = [...loaded.activities]
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  final displayList = sorted.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.event_busy_rounded,
                      message: 'ما في أنشطة حاليًا',
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

                      // 👇 مقارنة على createdAt، بالظبط متل alerts_page.dart
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
                        child: Image.asset('assets/images/activity.png'),
                      );

                      // شرائح موعد الفعالية الفعلي (تاريخ ووقت الحدث نفسو)
                      final chips = [
                        _chip(cs, 'التاريخ', _formatEventDate(item.activityDate)),
                        _chip(cs, 'الوقت', '${_formatEventTime(item.startTime)} - ${_formatEventTime(item.endTime)}'),
                      ];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(item.createdAt)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: item.activityName.replaceAll('_', ' '),
                              description: item.description,
                              // 👇 وقت الفقاعة صار من createdAt، بالظبط متل alerts
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