import 'package:flutter/material.dart';
import '../../../../core/localization/app_localization.dart';

class ModernCalendarStrip extends StatefulWidget {
  const ModernCalendarStrip({super.key});

  @override
  State<ModernCalendarStrip> createState() => _ModernCalendarStripState();
}

class _ModernCalendarStripState extends State<ModernCalendarStrip> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> months = [
      "month_january".tr(context), "month_february".tr(context), "month_march".tr(context),
      "month_april".tr(context), "month_may".tr(context), "month_june".tr(context),
      "month_july".tr(context), "month_august".tr(context), "month_september".tr(context),
      "month_october".tr(context), "month_november".tr(context), "month_december".tr(context),
    ];
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final int monthOffset = selectedDate.month - 1 + (index - 2);
              final int monthIndex = (monthOffset % 12 + 12) % 12;
              final bool isSelected = index == 2;
              final int dist = (index - 2).abs();

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      months[monthIndex],
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.secondary
                            : colorScheme.onSurface.withOpacity((1.0 - dist * 0.25).clamp(0.3, 0.6)),
                        fontSize: isSelected ? 15 : (14 - dist * 1.5),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Container(
                        width: 16, height: 2.5,
                        decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final DateTime date = selectedDate.add(Duration(days: index - 3));
              final bool isSelected = index == 3;
              final int dist = (index - 3).abs();
              final List<String> days = [
                "day_sunday".tr(context), "day_monday".tr(context), "day_tuesday".tr(context),
                "day_wednesday".tr(context), "day_thursday".tr(context), "day_friday".tr(context),
                "day_saturday".tr(context),
              ];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 48.0 - (dist * 4.0),
                    height: 76.0 - (dist * 6.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.secondary
                          : (isLight
                          ? Colors.white.withOpacity((1.0 - dist * 0.18).clamp(0.4, 1.0))
                          : Colors.grey[850]!.withOpacity((1.0 - dist * 0.18).clamp(0.3, 1.0))),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(color: colorScheme.secondary.withOpacity(0.38), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                          : [BoxShadow(color: Colors.black.withOpacity(dist == 1 ? 0.04 : 0.01), blurRadius: dist == 1 ? 4 : 1, offset: Offset(0, dist == 1 ? 3 : 1))],
                      border: isSelected ? null : Border.all(
                        color: isLight ? Colors.grey.withOpacity(0.05 * (4 - dist)) : Colors.white.withOpacity(0.02 * (4 - dist)),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[date.weekday % 7],
                          style: TextStyle(
                            color: isSelected ? Colors.white.withOpacity(0.9) : colorScheme.onSurface.withOpacity((1.0 - dist * 0.22).clamp(0.3, 0.6)),
                            fontSize: isSelected ? 11 : (10 - dist * 0.5),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: isSelected ? 6 : 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity((1.0 - dist * 0.22).clamp(0.4, 0.9)),
                            fontSize: isSelected ? 18 : (14 - dist * 0.8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Container(width: 5, height: 5, decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle)),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}