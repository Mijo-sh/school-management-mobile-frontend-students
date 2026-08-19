// presentation/widgets/book_slot_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/available_slot.dart';
import '../manager/appointment_bloc.dart';

class BookSlotSheet extends StatefulWidget {
  const BookSlotSheet({super.key});

  @override
  State<BookSlotSheet> createState() => _BookSlotSheetState();
}

class _BookSlotSheetState extends State<BookSlotSheet> {
  AvailableSlot? _selected;

  void _snack(String m, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: color),
    );
  }

  void _submit(BuildContext context, AppointmentState state) {
    // منع الإرسال إذا عنده موعد فعّال
    if (state.hasActive) {
      _snack('لديك موعد فعّال بالفعل، لا يمكنك الحجز مرة أخرى',
          Theme.of(context).colorScheme.error);
      return;
    }
    if (_selected == null) {
      _snack('اختر وقتاً أولاً', Theme.of(context).colorScheme.error);
      return;
    }
    context.read<AppointmentBloc>().add(BookAppointmentEvent(
      date: _selected!.date,
      startTime: _selected!.startTime,
      endTime: _selected!.endTime,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'المواعيد المتاحة',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),

                // تنبيه إذا عنده موعد فعّال
                if (state.hasActive)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لديك موعد فعّال بالفعل، لا يمكنك حجز موعد آخر',
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                // محتوى الأوقات
                Flexible(child: _buildSlots(context, state, cs)),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.hasActive
                        ? null
                        : () => _submit(context, state),
                    icon: const Icon(Icons.send_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('إرسال طلب الحجز'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSlots(
      BuildContext context, AppointmentState state, ColorScheme cs) {
    if (state.slotsStatus == SlotsStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.slotsStatus == SlotsStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(state.message ?? 'تعذّر جلب الأوقات'),
        ),
      );
    }
    if (state.slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'لا توجد أوقات متاحة',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: state.slots.map((slot) {
          final isSel = _selected == slot;
          return ChoiceChip(
            label: Text('${slot.startTime} - ${slot.endTime}'),
            selected: isSel,
            onSelected: state.hasActive
                ? null
                : (_) => setState(() => _selected = slot),
            selectedColor: cs.primary.withOpacity(0.18),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              color: isSel ? cs.primary : cs.onSurface.withOpacity(0.75),
            ),
            side: BorderSide(
              color: isSel ? cs.primary : cs.onSurface.withOpacity(0.15),
            ),
            backgroundColor: cs.surface,
          );
        }).toList(),
      ),
    );
  }
}