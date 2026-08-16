import 'package:flutter/material.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/unread_counts_store.dart';

/// بادج العدد غير المقروء — هلق بتقرا مباشرة من [UnreadCountsStore]
/// (Singleton محمّل مسبقًا بمستوى الـ Shell)، بدل ما تعمل طلب سيرفر
/// مستقل لحالها كل مرة تُبنى. صفر تأخير، وتحديث تلقائي فوري لما
/// الـ Store يتغيّر (تحميل أولي، إشعار جديد، أو تصفير قراءة).
class UnreadBadge extends StatelessWidget {
  final int? studentId;
  final String cardTitle;

  const UnreadBadge({
    super.key,
    this.studentId,
    required this.cardTitle,
  });

  int _countFor(UnreadCountsStore store) {
    switch (cardTitle) {
      case 'Announcements':
        return store.announcements;
      case 'Activities':
        return store.activities;
      case 'Evaluations':
        return store.evaluations;
      case 'Homeworks':
        return store.homeworks;
      case 'Grades':
        return store.grades;
      case 'File Helper':
        return store.materials;
      default: // Alerts
        return store.alerts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = di<UnreadCountsStore>();

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final count = _countFor(store);
        if (count <= 0) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1F9D55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Center(
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
