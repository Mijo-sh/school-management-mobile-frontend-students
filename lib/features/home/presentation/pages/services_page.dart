import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injector/injector_container.dart';
import '../../../../core/notifications/domain/repositories/push_notification_repository.dart';
import '../../../app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../../app_intro/domain/use_cases/get_user_role_usecase.dart';
import '../../../consulre/presentation/manager/appointment_bloc.dart';
import '../../../consulre/presentation/pages/appointments_page.dart';
import '../../../shared/presentation/widgets/DecorativeHeaderBackground.dart';
import '../../../shared/presentation/widgets/simble_curved_header.dart';
import '../widgets/service_card_tile.dart';
import '../../../shared/domain/entities/user_role.dart';       // نفس مكان الـ enum

typedef ServiceCardEntry = ({
String title,
String image,
Color color,
Color iconBg,
});

class ServicesPage extends StatefulWidget {
  final List<ServiceCardEntry> extraCards;
  final int? studentId;
  final String? childName;

  const ServicesPage({
    super.key,
    this.extraCards = const [],
    this.studentId,
    this.childName,
  });

  static const List<ServiceCardEntry> _sharedCards = [
    (title: 'Announcements', image: 'assets/images/announcement.png', color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
    (title: 'Alerts',        image: 'assets/images/alerts.png',       color: Color(0xFFE05C5C), iconBg: Color(0xFFFFEAEA)),
    (title: 'Top Students',  image: 'assets/images/top_students.png', color: Color(0xFFEF9F27), iconBg: Color(0xFFFEF3CD)),
    (title: 'Certification', image: 'assets/images/cetification.png', color: Color(0xFF185FA5), iconBg: Color(0xFFDAEEFF)),
    (title: 'Grades',        image: 'assets/images/grades.png',       color: Color(0xFF0F6E56), iconBg: Color(0xFFD4F5E8)),
    (title: 'Evaluations',   image: 'assets/images/evaluations.png',  color: Color(0xFF993C1D), iconBg: Color(0xFFFAECE7)),
    (title: 'Activities',    image: 'assets/images/activities.png',   color: Color(0xFF6B4EE6), iconBg: Color(0xFFEDE9FD)),
  ];

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}
class _ServicesPageState extends State<ServicesPage> {
  int _globalBadgeRefreshTick = 0;
  StreamSubscription<Map<String, dynamic>>? _foregroundSub;

  UserRole? _role; // 👈 جديد

  @override
  void initState() {
    super.initState();
    _loadRole(); // 👈 جديد
    _foregroundSub = di<PushNotificationRepository>()
        .onForegroundMessage
        .listen((_) {
      if (mounted) setState(() => _globalBadgeRefreshTick++);
    });
  }


  Future<void> _loadRole() async {
    final result = await di<GetAppSessionUseCase>().call();
    if (!mounted) return;
    result.fold(
          (_) {},
          (session) => setState(() => _role = session.role ?? UserRole.unknown),
    );
  }
  bool get _isStudent => _role == UserRole.student; // 👈 جديد (على مستوى الـ class)

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }

  List<ServiceCardEntry> get _allCards =>
      [...ServicesPage._sharedCards, ...widget.extraCards];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 👆 بدون أي getter هون
    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          SimbleCurvedHeader(title: "قائمة الخدمات"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardsGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isStudent
          ? Padding(
        padding: const EdgeInsets.only(bottom: 70), // 👈 يرفعه فوق الناف
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => di<AppointmentBloc>()..add(GetMyAppointmentsEvent()),
                child: const AppointmentsPage(),
              ),
            ),
          ),
          icon: const Icon(Icons.psychology_rounded),
          label: const Text('المرشد النفسي'),
        ),
      )
          : null,
    );
  }

  Widget _buildCardsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: _allCards.length,
      itemBuilder: (_, i) => ServiceCardTile(
        card: _allCards[i],
        studentId: widget.studentId,
        globalRefreshTick: _globalBadgeRefreshTick,
      ),
    );
  }
}
