import 'package:flutter/material.dart';

import '../../domain/entities/finance_report.dart';

class FinanceReportCard extends StatelessWidget {
  final FinanceReport report;
  const FinanceReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final summary = report.summary;
    // نسبة المدفوع من الإجمالي
    final percent = summary.totalAmount == 0
        ? 0.0
        : (summary.paidAmount / summary.totalAmount).clamp(0.0, 1.0);
    final statusColor = _statusColor(cs, summary.paymentStatus);

    return Container(
      // الفقاعة الخارجية
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        // الفقاعة الداخلية
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.55), width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان: أيقونة + اسم الخطة + سياسة التقسيط
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/payment.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.account_balance_wallet_rounded,
                      color: cs.primary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.planName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(report.installmentPolicyName,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                _statusTag(cs, summary.paymentStatus, statusColor),
              ],
            ),
            const SizedBox(height: 16),

            // شريط التقدّم للمدفوع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المدفوع من الإجمالي',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
                Text('${_fmt(summary.paidAmount)} / ${_fmt(summary.totalAmount)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 9,
                backgroundColor: cs.primary.withOpacity(0.10),
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 12),

            // المبلغ المتبقّي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المتبقّي',
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
                Text(_fmt(summary.remainingBalance),
                    style: TextStyle(
                        color: cs.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),

            // كبسة فتح لائحة الدفعات (قابلة للطي)
            _InstallmentsExpansion(
              installments: report.installments,
              transactions: report.transactions,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme cs, String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partially_paid':
        return const Color(0xFFB07D00); // كهرماني
      default: // unpaid / غيره
        return cs.error;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'مدفوع بالكامل';
      case 'partially_paid':
        return 'مدفوع جزئيًا';
      case 'unpaid':
        return 'غير مدفوع';
      default:
        return status;
    }
  }

  Widget _statusTag(ColorScheme cs, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_statusLabel(status),
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ===================== لائحة الدفعات (قابلة للطي) =====================
class _InstallmentsExpansion extends StatefulWidget {
  final List<InstallmentItem> installments;
  final List<TransactionItem> transactions;
  const _InstallmentsExpansion({
    required this.installments,
    required this.transactions,
  });

  @override
  State<_InstallmentsExpansion> createState() => _InstallmentsExpansionState();
}

class _InstallmentsExpansionState extends State<_InstallmentsExpansion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_open ? 'إخفاء الدفعات' : 'عرض الدفعات',
                    style: TextStyle(
                        color: cs.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: cs.primary,
                    size: 20),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
          _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            children: widget.installments
                .map((e) => _InstallmentRow(
              installment: e,
              transactions: widget.transactions,
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  final InstallmentItem installment;
  final List<TransactionItem> transactions;
  const _InstallmentRow({
    required this.installment,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final paid = installment.isPaid;
    final color = paid ? Colors.green : const Color(0xFFB07D00);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // رقم الدفعة
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Text('${installment.number}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(installment.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              // شارة الحالة
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(paid ? 'مدفوعة' : 'معلّقة',
                    style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _amountRow(cs, 'المستحق', installment.due, cs.onSurface),
          if (installment.paid > 0)
            _amountRow(cs, 'المدفوع', installment.paid, Colors.green),
          if (installment.remaining > 0)
            _amountRow(cs, 'المتبقّي', installment.remaining, cs.error),
          if (installment.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تاريخ الاستحقاق',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurface.withOpacity(0.55))),
                  Text(_fmtDate(installment.dueDate!),
                      style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurface.withOpacity(0.75),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // 👇 معلومات الدفع للدفعة المدفوعة
          if (paid) ..._paymentInfo(cs),
        ],
      ),
    );
  }

  // نعرض المعاملات المرتبطة (بما إنو الـ API ما بيربط المعاملة بدفعة محدّدة،
  // منعرض المعاملات العامة تحت أول دفعة مدفوعة — عدّلها لو الباك بيربطهن لاحقًا)
  List<Widget> _paymentInfo(ColorScheme cs) {
    if (transactions.isEmpty) return const [];
    return [
      const SizedBox(height: 8),
      Divider(color: cs.onSurface.withOpacity(0.08), height: 1),
      const SizedBox(height: 8),
      ...transactions.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoRow(cs, 'طريقة الدفع', _methodLabel(t.paymentMethod)),
            if (t.paperReceiptNo != null)
              _infoRow(cs, 'رقم الإيصال', t.paperReceiptNo!),
            if (t.digitalReference != null)
              _infoRow(cs, 'المرجع الرقمي', t.digitalReference!),
            if (t.createdAt != null)
              _infoRow(cs, 'تاريخ الدفع', _fmtDate(t.createdAt!)),
          ],
        ),
      )),
    ];
  }

  Widget _amountRow(ColorScheme cs, String label, int value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
          Text(_fmt(value),
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _infoRow(ColorScheme cs, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, color: cs.onSurface.withOpacity(0.55))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 11.5,
                    color: cs.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'cash':
        return 'نقدًا';
      case 'card':
        return 'بطاقة';
      case 'transfer':
        return 'حوالة';
      default:
        return raw;
    }
  }
}

// ===================== helpers =====================
String _fmt(int v) {
  // فاصل آلاف بسيط
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';