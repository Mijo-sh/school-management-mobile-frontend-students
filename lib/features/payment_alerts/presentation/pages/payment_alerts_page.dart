import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injector/injector_container.dart';
import '../../domain/entities/payment_alert_item.dart';
import '../../domain/entities/payment_alert_type.dart';
import '../../../shared/presentation/widgets/curved_header_bar.dart';
import '../../../shared/presentation/widgets/date_divider_chip.dart';
import '../../../shared/presentation/widgets/unified_bubble_tile.dart';
import '../../../shared/presentation/widgets/unified_empty_view.dart';
import '../../../shared/presentation/widgets/unified_error_view.dart';
import '../manager/payment_alerts_cubit.dart';
import '../manager/finance_report_cubit.dart';
import '../manager/finance_report_state.dart';
import '../widgets/finance_report_card.dart';

class PaymentAlertsPage extends StatelessWidget {
  final int? studentId;

  const PaymentAlertsPage({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          di<PaymentAlertsCubit>(param1: studentId)..loadAlerts(),
        ),
        BlocProvider(
          create: (_) =>
          di<FinanceReportCubit>(param1: studentId)..loadReport(),
        ),
      ],
      child: const _PaymentAlertsView(),
    );
  }
}

class _PaymentAlertsView extends StatefulWidget {
  const _PaymentAlertsView();

  @override
  State<_PaymentAlertsView> createState() => _PaymentAlertsViewState();
}

class _PaymentAlertsViewState extends State<_PaymentAlertsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PaymentAlertsCubit>().loadNextPage();
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  List<MapEntry<String, String>> _metaDetails(PaymentAlertItem alert) {
    final m = alert.meta;
    switch (alert.type) {
      case PaymentAlertType.payment:
        final entries = <MapEntry<String, String>>[];
        if (m['due_date'] != null) {
          entries.add(MapEntry(
              'تاريخ الاستحقاق', _formatMetaDate(m['due_date'].toString())));
        }
        if (m['amount_due'] != null) {
          entries
              .add(MapEntry('المبلغ المستحق', _formatAmount(m['amount_due'])));
        }
        return entries;

      case PaymentAlertType.payed:
        if (m['amount'] == null) return [];
        return [MapEntry('المبلغ المدفوع', _formatAmount(m['amount']))];

      case PaymentAlertType.general:
        return [];
    }
  }

  String _formatMetaDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(dynamic raw) {
    final n = num.tryParse(raw.toString());
    if (n == null) return raw.toString();
    return '${n.toStringAsFixed(0)} ل.س';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const CurvedHeaderBar(
              title: 'التنبيهات المالية',
              backgroundImage: 'assets/images/background_login.jpg',
            ),

            // ===== الكارت المالي — ثابت فوق، بسكرول مستقل جوّاه =====
            BlocBuilder<FinanceReportCubit, FinanceReportState>(
              builder: (context, financeState) {
                if (financeState is FinanceReportLoaded) {
                  return ConstrainedBox(
                    // أقصى ارتفاع للكارت. لما لائحة الدفعات تفتح وتتجاوزه،
                    // يبدأ السكرول جوّا الكارت بدل ما يمدد ويضرب من تحت.
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height *0.83,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                      child: FinanceReportCard(report: financeState.report),
                    ),
                  );
                }
                if (financeState is FinanceReportLoading ||
                    financeState is FinanceReportInitial) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                // لو فشل تحميل التقرير، منخفي الكارت بدون ما نكسر الصفحة
                return const SizedBox.shrink();
              },
            ),

            // ===== لائحة التنبيهات — منطقة سكرول مستقلة تحت الكارت =====
            Expanded(
              child: BlocBuilder<PaymentAlertsCubit, PaymentAlertsState>(
                builder: (context, state) {
                  if (state is PaymentAlertsLoading ||
                      state is PaymentAlertsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PaymentAlertsError) {
                    return UnifiedErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<PaymentAlertsCubit>().loadAlerts(),
                    );
                  }

                  final loaded = state as PaymentAlertsLoaded;

                  final sorted = [...loaded.items]
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  final displayList = sorted.reversed.toList();

                  if (displayList.isEmpty) {
                    return const UnifiedEmptyView(
                      icon: Icons.account_balance_wallet_outlined,
                      message: 'ما في تنبيهات مالية حاليًا',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
                    itemCount: displayList.length + (loaded.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // مؤشر تحميل الصفحة التالية (أعلى القائمة بسبب reverse)
                      if (index == displayList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                              CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final alert = displayList[index];

                      final showDateLabel = index == displayList.length - 1 ||
                          _dateLabel(displayList[index + 1].createdAt) !=
                              _dateLabel(alert.createdAt);

                      final leadingIcon = Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.12),
                        ),
                        child: Image.asset(
                          'assets/images/payment.png',
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance_wallet_rounded,
                            color: cs.primary,
                          ),
                        ),
                      );

                      final chips = _metaDetails(alert)
                          .map((e) => _chip(cs, e.key, e.value))
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateLabel)
                            DateDividerChip(
                                label: _dateLabel(alert.createdAt)),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UnifiedBubbleTile(
                              title: alert.title,
                              description: alert.description,
                              timeLabel: _timeLabel(alert.createdAt),
                              isUnread: !alert.isRead,
                              leadingIcon: leadingIcon,
                              detailsChips: chips,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _chip(ColorScheme cs, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
            fontSize: 11.5, color: cs.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}