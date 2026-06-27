import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/student_cubit.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  DateTime selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _expandedHeight = 300.0;
  static const double _collapsedHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(),
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading || state is StudentInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentError) {
            return _buildError(context, state.message);
          }

          // StudentLoaded
          final loaded = state as StudentLoaded;
          return _buildContent(context, loaded);
        },
      ),
    );
  }

  // ── ERROR ────────────────────────────────
  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<StudentCubit>().loadStudentData(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONTENT ──────────────────────────────
  Widget _buildContent(BuildContext context, StudentLoaded data) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // 👇 البيانات الحقيقية
    final String studentName = data.studentName;
    final String gradeName = data.academicInfo.gradeName;
    final String className = data.academicInfo.classNumber;
    final String semesterName = data.academicInfo.semesterName;

    // الحرفان الأولان للأفاتار المصغّر
    final String initials = _initials(studentName);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── HEADER ───────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: _expandedHeight + statusBarHeight,
          collapsedHeight: _collapsedHeight,
          toolbarHeight: _collapsedHeight,
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
          ),
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final double maxH = _expandedHeight + statusBarHeight;
              final double collapseRatio = ((constraints.maxHeight - _collapsedHeight) /
                  (maxH - _collapsedHeight))
                  .clamp(0.0, 1.0);

              final Color textColor = isLight ? Colors.white : Colors.grey[900]!;

              final double imageSize = (115 * collapseRatio).clamp(0.0, 115.0);
              final double fontSize = (19 * collapseRatio).clamp(0.0, 19.0);
              final double subSize = (13 * collapseRatio).clamp(0.0, 13.0);

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: colorScheme.primary),
                    Opacity(
                      opacity: (0.12 * collapseRatio).clamp(0.0, 0.12),
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets/images/background_login.jpg',
                          fit: BoxFit.cover,
                          color: Colors.white,
                          colorBlendMode: BlendMode.difference,
                        ),
                      ),
                    ),

                    // ── EXPANDED content ─────────────────────
                    Positioned(
                      top: statusBarHeight,
                      left: 0, right: 0, bottom: 0,
                      child: Opacity(
                        opacity: collapseRatio,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
                                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                ),
                              ],
                            ),
                            // الصورة لسا ثابتة (ما إلها API)
                            if (imageSize > 0)
                              Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20 * collapseRatio)),
                                  border: Border.all(
                                    color: isLight ? Colors.white : const Color(0xFF2A2A2A),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15 * collapseRatio),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/profile.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(height: 12 * collapseRatio),
                            // 👇 الاسم الحقيقي
                            if (fontSize > 0)
                              Text(
                                studentName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 6 * collapseRatio),
                            // 👇 الصف + الشعبة الحقيقيين
                            if (subSize > 0)
                              Text(
                                '$gradeName — $className',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: subSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── COLLAPSED content ──
                    Positioned(
                      top: statusBarHeight,
                      left: 0, right: 0,
                      height: _collapsedHeight,
                      child: Opacity(
                        opacity: (1.0 - collapseRatio * 2).clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorScheme.onPrimary.withOpacity(0.2), width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hello,', style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.6), fontSize: 11)),
                                  const SizedBox(height: 2),
                                  // 👇 الاسم الحقيقي
                                  Text(studentName, style: TextStyle(color: colorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const Spacer(),
                              Stack(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.notifications_none_rounded, color: colorScheme.onPrimary, size: 20),
                                  ),
                                  Positioned(
                                    top: 6, right: 6,
                                    child: Container(
                                      width: 7, height: 7,
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: colorScheme.primary, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ── CALENDAR STRIP ───────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildModernCalendarStrip(colorScheme),
          ),
        ),

        // ── SCHEDULE TITLE (pinned) ───────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverPinnedTitleDelegate(
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "Tomorrow's Classes",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
            ),
          ),
        ),

        // ── SCHEDULE LIST (لسا ثابت — ما إلو API) ──
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverToBoxAdapter(child: _buildDailySchedule(colorScheme)),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  // ── CALENDAR STRIP ───────────────────────
  Widget _buildModernCalendarStrip(ColorScheme colorScheme) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final int monthOffset = selectedDate.month - 1 + (index - 2);
              final int monthIndex = (monthOffset % 12 + 12) % 12;
              final bool isSelected = index == 2;
              final int dist = (index - 2).abs();

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      months[monthIndex],
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.secondary
                            : colorScheme.onSurface.withOpacity((1.0 - dist * 0.25).clamp(0.3, 0.6)),
                        fontSize: isSelected ? 15 : (14 - dist * 1.5),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Container(
                        width: 16, height: 2.5,
                        decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final DateTime date = selectedDate.add(Duration(days: index - 3));
              final bool isSelected = index == 3;
              final int dist = (index - 3).abs();
              const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 48.0 - (dist * 4.0),
                    height: 76.0 - (dist * 6.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.secondary
                          : (isLight
                          ? Colors.white.withOpacity((1.0 - dist * 0.18).clamp(0.4, 1.0))
                          : Colors.grey[850]!.withOpacity((1.0 - dist * 0.18).clamp(0.3, 1.0))),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(color: colorScheme.secondary.withOpacity(0.38), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 8)),
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                          : [BoxShadow(color: Colors.black.withOpacity(dist == 1 ? 0.04 : 0.01), blurRadius: dist == 1 ? 4 : 1, offset: Offset(0, dist == 1 ? 3 : 1))],
                      border: isSelected ? null : Border.all(
                        color: isLight ? Colors.grey.withOpacity(0.05 * (4 - dist)) : Colors.white.withOpacity(0.02 * (4 - dist)),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[date.weekday - 1],
                          style: TextStyle(
                            color: isSelected ? Colors.white.withOpacity(0.9) : colorScheme.onSurface.withOpacity((1.0 - dist * 0.22).clamp(0.3, 0.6)),
                            fontSize: isSelected ? 11 : (10 - dist * 0.5),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: isSelected ? 6 : 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity((1.0 - dist * 0.22).clamp(0.4, 0.9)),
                            fontSize: isSelected ? 18 : (14 - dist * 0.8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Container(width: 5, height: 5, decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle)),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── DAILY SCHEDULE (ثابت مؤقتاً) ──────────
  Widget _buildDailySchedule(ColorScheme colorScheme) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    const List<Map<String, String>> schedule = [
      {'time': '08:00 - 08:45 AM', 'subject': 'Mathematics', 'teacher': 'Mr. Khaled Al-Obeid'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
      {'time': '08:45 - 10:30 AM', 'subject': 'Physics Class', 'teacher': 'Mr. Sameer Al-Khateeb'},
      {'time': '10:45 - 11:30 AM', 'subject': 'Arabic Language', 'teacher': 'Mr. Marwan Al-Sheikh'},
    ];
    final List<Color> cardColors = [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final Color currentColor = cardColors[index % cardColors.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : Colors.grey[850],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(color: currentColor, borderRadius: BorderRadius.circular(18)),
                  child: Icon(Icons.menu_book_rounded, color: isLight ? Colors.white : Colors.grey[900], size: 24),
                ),
                const SizedBox(width: 12),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(width: 2, height: 50, color: Colors.grey.withOpacity(0.2)),
                    Positioned(top: 8, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle))),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schedule[index]['subject']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(schedule[index]['time']!, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
                          const SizedBox(width: 14),
                          Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              schedule[index]['teacher']!,
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 11),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── SLIVER PINNED TITLE ──────────────────
class _SliverPinnedTitleDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SliverPinnedTitleDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  double get maxExtent => 55.0;
  @override
  double get minExtent => 55.0;
  @override
  bool shouldRebuild(covariant _SliverPinnedTitleDelegate old) => old.child != child;
}