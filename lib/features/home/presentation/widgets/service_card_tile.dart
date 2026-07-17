import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_mobile_frontend_students/features/home/presentation/widgets/unread_badge.dart';
import '../../../../core/routing/route_name.dart';
import '../pages/services_page.dart';

class ServiceCardTile extends StatefulWidget {
  final ServiceCardEntry card;
  final int? studentId;
  final int globalRefreshTick;

  const ServiceCardTile({
    super.key,
    required this.card,
    this.studentId,
    this.globalRefreshTick = 0,
  });

  @override
  State<ServiceCardTile> createState() => _ServiceCardTileState();
}

class _ServiceCardTileState extends State<ServiceCardTile> {
  int _badgeRefreshTick = 0;

  Future<void> _onTap(BuildContext context) async {
    final card = widget.card;
    final studentId = widget.studentId;

    if (card.title == 'Alerts') {
      await context.push(RouteName.alerts, extra: studentId);
    } else if (card.title == 'Announcements') {
      await context.push(RouteName.announcements, extra: studentId);
    } else if (card.title == 'Activities') {
      await context.push(RouteName.activities, extra: studentId);
    } else {
      return;
    }

    if (mounted) {
      setState(() => _badgeRefreshTick++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final studentId = widget.studentId;
    final cs = Theme.of(context).colorScheme;

    final tile = InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? cs.surfaceContainerHigh
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card.color.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Color(0x07000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: card.iconBg,
                padding: const EdgeInsets.all(12),
                child: Image.asset(card.image, fit: BoxFit.contain),
              ),
            ),
            Container(height: 2, color: card.color),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Text(
                card.title,
                style:  TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    const badgeCards = {'Alerts', 'Announcements', 'Activities'};
    if (!badgeCards.contains(card.title)) return tile;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        Positioned(
          top: -6,
          left: -6,
          child: UnreadBadge(
            key: ValueKey('${_badgeRefreshTick}_${widget.globalRefreshTick}'),
            studentId: studentId,
            cardTitle: card.title,
          ),
        ),
      ],
    );
  }
}