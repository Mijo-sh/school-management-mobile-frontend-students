// lib/features/exam/presentation/pages/exam_schedule_pages.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../../core/notification_types.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../../domain/entities/exam_schedule_entity.dart';
import '../manager/exam_schedule_cubit.dart';
import '../widgets/exam_unread_store.dart';

// ══════════════════════════════════════════════════════════
// صفحة المذاكرات (type = quiz)
// ══════════════════════════════════════════════════════════
class QuizSchedulePage extends StatelessWidget {
  final int? studentId;
  const QuizSchedulePage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return _ExamSchedulePageBase(
      type: ExamType.quiz,
      title: 'برنامج المذاكرات',
      emptyMessage: 'ما في مذاكرات حاليًا',
      studentId: studentId,
    );
  }
}

// ══════════════════════════════════════════════════════════
// صفحة الامتحانات (type = exam)
// ══════════════════════════════════════════════════════════
class ExamsSchedulePage extends StatelessWidget {
  final int? studentId;
  const ExamsSchedulePage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return _ExamSchedulePageBase(
      type: ExamType.exam,
      title: 'برنامج الامتحانات',
      emptyMessage: 'ما في امتحانات حاليًا',
      studentId: studentId,
    );
  }
}

// ══════════════════════════════════════════════════════════
// القاعدة المشتركة للصفحتين
// ══════════════════════════════════════════════════════════
class _ExamSchedulePageBase extends StatelessWidget {
  final ExamType type;
  final String title;
  final String emptyMessage;
  final int? studentId;

  const _ExamSchedulePageBase({
    required this.type,
    required this.title,
    required this.emptyMessage,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ExamScheduleCubit>(param1: studentId, param2: type)..load(),
      child: _ExamScheduleView(
        type: type,
        title: title,
        emptyMessage: emptyMessage,
        studentId: studentId,
      ),
    );
  }
}

class _ExamScheduleView extends StatefulWidget {
  final ExamType type;
  final String title;
  final String emptyMessage;
  final int? studentId;

  const _ExamScheduleView({
    required this.type,
    required this.title,
    required this.emptyMessage,
    required this.studentId,
  });

  @override
  State<_ExamScheduleView> createState() => _ExamScheduleViewState();
}

class _ExamScheduleViewState extends State<_ExamScheduleView> {
  StreamSubscription<Map<String, dynamic>>? _notificationSub;

  @override
  void initState() {
    super.initState();

    // نؤجّل التصفير لبعد اكتمال الإطار الأول حتى لا يستدعي notifyListeners
    // أثناء البناء (يسبب setState during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di<ExamUnreadStore>()
          .markTypeRead(widget.type, studentId: widget.studentId);
    });

    // تحديث تلقائي لو وصل إشعار جدول والتطبيق مفتوح على الصفحة.
    _notificationSub = di<PushNotificationRepository>()
        .onForegroundMessage
        .listen(_onNotification);
  }

  void _onNotification(Map<String, dynamic> data) {
    final t = resolveNotificationType(data);
    if (t == NotificationType.newExamSchedule ||
        t == NotificationType.updateExamSchedule) {
      if (mounted) context.read<ExamScheduleCubit>().load();
    }
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          CurvedHeaderBar(
            title: widget.title,
            backgroundImage: 'assets/images/background_login.jpg',
          ),
          Expanded(
            child: BlocBuilder<ExamScheduleCubit, ExamScheduleState>(
              builder: (context, state) {
                if (state is ExamScheduleLoading ||
                    state is ExamScheduleInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExamScheduleError) {
                  return UnifiedErrorView(
                    message: state.message,
                    onRetry: () => context.read<ExamScheduleCubit>().load(),
                  );
                }

                final loaded = state as ExamScheduleLoaded;
                if (loaded.items.isEmpty) {
                  return UnifiedEmptyView(
                    icon: Icons.event_note_rounded,
                    message: widget.emptyMessage,
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                  itemCount: loaded.items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExamScheduleCard(item: loaded.items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// كارت بند الجدول (الكارت الخارجي)
// ══════════════════════════════════════════════════════════
class _ExamScheduleCard extends StatelessWidget {
  final ExamScheduleItem item;
  const _ExamScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color accentColor = cs.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor, width: 1.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان + مؤشر غير مقروء
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.12),
                  ),
                  child: Image.asset(
                    item.isExam
                        ? "assets/images/exam.png"
                        : "assets/images/test.png",
                  ),
                ),
              const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (!item.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1F9D55),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: accentColor.withOpacity(0.8)),
            const SizedBox(height: 20),

            // المواد: كل مادة بينها وبين التالية فاصل (divider)
            for (int i = 0; i < item.subjects.length; i++) ...[
              _SubjectRow(subject: item.subjects[i]),
              if (i != item.subjects.length - 1) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: accentColor.withOpacity(0.18)),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// صف المادة: avatar دائري (صورة باسم المادة) + الاسم +
// المقرر (كـ description) ثم التاريخ والوقت
// ══════════════════════════════════════════════════════════
class _SubjectRow extends StatelessWidget {
  final ExamSubjectInfo subject;
  const _SubjectRow({required this.subject});

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('yyyy/MM/dd').format(d);
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0]}:${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الاسم + الصورة الدائرية (avatar) جنبه
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withOpacity(0.12),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/${subject.subjectName}.png',
                  fit: BoxFit.cover,
                  // لو ما في صورة باسم المادة، نستخدم subject1.png
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/subject1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.menu_book_rounded,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                subject.subjectName,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),

        // المقرر (كـ description) — أكبر شوي، قبل التاريخ والوقت
        if (subject.syllabus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text("المقرر: ${subject.syllabus}",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.75),
              height: 1.5,
            ),
          ),
        ],

        const SizedBox(height: 8),

        // التفاصيل: تاريخ + وقت
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 6,
          runSpacing: 6,
          children: [
            _chip(cs, 'التاريخ', _formatDate(subject.examDate)),
            _chip(cs, 'الوقت',
                '${_formatTime(subject.startTime)} - ${_formatTime(subject.endTime)}'),
          ],
        ),
      ],
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
        style: TextStyle(
          fontSize: 11.5,
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}