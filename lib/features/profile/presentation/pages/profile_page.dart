import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            // داخل الـ slivers في CustomScrollView:
            slivers: [
              DashboardHeader(data: loaded, scaffoldKey: _scaffoldKey, studentId: widget.studentId),
              //[cite: 2, 4]
              const SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: ModernCalendarStrip())),
              //[cite: 3, 4]
              SliverPersistentHeader(
                  pinned: true, delegate: SliverPinnedTitleDelegate()),
              //[cite: 1, 4]
              const DailyScheduleList(),
              //[cite: 1, 4]
            ],
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