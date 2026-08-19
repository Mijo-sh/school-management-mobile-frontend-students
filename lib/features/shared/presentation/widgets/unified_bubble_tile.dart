// presentation/shared/widgets/unified_bubble_tile.dart
import 'package:flutter/material.dart';

class UnifiedBubbleTile extends StatelessWidget {
  final String title;
  final String? description;
  final String timeLabel;
  final bool isUnread;
  final Widget leadingIcon;
  final List<Widget> detailsChips;

  /// أزرار/محتوى اختياري يظهر داخل الفقاعة بعرض كامل (تحت الـ chips).
  /// الأنشطة وغيرها ما بتمرّره، فما بيتأثروا.
  final Widget? bottomActions;
  final Widget? trailing;
  const UnifiedBubbleTile({
    super.key,
    required this.title,
    this.description,
    required this.timeLabel,
    required this.isUnread,
    required this.leadingIcon,
    this.detailsChips = const [],
    this.bottomActions,
    this.trailing, // 👈 جديد

  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUnread ? cs.primary.withOpacity(0.08) : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? cs.primary : cs.primary.withOpacity(0.8),
            width: isUnread ? 1.8 : 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leadingIcon,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
                if (isUnread) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            if (detailsChips.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                children: detailsChips,
              ),
            ],
            // 👇 الأزرار/المحتوى الاختياري بعرض كامل داخل الفقاعة
            if (bottomActions != null) ...[
              const SizedBox(height: 12),
              bottomActions!,
            ],
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.45),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}