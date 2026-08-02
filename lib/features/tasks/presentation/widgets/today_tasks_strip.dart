import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/localization/app_localization.dart';
import '../../data/data_sources/random_tasks_store.dart';
import '../../domain/entities/random_task.dart';
import '../../../../core/routing/route_name.dart';

/// تصميم مبسط لمهام اليوم في صفحة البروفايل (بدون عرض تفاصيل أسماء المهام)
class TodayTasksStrip extends StatefulWidget {
  const TodayTasksStrip({super.key});

  @override
  State<TodayTasksStrip> createState() => _TodayTasksStripState();
}

class _TodayTasksStripState extends State<TodayTasksStrip> {
  late final Future<void> _loadFuture = di<RandomTasksStore>().ensureLoaded();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = di<RandomTasksStore>();

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final tasks = store.todayTasks;
            final completedCount = tasks.where((t) => t.isDone).length;
            final totalCount = tasks.length;
            final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: صورة الـ task + العنوان + نسبة الإنجاز + زر العرض ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/task.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'random_tasks_today_title'.tr(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalCount == 0
                                  ? 'لا توجد مهام اليوم'
                                  : '$completedCount من $totalCount مهام منجزة',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(RouteName.randomTasks),
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        label: Text('random_tasks_view_all'.tr(context)),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  // --- شريط التقدم (Progress Bar) ---
                  if (totalCount > 0) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: cs.outlineVariant.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}