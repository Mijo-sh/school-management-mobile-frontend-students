import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../data/data_sources/random_tasks_store.dart';
import '../../domain/entities/random_task.dart';

class RandomTasksPage extends StatefulWidget {
  const RandomTasksPage({super.key});

  @override
  State<RandomTasksPage> createState() => _RandomTasksPageState();
}

class _RandomTasksPageState extends State<RandomTasksPage> {
  late final Future<void> _loadFuture = _initializeStoreAndCheckTasks();
  late final ConfettiController _successConfettiController;

  @override
  void initState() {
    super.initState();
    _successConfettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _successConfettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeStoreAndCheckTasks() async {
    final store = di<RandomTasksStore>();
    await store.ensureLoaded();

    // 🔔 تفعيل جدولة الإشعار المحلي اليومي فور فتح صفحة المهام
    try {
      await di<PushNotificationRepository>().scheduleDailyTaskNotification();
    } catch (e) {
      print("خطأ في جدولة الإشعار: $e");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingPreviousTasks(context, store);
    });
  }

  // فحص مهام الأيام السابقة بدقة وإجبار المستخدم على تقييمها إذا لم تكن مقفولة
  Future<void> _checkPendingPreviousTasks(BuildContext context, RandomTasksStore store) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final allPastTasks = store.allTasks.where((t) {
      final taskDate = DateTime(t.date.year, t.date.month, t.date.day);
      return taskDate.isBefore(todayStart);
    }).toList();

    // ما في مهام سابقة أصلاً — ما في شي نعرضه
    if (allPastTasks.isEmpty) return;

    // فلترة المهام السابقة التي لم يتم قفلها بعد
    final uncompletedPastTasks = allPastTasks.where((t) => !t.isLocked).toList();

    // إذا كل المهام مقفولة مسبقاً — روح مباشرة على نافذة النسبة بدون تقييم
    if (uncompletedPastTasks.isEmpty) {
      if (!context.mounted) return;
      _successConfettiController.play();
      _showSuccessAndRatioDialog(context, store);
      return;
    }

    if (!context.mounted) return;

    // متغير لمنع استدعاء نافذة النسبة أكثر من مرة
    bool _ratioShown = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('مراجعة مهام الأيام السابقة', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: uncompletedPastTasks.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: uncompletedPastTasks.length,
                itemBuilder: (context, index) {
                  final task = uncompletedPastTasks[index];
                  return ListTile(
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('تاريخ المهمة: ${task.date.day}/${task.date.month}/${task.date.year}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Color(0xFF0F9D55)),
                          onPressed: () async {
                            await store.setStatus(task.id, true);
                            setDialogState(() => uncompletedPastTasks.removeAt(index));
                            if (uncompletedPastTasks.isEmpty && !_ratioShown && dialogContext.mounted) {
                              _ratioShown = true;
                              Navigator.pop(dialogContext);
                              _successConfettiController.play();
                              _showSuccessAndRatioDialog(context, store);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            await store.setStatus(task.id, false);
                            setDialogState(() => uncompletedPastTasks.removeAt(index));
                            if (uncompletedPastTasks.isEmpty && !_ratioShown && dialogContext.mounted) {
                              _ratioShown = true;
                              Navigator.pop(dialogContext);
                              _successConfettiController.play();
                              _showSuccessAndRatioDialog(context, store);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // نافذة إظهار نسبة إنجاز المهام السابقة مع الاحتفال، ثم حذفها ليبدأ يوم جديد نظيف
  // نحسب القائمة والنسبة هنا مباشرة بعد انتهاء التقييم وقبل أي تأخير async
  void _showSuccessAndRatioDialog(BuildContext context, RandomTasksStore store) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // نأخذ snapshot فوري من الـ store بعد اكتمال القفل
    final pastLockedTasks = store.allTasks.where((t) {
      final taskDate = DateTime(t.date.year, t.date.month, t.date.day);
      return taskDate.isBefore(todayStart) && t.isLocked;
    }).toList();

    // نحسب النسبة قبل ما ندخل الـ dialog
    final int totalCount = pastLockedTasks.length;
    final int doneCount = pastLockedTasks.where((t) => t.isDone).length;
    final String ratio = totalCount > 0
        ? ((doneCount / totalCount) * 100).toStringAsFixed(0)
        : '0';

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.military_tech_rounded, size: 60, color: Colors.amber),
            const SizedBox(height: 12),
            const Text('برافو عليك!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'نسبة إنجازك لمهامك السابقة هي: $ratio%',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // حذف مهام الأيام السابقة بعد تقييمها وعرض النسبة لتختفي من القائمة
                for (final oldTask in pastLockedTasks) {
                  await store.deleteTask(oldTask.id);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('حسناً، لنبدأ اليوم!'),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'random_tasks_today'.tr(context);
    if (diff == 1) return 'random_tasks_tomorrow'.tr(context);
    if (diff == -1) return 'random_tasks_yesterday'.tr(context);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Future<void> _showTaskSheet(BuildContext context, {RandomTask? taskToEdit}) async {
    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final descController = TextEditingController(text: taskToEdit?.description ?? '');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isEditing = taskToEdit != null;

    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEditing ? 'تعديل المهمة' : 'random_tasks_new_task'.tr(context),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(labelText: 'random_tasks_title_field'.tr(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'random_tasks_description_field'.tr(context)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'مهام اليوم (${today.day}/${today.month}/${today.year})',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  final store = di<RandomTasksStore>();

                  if (isEditing) {
                    await store.updateTask(
                      taskToEdit.copyWith(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                  } else {
                    await store.addTask(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      date: today,
                    );
                  }
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: Text(isEditing ? 'حفظ التعديلات' : 'random_tasks_add_button'.tr(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        floatingActionButton: FloatingActionButton(
          backgroundColor: cs.primary,
          onPressed: () => _showTaskSheet(context),
          child: Icon(Icons.add_rounded, color: cs.onPrimary),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                CurvedHeaderBar(
                  title: 'random_tasks_page_title'.tr(context),
                  backgroundImage: 'assets/images/background_login.jpg',
                ),
                Expanded(
                  child: FutureBuilder<void>(
                    future: _loadFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final store = di<RandomTasksStore>();

                      return ListenableBuilder(
                        listenable: store,
                        builder: (context, _) {
                          final tasks = store.allTasks;

                          if (tasks.isEmpty) {
                            return Center(
                              child: Text(
                                'random_tasks_empty'.tr(context),
                                style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final showDateLabel =
                                  index == 0 || _dateLabel(tasks[index - 1].date) != _dateLabel(task.date);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (showDateLabel) DateDividerChip(label: _dateLabel(task.date)),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _TaskCard(
                                      task: task,
                                      formattedDate: _formatDate(task.date),
                                      onEdit: () => _showTaskSheet(context, taskToEdit: task),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _successConfettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final RandomTask task;
  final String formattedDate;
  final VoidCallback onEdit;

  const _TaskCard({required this.task, required this.formattedDate, required this.onEdit});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final store = di<RandomTasksStore>();

    final uniformColor = cs.primary;
    final isDone = widget.task.isDone;
    final isLocked = widget.task.isLocked;

    String taskImagePath = 'assets/images/undefined_task.png';
    if (isDone) {
      taskImagePath = 'assets/images/task_done.png';
    } else if (isLocked && !isDone) {
      taskImagePath = 'assets/images/unfinished_task.png';
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLocked
                ? (isDone ? const Color(0xFF0F9D55).withOpacity(0.07) : cs.error.withOpacity(0.07))
                : uniformColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(26),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLocked ? (isDone ? const Color(0xFF0F9D55) : cs.error) : uniformColor,
                width: 1.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isLocked ? (isDone ? const Color(0xFF0F9D55) : cs.error) : uniformColor).withOpacity(0.15),
                      ),
                      child: Image.asset(
                        taskImagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: (isLocked && isDone) ? cs.onSurface.withOpacity(0.45) : cs.onSurface,
                          decoration: (isLocked && isDone) ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationColor: cs.onSurface.withOpacity(0.4),
                          decorationThickness: 2,
                        ),
                        child: Text(widget.task.title, textAlign: TextAlign.right),
                      ),
                    ),
                  ],
                ),
                if (widget.task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.task.description,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity((isLocked && isDone) ? 0.45 : 0.75), height: 1.4),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: uniformColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_rounded, size: 12, color: uniformColor),
                          const SizedBox(width: 4),
                          Text(widget.formattedDate, style: TextStyle(fontSize: 11.5, color: uniformColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(height: 1, color: uniformColor.withOpacity(0.2)),
                const SizedBox(height: 8),

                isLocked
                    ? Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 18,
                      color: isDone ? const Color(0xFF0F9D55) : cs.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDone ? 'تم إنجاز المهمة (مقفولة)' : 'لم يتم إنجاز المهمة (مقفولة)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDone ? const Color(0xFF0F9D55) : cs.error,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.lock_outline_rounded, size: 16, color: cs.onSurface.withOpacity(0.4)),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _confettiController.play();
                          store.setStatus(widget.task.id, true);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F9D55),
                          side: const BorderSide(color: Color(0xFF0F9D55)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('تم الإنجاز', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => store.setStatus(widget.task.id, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('لم يتم', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),

                if (!isLocked) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 19, color: cs.onSurface.withOpacity(0.6)),
                        onPressed: widget.onEdit,
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 19, color: cs.onSurface.withOpacity(0.4)),
                        onPressed: () => store.deleteTask(widget.task.id),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          createParticlePath: (paint) {
            final path = Path();
            path.addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 8, 8), const Radius.circular(2)));
            return path;
          },
        ),
      ],
    );
  }
}