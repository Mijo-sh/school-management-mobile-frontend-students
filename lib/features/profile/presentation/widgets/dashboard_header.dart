import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_name.dart';
import '../manager/student_cubit.dart';
import '../pages/authenticated_avatar.dart';

class DashboardHeader extends StatelessWidget {
  final StudentLoaded data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  /// null = الطالب نفسو، موجود = ولي أمر عم يشوف داشبورد ابن معيّن.
  final int? studentId;

  /// بيتغيّر بس عند السحب اليدوي للتحديث (Pull-to-Refresh) — منمررها
  /// كـ key للأفاتار عشان تجبرها تعيد جلب الصورة من الصفر.
  final int avatarRefreshTick;

  static const double _expandedHeight = 300.0;
  static const double _collapsedHeight = 80.0;

  const DashboardHeader({
    super.key,
    required this.data,
    required this.scaffoldKey,
    this.studentId,
    this.avatarRefreshTick = 0,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final String studentName = data.studentName;
    final String gradeName = data.academicInfo.gradeName;
    final String className = data.academicInfo.classNumber;
    final String initials = _initials(studentName);

    return SliverAppBar(
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
          final double collapseRatio = ((constraints.maxHeight - _collapsedHeight) / (maxH - _collapsedHeight)).clamp(0.0, 1.0);
          final Color textColor = isLight ? Colors.white : Colors.grey[900]!;
          final double imageSize = (140 * collapseRatio).clamp(0.0, 140.0);
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
                // Expanded Content
                Positioned(
                  top: statusBarHeight, left: 0, right: 0, bottom: 0,
                  child: Opacity(
                    opacity: collapseRatio,
                    child: Column(
                      children: [
                        Row(children: [
                          IconButton(
                            icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
                            onPressed: () => scaffoldKey.currentState?.openDrawer(),
                          ),
                          const Spacer(),
                          // سهم الرجوع لقائمة الأبناء — بيظهر بس لو ولي
                          // أمر عم يشوف داشبورد ابن.
                          if (studentId != null)
                            IconButton(
                              icon: Icon(Icons.arrow_forward_rounded, color: textColor, size: 26),
                              onPressed: () => context.push(ParentRouteName.home),
                            ),
                        ]),
                        // داخل الـ Column المسؤول عن الـ Expanded content في ملف dashboard_header.dart
                        Visibility(
                          // 👇 maintainState: true هو السطر الحاسم — بيخلي
                          // فلاتر يحافظ على الـ State (والـ Future المخزّنة
                          // فيها) حتى لما الـ widget تختفي مؤقتًا أثناء
                          // أنيميشن السحب، بدل ما يمسحها ويعيد إنشاءها من
                          // الصفر (يلي كان يسبب طلب صورة جديد كل مرة).
                          visible: imageSize > 0,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: false,
                          child: Container(
                            width: imageSize > 0 ? imageSize : 1,
                            height: imageSize > 0 ? imageSize : 1,
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
                            ),
                            // 👇 الصورة صارت موثّقة (بتحمل التوكن) وبتخزّن
                            // بايتاتها محليًا تلقائيًا، بدل NetworkImage الخام.
                            child: AuthenticatedAvatar(
                              key: ValueKey('avatar_expanded_$avatarRefreshTick'),
                              studentId: studentId,
                              size: imageSize > 0 ? imageSize : 1,
                              borderRadius: BorderRadius.circular(20 * collapseRatio),
                              fallback: Icon(Icons.person_rounded, size: imageSize * 0.5, color: isLight ? Colors.white : Colors.grey[700]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(studentName, style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.bold)),
                        Text('$gradeName — $className', style: TextStyle(color: textColor, fontSize: subSize)),
                      ],
                    ),
                  ),
                ),
                // Collapsed Content
                Positioned(
                  top: statusBarHeight, left: 0, right: 0, height: _collapsedHeight,
                  child: Opacity(
                    opacity: (1.0 - collapseRatio * 2).clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AuthenticatedAvatar(
                              key: ValueKey('avatar_collapsed_$avatarRefreshTick'),
                              studentId: studentId,
                              size: 42,
                              borderRadius: BorderRadius.circular(12),
                              fallback: Center(child: Text(initials, style: TextStyle(color: colorScheme.onPrimary))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hello,', style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.6))), Text(studentName, style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w500))]),
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
    );
  }
}
