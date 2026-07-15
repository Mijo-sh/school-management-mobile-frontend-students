import 'package:flutter/material.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../activities/domain/use_cases/get_unread_activities_count_usecase.dart';
import '../../../alerts/domain/use_cases/get_unread_alerts_count_usecase.dart';
import '../../../announcement/domain/use_cases/get_unread_announcements_count_usecase.dart';

class UnreadBadge extends StatelessWidget {
  final int? studentId;
  final String cardTitle;

  const UnreadBadge({
    super.key,
    this.studentId,
    required this.cardTitle,
  });

  @override
  Widget build(BuildContext context) {
    final Future<int> future;

    switch (cardTitle) {
      case 'Announcements':
        future = di<GetUnreadAnnouncementsCountUseCase>()
            .call(studentId: studentId)
            .then((r) => r.fold((_) => 0, (count) => count));
        break;
      case 'Activities':
        future = di<GetUnreadActivitiesCountUseCase>()
            .call(studentId: studentId)
            .then((r) => r.fold((_) => 0, (count) => count));
        break;
      default: // Alerts
        future = di<GetUnreadAlertsCountUseCase>()
            .call(studentId: studentId)
            .then((r) => r.fold((_) => 0, (count) => count));
    }

    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
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