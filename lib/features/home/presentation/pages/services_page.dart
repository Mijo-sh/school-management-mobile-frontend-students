import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../shared/presentation/widgets/user_header_card.dart';
import '../widgets/service_card_tile.dart';

typedef ServiceCardEntry = ({
String title,
String image,
Color color,
Color iconBg,
});

class ServicesPage extends StatefulWidget {
  final List<ServiceCardEntry> extraCards;
  final int? studentId;
  final String? childName;

  const ServicesPage({
    super.key,
    this.extraCards = const [],
    this.studentId,
    this.childName,
  });

  static const List<ServiceCardEntry> _sharedCards = [
    (title: 'Announcements', image: 'assets/images/announcement.png', color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
    (title: 'Alerts',        image: 'assets/images/alerts.png',       color: Color(0xFFE05C5C), iconBg: Color(0xFFFFEAEA)),
    (title: 'Top Students',  image: 'assets/images/top_students.png', color: Color(0xFFEF9F27), iconBg: Color(0xFFFEF3CD)),
    (title: 'Certification', image: 'assets/images/cetification.png', color: Color(0xFF185FA5), iconBg: Color(0xFFDAEEFF)),
    (title: 'Grades',        image: 'assets/images/grades.png',       color: Color(0xFF0F6E56), iconBg: Color(0xFFD4F5E8)),
    (title: 'Evaluations',   image: 'assets/images/evaluations.png',  color: Color(0xFF993C1D), iconBg: Color(0xFFFAECE7)),
    (title: 'Activities',    image: 'assets/images/activities.png',   color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
  ];

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _globalBadgeRefreshTick = 0;
  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  @override
  void initState() {
    super.initState();
    _foregroundSub = di<PushNotificationRepository>()
        .onForegroundMessage
        .listen((_) {
      if (mounted) setState(() => _globalBadgeRefreshTick++);
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }

  List<ServiceCardEntry> get _allCards => [...ServicesPage._sharedCards, ...widget.extraCards];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            // استخدام المكون المشترك الجديد هنا وبأي شاشة أخرى
            UserHeaderCard(cs: cs, overrideName: widget.childName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildCardsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: _allCards.length,
      itemBuilder: (_, i) => ServiceCardTile(
        card: _allCards[i],
        studentId: widget.studentId,
        globalRefreshTick: _globalBadgeRefreshTick,
      ),
    );
  }
}