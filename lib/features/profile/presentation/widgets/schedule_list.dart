import 'package:flutter/material.dart';

class DailyScheduleList extends StatelessWidget {
  const DailyScheduleList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // البيانات الخاصة بالجدول
    const List<Map<String, String>> schedule = [
      {'time': '08:00 - 08:45 AM', 'subject': 'Mathematics', 'teacher': 'Mr. Khaled Al-Obeid'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
    ];

    final List<Color> cardColors = [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary];

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final Color currentColor = cardColors[index % cardColors.length];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : Colors.grey[850],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 55, height: 55,
                    decoration: BoxDecoration(color: currentColor, borderRadius: BorderRadius.circular(18)),
                    child: Icon(Icons.menu_book_rounded, color: isLight ? Colors.white : Colors.grey[900], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(width: 2, height: 50, color: Colors.grey.withOpacity(0.2)),
                      Positioned(top: 8, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle))),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule[index]['subject']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(schedule[index]['time']!, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
                            const SizedBox(width: 14),
                            Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                schedule[index]['teacher']!,
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: schedule.length,
        ),
      ),
    );
  }
}

// هذا الـ Delegate يوضع في الـ CustomScrollView مباشرة في الـ slivers
class SliverPinnedTitleDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(context, shrinkOffset, overlapsContent) => Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: Text("Tomorrow's Classes", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)));

  @override
  double get maxExtent => 55.0;
  @override
  double get minExtent => 55.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
}