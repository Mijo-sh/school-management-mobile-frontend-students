import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../profile/presentation/pages/authenticated_avatar.dart'; // 👈 عدّل المسار حسب مكانه عندك
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../../domain/entities/report_card.dart';
import '../manager/report_card_cubit.dart';
import '../manager/report_card_state.dart';

// ===================== اختيار صورة المادة =====================
class _SubjectAsset {
  const _SubjectAsset._();

  // المواد يلي عندك صورة مخصّصة باسمها (بنفس كتابة اسم المادة تمامًا)
  static const Set<String> _known = {
    'Mathematics', 'Physics', 'Chemistry', 'Arabic', 'English',
    'Islamic Studies', 'French', 'History', 'Geography',
    'Computer Science', 'Science', 'Art', 'Music', 'Sports',
  };

  /// مسار الصورة: المخصّصة باسم المادة كما هو، وإلا subjectN (1..7 ثابت لكل مادة).
  static String pathFor(String subjectName) {
    final name = subjectName.trim();
    if (_known.contains(name)) {
      return 'assets/images/$subjectName.png';
    }
    final n = (name.hashCode.abs() % 7) + 1; // 1..7
    return 'assets/images/subjects/subject$n.png';
  }
}

// ===================== الصفحة =====================
class ReportCardPage extends StatelessWidget {
  final int? studentId; // null → الطالب / قيمة → ولي الأمر
  final int firstTermId; // معرّف الفصل الأول
  final int secondTermId; // معرّف الفصل الثاني

  const ReportCardPage({
    super.key,
    this.studentId,
    this.firstTermId = 1,
    this.secondTermId = 2,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ننشئ cubit واحد ونبلّشو بالفصل الأول
      create: (_) => di<ReportCardCubit>(
        param1: studentId,
        param2: firstTermId,
      )..loadReportCard(),
      child: _ReportCardView(
        studentId: studentId,
        firstTermId: firstTermId,
        secondTermId: secondTermId,
      ),
    );
  }
}

class _ReportCardView extends StatefulWidget {
  final int? studentId;
  final int firstTermId;
  final int secondTermId;

  const _ReportCardView({
    this.studentId,
    required this.firstTermId,
    required this.secondTermId,
  });

  @override
  State<_ReportCardView> createState() => _ReportCardViewState();
}

class _ReportCardViewState extends State<_ReportCardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<ReportCardCubit>().loadReportCard(reportCardId: _currentTermId);
  }

  int get _currentTermId =>
      _tabController.index == 0 ? widget.firstTermId : widget.secondTermId;

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          const CurvedHeaderBar(
            title: 'الجلاء',
            backgroundImage: 'assets/images/background_login.jpg',
          ),
          // ── التبويبات (نفس نمط صفحة الأوائل) ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: cs.onPrimary,
              unselectedLabelColor: cs.onSurface.withOpacity(0.6),
              labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'الفصل الأول'),
                Tab(text: 'الفصل الثاني'),
              ],
            ),
          ),
          // ── المحتوى ──
          Expanded(
            child: BlocBuilder<ReportCardCubit, ReportCardState>(
              builder: (context, state) {
                if (state is ReportCardLoading || state is ReportCardInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ReportCardError) {
                  return UnifiedErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<ReportCardCubit>()
                        .loadReportCard(reportCardId: _currentTermId),
                  );
                }
                if (state is ReportCardEmpty) {
                  // رسالة الباك حرفيًا، بقلب الصفحة، بدون زر إعادة
                  return UnifiedEmptyView(
                    icon: Icons.description_outlined,
                    message: state.message,
                  );
                }
                final reportCard = (state as ReportCardLoaded).reportCard;
                return _ReportCardBody(
                  reportCard: reportCard,
                  studentId: widget.studentId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCardBody extends StatelessWidget {
  final ReportCard reportCard;
  final int? studentId;
  const _ReportCardBody({required this.reportCard, this.studentId});

  @override
  Widget build(BuildContext context) {
    final summary = reportCard.summary;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
      children: [
        _SummaryCard(
          studentName: reportCard.studentName,
          summary: summary,
          studentId: studentId,
        ),
        if (summary.failureReasons.isNotEmpty) ...[
          const SizedBox(height: 14),
          _FailureReasonsCard(reasons: summary.failureReasons),
        ],
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('المواد',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ...reportCard.subjects.map(
              (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubjectCard(subject: s),
          ),
        ),
      ],
    );
  }
}

// ===================== كارد الملخّص =====================
class _SummaryCard extends StatelessWidget {
  final String studentName;
  final ReportCardSummary summary;
  final int? studentId;
  const _SummaryCard({
    required this.studentName,
    required this.summary,
    this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final passed = summary.isPassed;
    final resultColor = passed ? Colors.green : cs.error;
    final percent = summary.maxTotalMarks == 0
        ? 0.0
        : (summary.totalMarks / summary.maxTotalMarks).clamp(0.0, 1.0);

    return Container(
      // 👇 الفقاعة الخارجية — نفس نمط كاردات المواد
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        // 👇 الفقاعة الداخلية — حدود ملوّنة
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: resultColor.withOpacity(passed ? 0.55 : 0.7),
            width: passed ? 1.4 : 1.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // صورة الطالب بالدائرة
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: resultColor.withOpacity(0.5), width: 1.8),
                    color: resultColor.withOpacity(0.14),
                  ),
                  child: ClipOval(
                    child: AuthenticatedAvatar(
                      studentId: studentId,
                      size: 52,
                      borderRadius: BorderRadius.circular(26),
                      fallback: Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: resultColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName.replaceAll('_', ' '),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(passed ? 'ناجح' : 'راسب',
                          style: TextStyle(
                              color: resultColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                ),
                _AttendanceBadge(status: summary.attendanceStatus),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع الكلّي',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
                Text(
                    '${_fmt(summary.totalMarks)} / ${_fmt(summary.maxTotalMarks)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 9,
                backgroundColor: cs.primary.withOpacity(0.10),
                valueColor: AlwaysStoppedAnimation(resultColor),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${(percent * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final String status;
  const _AttendanceBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final ok = status.toLowerCase() == 'passed';
    final color = ok ? Colors.green : Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 14, color: color),
          const SizedBox(width: 4),
          Text(ok ? 'حضور مكتمل' : 'حضور ناقص',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ===================== كارد أسباب الرسوب =====================
class _FailureReasonsCard extends StatelessWidget {
  final List<String> reasons;
  const _FailureReasonsCard({required this.reasons});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_gmailerrorred_rounded,
                  color: cs.error, size: 20),
              const SizedBox(width: 6),
              Text('أسباب الرسوب',
                  style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ...reasons.map(
                (r) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: cs.error, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r,
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: cs.onSurface.withOpacity(0.85))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== كارد المادة (نمط الفقاعة + صورة المادة) =====================
class _SubjectCard extends StatelessWidget {
  final SubjectResult subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final passed = subject.isPassed;
    final statusColor = passed ? Colors.green : cs.error;
    final hasEvals = subject.evaluations.isNotEmpty;

    return Container(
      // الفقاعة الخارجية — نفس نمط UnifiedBubbleTile
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        // الفقاعة الداخلية — حدود ملوّنة حسب النجاح/الرسوب
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withOpacity(passed ? 0.55 : 0.7),
            width: passed ? 1.4 : 1.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // صورة المادة
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    _SubjectAsset.pathFor(subject.subjectName),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.menu_book_rounded,
                      size: 25,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(subject.subjectName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5)),
                          ),
                          if (subject.isFailingSubject) ...[
                            const SizedBox(width: 6),
                            _tag(cs, 'أساسية', cs.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                              '${_fmt(subject.subjectTotal)} / ${_fmt(subject.maxMark)}',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          Text('النجاح: ${_fmt(subject.passingMark)}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: cs.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
                _tag(cs, passed ? 'ناجح' : 'راسب', statusColor),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: subject.maxMark == 0
                    ? 0
                    : (subject.subjectTotal / subject.maxMark).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: cs.primary.withOpacity(0.10),
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            if (hasEvals)
              _EvaluationsExpansion(evaluations: subject.evaluations),
          ],
        ),
      ),
    );
  }

  Widget _tag(ColorScheme cs, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ===================== تفاصيل التقييمات (قابلة للطي) =====================
class _EvaluationsExpansion extends StatefulWidget {
  final List<EvaluationItem> evaluations;
  const _EvaluationsExpansion({required this.evaluations});

  @override
  State<_EvaluationsExpansion> createState() => _EvaluationsExpansionState();
}

class _EvaluationsExpansionState extends State<_EvaluationsExpansion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_open ? 'إخفاء التفاصيل' : 'تفاصيل العلامات',
                    style: TextStyle(
                        color: cs.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: cs.primary,
                    size: 18),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
          _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            children:
            widget.evaluations.map((e) => _EvaluationRow(item: e)).toList(),
          ),
        ),
      ],
    );
  }
}

class _EvaluationRow extends StatelessWidget {
  final EvaluationItem item;
  const _EvaluationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name,
                style: TextStyle(
                    fontSize: 12.5, color: cs.onSurface.withOpacity(0.8))),
          ),
          Text('${_fmt(item.mark)} / ${_fmt(item.maxMark)}',
              style:
              const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ===================== helper تنسيق الأرقام =====================
String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2);
}