// presentation/features/alerts/alerts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../domain/entities/alert_item.dart';
import '../../domain/entities/alert_type.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/alerts_cubit.dart';

class AlertsPage extends StatelessWidget {
  final int? studentId;

  const AlertsPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<AlertsCubit>(param1: studentId)..loadAlerts(),
      child: const _AlertsView(),
    );
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

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

  List<MapEntry<String, String>> _metaDetails(AlertItem alert) {
    final m = alert.meta;
    switch (alert.type) {
      case AlertType.absence:
        final date = m['date']?.toString();
        if (date == null) return [];
        return [MapEntry('تاريخ الغياب', _formatMetaDate(date))];

      case AlertType.behavior:
        final severity = m['severity']?.toString();
        if (severity == null) return [];
        return [MapEntry('درجة الملاحظة', _severityLabel(severity))];

      case AlertType.late:
        final entries = <MapEntry<String, String>>[];
        if (m['session'] != null) entries.add(MapEntry('الحصة', m['session'].toString()));
        if (m['minutes_late'] != null) {
          entries.add(MapEntry('مدة التأخير', '${m['minutes_late']} دقيقة'));
        }
        return entries;

      case AlertType.escape:
        final session = m['session']?.toString();
        if (session == null) return [];
        return [MapEntry('الحصة', session)];

      case AlertType.homework:
        final entries = <MapEntry<String, String>>[];
        if (m['subject'] != null) entries.add(MapEntry('المادة', m['subject'].toString()));
        if (m['date'] != null) entries.add(MapEntry('تاريخ الواجب', _formatMetaDate(m['date'].toString())));
        return entries;

      case AlertType.general:
        return [];
    }
  }

  String _formatMetaDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day}/${date.month}/${date.year}';
  }

  String _severityLabel(String raw) {
    switch (raw) {
      case 'high':
        return 'مرتفعة';
      case 'medium':
        return 'متوسطة';
      case 'low':
        return 'منخفضة';
      default:
        return raw;
    }
  }

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
              title: 'التنبيهات',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
            Expanded(
              child: BlocBuilder<AlertsCubit, AlertsState>(
                builder: (context, state) {
                  if (state is AlertsLoading || state is AlertsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AlertsError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () => context.read<AlertsCubit>().loadAlerts(),
                    );
                  }

                  final loaded = state as AlertsLoaded;

                  // 1. ترتيب تصاعدي ثم عكس القائمة
                  final sortedAndReversed = [...loaded.alerts]
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  final displayList = sortedAndReversed.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.notifications_off_rounded,
                      message: 'ما في تنبيهات حاليًا',
                    );
                  }

                  return ListView.builder(
                    reverse: true, // البدء من الأسفل 👇
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final alert = displayList[index];

                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].createdAt) != _dateLabel(alert.createdAt);

                      final leadingIcon = Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Image.asset(
                          'assets/images/${alert.type.name}.png',
                          errorBuilder: (_, __, ___) => Icon(Icons.notifications_rounded, color: cs.primary),
                        ),
                      );

                      final chips = _metaDetails(alert).map((e) => _chip(cs, e.key, e.value)).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel) DateDividerChip(label: _dateLabel(alert.createdAt)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: alert.title,
                              description: alert.description,
                              timeLabel: _timeLabel(alert.createdAt),
                              isUnread: !alert.isRead,
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