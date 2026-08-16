import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../weekly_schedule/domain/entities/schedule_entry.dart';
import '../manager/tomorrow_schedule_cubit.dart';
import '../manager/tomorrow_schedule_state.dart';

/// palette من 7 ألوان.
const List<Color> _cardPalette = [
  Color(0xFFE88D9E),
  Color(0xFF9B72CF),
  Color(0xFF53A6D8),
  Color(0xFF75B798),
  Color(0xFFE2A93B),
  Color(0xFFB07D62),
  Color(0xFF38B6AB),
];

/// لون حسب اسم المادة — نفس المادة دائمًا نفس اللون.
Color _colorForSubject(String? subject) {
  final s = subject ?? '';
  final hash = s.codeUnits.fold<int>(0, (sum, ch) => sum + ch);
  return _cardPalette[hash % _cardPalette.length];
}

String _imageForSubject(String? subject) {
  if (subject == null || subject.isEmpty) return 'assets/images/subject1.png';
  return 'assets/images/$subject.png';
}

/// قائمة حصص الغد كـ Sliver. تجيب من API الغد.
/// [studentId] اختياري: الأب يمرّره، الطالب null (الباك يعرفه من التوكن).
class DailyScheduleList extends StatelessWidget {
  final int? studentId;
  const DailyScheduleList({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocProvider(
        create: (_) => di<TomorrowScheduleCubit>(),
        child: _DailyScheduleView(studentId: studentId),
      ),
    );
  }
}

class _DailyScheduleView extends StatefulWidget {
  final int? studentId;
  const _DailyScheduleView({this.studentId});

  @override
  State<_DailyScheduleView> createState() => _DailyScheduleViewState();
}

class _DailyScheduleViewState extends State<_DailyScheduleView> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // الطالب: null (الباك يعرفه من التوكن). الأب: id الابن.
    context.read<TomorrowScheduleCubit>().fetchTomorrow(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<TomorrowScheduleCubit, TomorrowScheduleState>(
      builder: (context, state) {
        if (state is TomorrowLoading || state is TomorrowInitial) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TomorrowError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.error, fontSize: 14)),
            ),
          );
        }

        final loaded = state as TomorrowLoaded;
        if (loaded.entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text('ما في حصص بكرا',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          child: Column(
            children: loaded.entries
                .map((e) => _TomorrowCard(
              entry: e,
              color: _colorForSubject(e.subjectName),
            ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _TomorrowCard extends StatelessWidget {
  final ScheduleEntry entry;
  final Color color;
  const _TomorrowCard({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${entry.periodIndex}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15)),
                ),
                const SizedBox(height: 4),
                Text(entry.startTime,
                    style: TextStyle(
                        fontSize: 10, color: cs.onSurface.withOpacity(0.5))),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 46, height: 46,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                _imageForSubject(entry.subjectName),
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.menu_book_rounded, color: color, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.subjectName ?? '—',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: cs.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text('${entry.startTime} - ${entry.endTime}',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 13, color: cs.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(entry.teacherName ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنوان مثبّت "حصص الغد".
class SliverPinnedTitleDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  const SliverPinnedTitleDelegate({this.title = 'حصص الغد'});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 55.0;
  @override
  double get minExtent => 55.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
}