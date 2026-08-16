import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../domain/entities/schedule_entry.dart';
import '../manager/schedule_cubit (1).dart';
import '../manager/schedule_state (1).dart';

Color colorForSubjectName(String subject) {
  const palette = [
    Color(0xFFE88D9E),
    Color(0xFF9B72CF),
    Color(0xFF53A6D8),
    Color(0xFF75B798),
    Color(0xFFE2C95F),
    Color(0xFFB07D62),
    Color(0xFF38B6AB),
  ];
  final hash = subject.codeUnits.fold<int>(0, (sum, c) => sum + c);
  return palette[hash % palette.length];
}

/// صورة المادة: نجرّب اسم المادة أولًا، وإلا صورة احتياطية.
String imageForSubject(String? subject) {
  if (subject == null || subject.isEmpty) return 'assets/images/subject1.png';
  return 'assets/images/$subject.png';
}

class WeeklySchedulePage extends StatelessWidget {
  /// اختياري: الأب يمرّر id الابن. الطالب لا يمرّر شيء (null) — نجيبه من الجلسة.
  final int? studentId;

  const WeeklySchedulePage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ScheduleCubit>(),
      child: _WeeklyScheduleView(studentId: studentId),
    );
  }
}

class _WeeklyScheduleView extends StatefulWidget {
  final int? studentId;
  const _WeeklyScheduleView({this.studentId});

  @override
  State<_WeeklyScheduleView> createState() => _WeeklyScheduleViewState();
}

class _WeeklyScheduleViewState extends State<_WeeklyScheduleView> {
  static const List<String> _dayKeys = [
    'sunday', 'monday', 'tuesday', 'wednesday', 'thursday'
  ];
  static const List<String> _dayLabels = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'
  ];

  static int? get _actualTodayIndex {
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.sunday) return 0;
    if (weekday >= DateTime.monday && weekday <= DateTime.thursday) return weekday;
    return null;
  }

  late int _selectedDayIndex = _actualTodayIndex ?? 0;

  final GlobalKey _captureKey = GlobalKey();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// يجلب البرنامج. لو الأب مرّر studentId يُرسل، وإلا (طالب = null)
  /// يُرسل null والباك يعرف الطالب من التوكن.
  Future<void> _init() async {
    // الطالب: null. الأب: id الابن. الاثنين صالحين — الـ remote يتعامل معهم.
    context.read<ScheduleCubit>().fetchWeekly(widget.studentId);
  }

  Future<Uint8List> _captureBytes() async {
    final boundary =
    _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showMsg(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _shareAsImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureBytes();
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/weekly_schedule_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'برنامج الأسبوع'),
      );
    } catch (_) {
      _showMsg('تعذّرت المشاركة، حاول مجددًا');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureBytes();
      await Gal.putImageBytes(bytes,
          name: 'weekly_schedule_${DateTime.now().millisecondsSinceEpoch}');
      _showMsg('تم حفظ الصورة بالمعرض بنجاح');
    } catch (_) {
      _showMsg('تعذّر الحفظ — تأكد من صلاحية الوصول للمعرض');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showExportOptions() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2)),
                ),
                _ExportOptionTile(
                  icon: Icons.image_outlined,
                  label: 'حفظ كصورة بالمعرض',
                  onTap: () {
                    Navigator.pop(context);
                    _saveToGallery();
                  },
                ),
                _ExportOptionTile(
                  icon: Icons.ios_share_rounded,
                  label: 'مشاركة',
                  onTap: () {
                    Navigator.pop(context);
                    _shareAsImage();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ScheduleEntry entry) {
    final cs = Theme.of(context).colorScheme;
    final color = colorForSubjectName(entry.subjectName ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.15), shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          imageForSubject(entry.subjectName),
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.menu_book_rounded, color: color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(entry.subjectName ?? '—',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'المدرّس',
                    value: entry.teacherName ?? '—'),
                const SizedBox(height: 10),
                _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'الوقت',
                    value: '${entry.startTime} - ${entry.endTime}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _showExportOptions,
        backgroundColor: cs.primary,
        child: _isProcessing
            ? SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.2, color: cs.onPrimary))
            : Icon(Icons.more_horiz_rounded, color: cs.onPrimary),
      ),
      body: BlocListener<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          // عرض كاش قديم بسبب مشكلة اتصال → تحذير
          if (state is ScheduleLoaded && state.warningMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.warningMessage!),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: Column(
          children: [
            const CurvedHeaderBar(
              title: 'برنامج الأسبوع',
              backgroundImage: 'assets/images/background_login.jpg',
            ),
            Expanded(
              child: BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoading || state is ScheduleInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ScheduleError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 48, color: cs.error),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.error, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _init(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final schedule = (state as ScheduleLoaded).schedule;
                  return _buildContent(cs, schedule);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, WeeklySchedule schedule) {
    final actualToday = _actualTodayIndex;
    final selectedKey = _dayKeys[_selectedDayIndex];
    final dayEntries = schedule[selectedKey] ?? [];

    return RepaintBoundary(
      key: _captureKey,
      child: Container(
        color: cs.surface,
        child: Column(
          children: [
            _DayStrip(
              dayLabels: _dayLabels,
              selectedIndex: _selectedDayIndex,
              actualTodayIndex: actualToday,
              onSelect: (i) => setState(() => _selectedDayIndex = i),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: dayEntries.isEmpty
                  ? Center(
                  child: Text('ما في حصص بهذا اليوم',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.5),
                          fontSize: 14)))
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final entry = dayEntries[index];
                  return _PeriodCard(
                    entry: entry,
                    onTap: () => _showDetails(context, entry),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final ScheduleEntry entry;
  final VoidCallback onTap;

  const _PeriodCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = colorForSubjectName(entry.subjectName ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4), width: 1.2),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 34, height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${entry.periodIndex}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 15)),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.startTime,
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurface.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46, height: 46,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    imageForSubject(entry.subjectName),
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.menu_book_rounded, color: color, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.subjectName ?? '—',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                      const SizedBox(height: 3),
                      Text(entry.teacherName ?? '',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: cs.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded,
                    color: cs.onSurface.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportOptionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10), shape: BoxShape.circle),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 19, color: cs.onSurface.withOpacity(0.5)),
        const SizedBox(width: 10),
        Text('$label:  ',
            style:
            TextStyle(fontSize: 13.5, color: cs.onSurface.withOpacity(0.6))),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
        ),
      ],
    );
  }
}

/// شريط أيام ثابت — الثلاثاء في المنتصف، مع ظل واضح وناعم حول الأطراف وباقي الأيام
class _DayStrip extends StatelessWidget {
  final List<String> dayLabels;
  final int selectedIndex;
  final int? actualTodayIndex;
  final ValueChanged<int> onSelect;

  const _DayStrip({
    required this.dayLabels,
    required this.selectedIndex,
    required this.actualTodayIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(dayLabels.length, (index) {
          final bool isSelected = index == selectedIndex;
          final bool isTuesdayCenter = index == 2;
          final bool isAdjacent = index == 1 || index == 3;
          final bool isOuter = index == 0 || index == 4;

          final double itemHeight = isTuesdayCenter ? 74.0 : (isOuter ? 58.0 : 64.0);

          List<BoxShadow> customShadows;
          if (isSelected) {
            customShadows = [
              BoxShadow(
                color: cs.secondary.withOpacity(0.42),
                blurRadius: 18,
                spreadRadius: 1.5,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ];
          } else if (isTuesdayCenter) {
            customShadows = [
              BoxShadow(
                color: cs.primary.withOpacity(0.38),
                blurRadius: 20,
                spreadRadius: 1.5,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ];
          } else if (isAdjacent) {
            customShadows = [
              BoxShadow(
                color: cs.primary.withOpacity(0.32),
                blurRadius: 22,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ];
          } else {
            customShadows = [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ];
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: 52.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      height: itemHeight,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.secondary
                            : (isLight
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[850]!),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: customShadows,
                        border: isSelected
                            ? null
                            : Border.all(
                          color: isLight
                              ? Colors.grey.withOpacity(0.06)
                              : Colors.white.withOpacity(0.03),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            dayLabels[index],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : cs.onSurface.withOpacity(0.8),
                              fontSize: isTuesdayCenter
                                  ? 13.5
                                  : (isSelected ? 13 : 11.5),
                              fontWeight: (isSelected || isTuesdayCenter)
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}