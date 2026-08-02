import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/widgets/curved_header_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';


Color colorForSubjectName(String subject) {
  const palette = [
    Color(0xFFE88D9E), // زهري ناعم
    Color(0xFF9B72CF), // بنفسجي هادئ
    Color(0xFF53A6D8), // أزرق سماوي صافي
    Color(0xFF75B798), // أخضر مريح
    Color(0xFFE2C95F), // أصفر دافئ
    Color(0xFFB07D62), // بني ترابي
    Color(0xFF38B6AB), // لون توركواز من عندك
    // Color(0xFFD35252), // أحمر دافئ وهادئ
    // Color(0xFF7E858E),
  ];
  final hash = subject.codeUnits.fold<int>(0, (sum, c) => sum + c);
  return palette[hash % palette.length];
}

class ScheduleEntry {
  final int dayIndex;
  final int periodIndex;
  final String subject;
  final String teacher;
  final String room;
  final String imagePath; // ── مسار الصورة الخاص بكل مادة

  const ScheduleEntry({
    required this.dayIndex,
    required this.periodIndex,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.imagePath,
  });

  Color get color => colorForSubjectName(subject);
}

class WeeklySchedulePage extends StatefulWidget {
  final int? studentId;

  const WeeklySchedulePage({super.key, this.studentId});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  static const List<String> _days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

  static const List<String> _periodLabels = [
    '08:00', '08:45', '09:30', '10:15', '11:00', '11:45', '12:30',
  ];

  // ── تم ربط كل مادة بصورتها الخاصة (من subject1 إلى subject7) بالترتيب
  static const List<({String subject, String teacher, String room, String imagePath})> _subjectsPool = [
    (subject: 'رياضيات', teacher: 'أ. خالد العبيد', room: 'قاعة 12', imagePath: 'assets/images/subject1.png'),
    (subject: 'رياضة', teacher: 'أ. عمر فارس', room: 'الملعب', imagePath: 'assets/images/subject2.png'),
    (subject: 'علوم', teacher: 'أ. ريم يوسف', room: 'مختبر 1', imagePath: 'assets/images/subject3.png'),
    (subject: 'إنكليزي', teacher: 'أ. رنا سعيد', room: 'قاعة 5', imagePath: 'assets/images/subject4.png'),
    (subject: 'جغرافيا', teacher: 'أ. فادي حمدان', room: 'قاعة 7', imagePath: 'assets/images/subject5.png'),
    (subject: 'عربي', teacher: 'أ. لينا حسن', room: 'قاعة 12', imagePath: 'assets/images/subject6.png'),
    (subject: 'فرنسي', teacher: 'أ. ديمة سلوم', room: 'قاعة 9', imagePath: 'assets/images/subject7.png'),
  ];

  static List<ScheduleEntry> get _mockEntries {
    final entries = <ScheduleEntry>[];
    for (int day = 0; day < _days.length; day++) {
      for (int period = 0; period < _periodLabels.length; period++) {
        final subjectIndex = (day * 3 + period) % _subjectsPool.length;
        final s = _subjectsPool[subjectIndex];
        entries.add(ScheduleEntry(
          dayIndex: day,
          periodIndex: period,
          subject: s.subject,
          teacher: s.teacher,
          room: s.room,
          imagePath: s.imagePath,
        ));
      }
    }
    return entries;
  }

  ScheduleEntry? _entryAt(int day, int period) {
    for (final e in _mockEntries) {
      if (e.dayIndex == day && e.periodIndex == period) return e;
    }
    return null;
  }

  static int? get _actualTodayIndex {
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.sunday) return 0;
    if (weekday >= DateTime.monday && weekday <= DateTime.thursday) return weekday;
    return null;
  }

  late int _selectedDayIndex = _actualTodayIndex ?? 0;

  final GlobalKey _captureKey = GlobalKey();
  bool _isProcessing = false;

  Future<Uint8List> _captureBytes() async {
    final boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _shareAsImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureBytes();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/weekly_schedule_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'برنامج الأسبوع'),
      );
    } catch (_) {
      _showError('تعذّرت المشاركة، حاول مجددًا');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureBytes();
      await Gal.putImageBytes(
        bytes,
        name: 'weekly_schedule_${DateTime.now().millisecondsSinceEpoch}',
      );
      _showError('تم حفظ الصورة بالمعرض بنجاح');
    } catch (_) {
      _showError('تعذّر الحفظ — تأكد من صلاحية الوصول للمعرض');
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
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
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
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: entry.color.withOpacity(0.15), shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(entry.imagePath, errorBuilder: (_, __, ___) => Icon(Icons.menu_book_rounded, color: entry.color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.subject, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: cs.onSurface)),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(icon: Icons.person_outline_rounded, label: 'المدرّس', value: entry.teacher),
              const SizedBox(height: 10),
              _DetailRow(icon: Icons.meeting_room_outlined, label: 'القاعة', value: entry.room),
              const SizedBox(height: 10),
              _DetailRow(icon: Icons.access_time_rounded, label: 'الوقت', value: _periodLabels[entry.periodIndex]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actualToday = _actualTodayIndex;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        floatingActionButton: FloatingActionButton(
          onPressed: _isProcessing ? null : _showExportOptions,
          backgroundColor: cs.primary,
          child: _isProcessing
              ? SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: cs.onPrimary),
          )
              : Icon(Icons.more_horiz_rounded, color: cs.onPrimary),
        ),
        body: Column(
          children: [
            const CurvedHeaderBar(
              title: 'برنامج الأسبوع',
              backgroundImage: 'assets/images/background_login.jpg',
            ),

            // ── شريط أفقي بأسماء المواد وصورها الخاصة ──
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _subjectsPool.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = _subjectsPool[i];
                    final subjectColor = colorForSubjectName(s.subject);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: subjectColor.withOpacity(0.35), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            s.imagePath,
                            width: 16,
                            height: 16,
                            errorBuilder: (_, __, ___) => Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: subjectColor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.subject,
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: subjectColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── الجزء يلي بينلقط بالصورة/PDF ──
            Expanded(
              child: RepaintBoundary(
                key: _captureKey,
                child: Container(
                  color: cs.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 52),
                            ...List.generate(_days.length, (i) {
                              final isSelected = i == _selectedDayIndex;
                              final isActualToday = i == actualToday;

                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _selectedDayIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? cs.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _days[i],
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? cs.onPrimary : cs.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          width: 4, height: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActualToday
                                                ? (isSelected ? cs.onPrimary : cs.primary)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                          itemCount: _periodLabels.length,
                          itemBuilder: (context, periodIndex) {
                            final isOddRow = periodIndex.isOdd;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isOddRow ? cs.surfaceContainer.withOpacity(0.35) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: SizedBox(
                                height: 62,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: 52,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cs.primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _periodLabels[periodIndex],
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(_days.length, (dayIndex) {
                                      final entry = _entryAt(dayIndex, periodIndex);
                                      final isSelectedCol = dayIndex == _selectedDayIndex;

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 3),
                                          child: entry == null
                                              ? _EmptyCell(highlighted: isSelectedCol)
                                              : _FilledCell(
                                            entry: entry,
                                            highlighted: isSelectedCol,
                                            onTap: () => _showDetails(context, entry),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportOptionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: cs.primary.withOpacity(0.10), shape: BoxShape.circle),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: cs.onSurface)),
    );
  }
}

class _FilledCell extends StatelessWidget {
  final ScheduleEntry entry;
  final bool highlighted;
  final VoidCallback onTap;

  const _FilledCell({required this.entry, required this.highlighted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: entry.color.withOpacity(highlighted ? 0.22 : 0.13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: entry.color.withOpacity(highlighted ? 0.9 : 0.45), width: highlighted ? 1.6 : 1),
            boxShadow: [
              BoxShadow(color: entry.color.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Opacity(
                opacity: 0.7,
                child: Image.asset(
                  entry.imagePath,
                  width: 30,
                  height: 30,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Text(
                entry.subject,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: entry.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  final bool highlighted;
  const _EmptyCell({required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: highlighted ? cs.surfaceContainer.withOpacity(0.6) : cs.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: highlighted ? Border.all(color: cs.primary.withOpacity(0.25), width: 1) : null,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.remove_rounded, size: 16, color: cs.onSurface.withOpacity(0.25)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 19, color: cs.onSurface.withOpacity(0.5)),
        const SizedBox(width: 10),
        Text('$label:  ', style: TextStyle(fontSize: 13.5, color: cs.onSurface.withOpacity(0.6))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }
}