import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_management_mobile_frontend_students/features/tasks/presentation/widgets/today_tasks_strip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/routing/selected_child_holder.dart';
import '../../../home/presentation/widgets/home_drawer_widget.dart';
import '../../../shared/domain/entities/user_role.dart';
import '../manager/student_cubit.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/schedule_list.dart';

class StudentDashboard extends StatefulWidget {
  /// null = الطالب نفسو عم يشوف داشبوردو. موجود = ولي أمر عم يشوف
  /// داشبورد ابن معيّن — نفس مبدأ studentId بكل مكان تاني بالتطبيق.
  final int? studentId;

  const StudentDashboard({super.key, this.studentId});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // بيتغيّر بس لما يصير سحب يدوي (Pull-to-Refresh) — مربوط بـ key
  // الأفاتار حتى يجبرها تعيد جلب الصورة من الصفر (widget جديد كليًا
  // بمنظور فلاتر، فـ initState بيعيد التنفيذ).
  int _avatarRefreshTick = 0;

  Future<void> _onRefresh() async {
    if (widget.studentId == null) {
      // الطالب نفسو
      await context.read<StudentCubit>().loadStudentData();
    } else {
      final child = di<SelectedChildHolder>().current;
      if (child != null) {
        context.read<StudentCubit>().loadFromChildCard(child);
      }
    }
    setState(() => _avatarRefreshTick++);
  }

  @override
  Widget build(BuildContext context) {
    printAllSharedPreferences();
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawerWidget(isDark: false, role: UserRole.student),
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading || state is StudentInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentError) {
            return _buildError(context, state.message);
          }
          final loaded = state as StudentLoaded;
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                DashboardHeader(
                  data: loaded,
                  scaffoldKey: _scaffoldKey,
                  studentId: widget.studentId,
                  avatarRefreshTick: _avatarRefreshTick,
                ),

                const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ModernCalendarStrip())),

                if (widget.studentId == null)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TodayTasksStrip(),
                    ),
                  ),
                SliverPersistentHeader(
                    pinned: true, delegate: SliverPinnedTitleDelegate()),
                //[cite: 1, 4]
                DailyScheduleList(studentId: widget.studentId),
                //[cite: 1, 4]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56,
                color: colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: colorScheme.onSurface)),
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
}

Future<void> printAllSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();

  final keys = prefs.getKeys();

  debugPrint("--- محتويات SharedPreferences ---");

  for (String key in keys) {
    final value = prefs.get(key);
    debugPrint("Key: $key | Value: $value | Type: ${value.runtimeType}");
    debugPrint("============================================================");
  }

  debugPrint("----------------------------------");
}
Future<void> printAllSecureData() async {
  // إنشاء نسخة من الـ secure storage
  const storage = FlutterSecureStorage();

  // قراءة كافة البيانات المخزنة كـ Map
  Map<String, String> allData = await storage.readAll();

  debugPrint("--- محتويات Flutter Secure Storage ---");
  if (allData.isEmpty) {
    debugPrint("الـ Secure Storage فارغ.");
  } else {
    allData.forEach((key, value) {
      debugPrint("Key: $key | Value: $value");
      debugPrint("---------------------------------------");

    });
  }
  debugPrint("---------------------------------------");
}