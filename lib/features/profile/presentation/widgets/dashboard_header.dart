import 'package:flutter/material.dart';
import '../manager/student_cubit.dart';

class DashboardHeader extends StatelessWidget {
  final StudentLoaded data;
  final GlobalKey<ScaffoldState> scaffoldKey;
  static const double _expandedHeight = 300.0;
  static const double _collapsedHeight = 80.0;

  const DashboardHeader({super.key, required this.data, required this.scaffoldKey, int? studentId});

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
                        ]),
                        // داخل الـ Column المسؤول عن الـ Expanded content في ملف dashboard_header.dart
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
                              // 👇 التعديل هنا لربط الرابط بالصورة
                              image: DecorationImage(
                                image: data.photoUrl != null && data.photoUrl!.isNotEmpty
                                    ? NetworkImage(data.photoUrl!) as ImageProvider
                                    : const AssetImage('assets/images/profile.jpg'),
                                fit: BoxFit.cover,
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
                          Container(width: 42, height: 42, decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(initials, style: TextStyle(color: colorScheme.onPrimary)))),
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