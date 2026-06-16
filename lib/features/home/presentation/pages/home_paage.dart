import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _cards = [
    (title: 'Announcements', image: 'assets/images/announcement.png',  color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
    (title: 'Alerts',        image: 'assets/images/alerts.png',        color: Color(0xFFE05C5C), iconBg: Color(0xFFFFEAEA)),
    (title: 'Top Students',  image: 'assets/images/top_students.png',  color: Color(0xFFEF9F27), iconBg: Color(0xFFFEF3CD)),
    (title: 'Certification', image: 'assets/images/cetification.png',  color: Color(0xFF185FA5), iconBg: Color(0xFFDAEEFF)),
    (title: 'Grades',        image: 'assets/images/grades.png',        color: Color(0xFF0F6E56), iconBg: Color(0xFFD4F5E8)),
    (title: 'Homework',      image: 'assets/images/homework.png',      color: Color(0xFFB07D00), iconBg: Color(0xFFFEF3CD)),
    (title: 'Evaluations',   image: 'assets/images/evaluations.png',   color: Color(0xFF993C1D), iconBg: Color(0xFFFAECE7)),
    (title: 'Activities',    image: 'assets/images/activities.png',    color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            _buildHeader(context, cs),
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

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      color: cs.surface,
      child: Container(
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.onPrimary.withOpacity(0.2), width: 2),
              ),
              child: Center(
                child: Text('SA', style: TextStyle(color: cs.onPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: TextStyle(color: cs.onPrimary.withOpacity(0.6), fontSize: 11)),
                const SizedBox(height: 2),
                Text('Sara Adnan Staif', style: TextStyle(color: cs.onPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.notifications_none_rounded, color: cs.onPrimary, size: 20),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
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
      itemCount: _cards.length,
      itemBuilder: (_, i) => _ServiceCard(card: _cards[i]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ({String title, String image, Color color, Color iconBg}) card;
  const _ServiceCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: card.color.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4)),
          const BoxShadow(color: Color(0x07000000), blurRadius: 6, offset: Offset(0, 2)),
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
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}