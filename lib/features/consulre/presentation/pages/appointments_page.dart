// presentation/pages/appointments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../domain/entities/appointment.dart';
import '../manager/appointment_bloc.dart';
import '../widgets/appointment_status_style.dart';
import '../widgets/book_slot_sheet.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          const CurvedHeaderBar(
            title: "مواعيدي مع المرشد",
            backgroundImage: "assets/images/background_login.jpg",
          ),
          Expanded(
            child: BlocConsumer<AppointmentBloc, AppointmentState>(
              listener: (context, state) {
                if (state.status == AppointmentStatus.booked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال طلب الحجز بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state.status == AppointmentStatus.cancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? 'تم إلغاء الموعد بنجاح'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                if (state.status == AppointmentStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? 'حدث خطأ'),
                      backgroundColor: cs.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == AppointmentStatus.loading &&
                    state.appointments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == AppointmentStatus.failure &&
                    state.appointments.isEmpty) {
                  return _ErrorView(
                    cs: cs,
                    message: state.message,
                    onRetry: () => context
                        .read<AppointmentBloc>()
                        .add(GetMyAppointmentsEvent()),
                  );
                }

                final busy = state.status == AppointmentStatus.cancelling ||
                    state.status == AppointmentStatus.booking;

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async => context
                          .read<AppointmentBloc>()
                          .add(GetMyAppointmentsEvent()),
                      child: state.appointments.isEmpty
                          ? _EmptyView(cs: cs)
                          : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: state.appointments.length,
                        itemBuilder: (_, i) {
                          final ap = state.appointments[i];
                          return _AppointmentCard(
                            cs: cs,
                            appointment: ap,
                            onCancel: _canCancel(ap.status)
                                ? () => _confirmCancel(context, ap.id!)
                                : null,
                          );
                        },
                      ),
                    ),
                    if (busy)
                      Container(
                        color: Colors.black.withOpacity(0.05),
                        child:
                        const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // ── زر حجز موعد ──
      floatingActionButton: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () => _openBookSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('حجز موعد مع المرشد'),
          );
        },
      ),
    );
  }

  bool _canCancel(String status) =>
      status == 'pending' || status == 'accepted';

  void _openBookSheet(BuildContext context) {
    final bloc = context.read<AppointmentBloc>();
    bloc.add(GetAvailableSlotsEvent());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const BookSlotSheet(),
      ),
    );
  }

  void _confirmCancel(BuildContext context, int id) {
    final bloc = context.read<AppointmentBloc>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل تريد إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              bloc.add(CancelAppointmentEvent(id: id));
              Navigator.pop(context);
            },
            child: const Text('إلغاء الموعد'),
          ),
        ],
      ),
    );
  }
}
// ── كارد موعد (مبني على التصميم الموحّد) ──
class _AppointmentCard extends StatelessWidget {
  final ColorScheme cs;
  final Appointment appointment;
  final VoidCallback? onCancel;

  const _AppointmentCard({
    required this.cs,
    required this.appointment,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final accent = cs.primary;
    final style = statusStyle(appointment.status);

    // النص الرئيسي حسب الحالة
    String displayTitle = appointment.appointmentDate;
    if (appointment.status == 'pending') {
      displayTitle = 'تم ارسال طلبك سيصلك اشعار عند موافقة المرشد على الطلب';
    } else if (appointment.status == 'completed') {
      displayTitle = 'تم اكمال الموعد';
    } else if (appointment.status == 'cancelled') {
      displayTitle =
      'تم الغاء الطلب ';
    }
    return UnifiedBubbleTile(
      title: displayTitle,
      timeLabel: '',
      isUnread: appointment.status == 'pending',
      leadingIcon: CircleAvatar(
        radius: 16,
        backgroundColor: accent.withOpacity(0.12),
        backgroundImage: const AssetImage('assets/images/avatar.png'),
      ),
      // 👇 التاريخ والوقت فقط
      detailsChips: [
          _InfoChip(
            cs: cs,
            label: 'التاريخ',
            value: appointment.appointmentDate,
          ),
          _InfoChip(
            cs: cs,
            label: 'الوقت',
            value: '${appointment.startTime} - ${appointment.endTime}',
          ),
        ],
      // 👇 الحالة تحت التاريخ والوقت، وفوقها زر الإلغاء (إذا موجود)
      bottomActions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شارة الحالة — محاذاة لجهة النهاية (اليسار بالـ RTL)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                style.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: style.color,
                ),
              ),
            ),
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('إلغاء الموعد'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// ── chip موحّد (نفس ستايل الأنشطة) ──
class _InfoChip extends StatelessWidget {
  final ColorScheme cs;
  final String label;
  final String value;

  const _InfoChip({
    required this.cs,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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

// ── قائمة فارغة ──
class _EmptyView extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyView({required this.cs});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(Icons.event_busy_rounded,
            size: 60, color: cs.onSurface.withOpacity(0.3)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا يوجد لديك مواعيد',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}

// ── واجهة الخطأ ──
class _ErrorView extends StatelessWidget {
  final ColorScheme cs;
  final String? message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.cs,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: cs.error),
            const SizedBox(height: 14),
            Text(message ?? 'حدث خطأ', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}