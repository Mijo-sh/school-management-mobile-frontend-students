import '../../domain/entities/finance_report.dart';

class FinanceReportModel extends FinanceReport {
  const FinanceReportModel({
    required super.studentName,
    required super.planName,
    required super.installmentPolicyName,
    required super.installmentPolicyCount,
    required super.summary,
    required super.installments,
    required super.transactions,
  });

  factory FinanceReportModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final student = data['student'] as Map<String, dynamic>? ?? const {};
    final plan = data['plan'] as Map<String, dynamic>? ?? const {};
    final policy =
        data['installment_policy'] as Map<String, dynamic>? ?? const {};
    final summaryJson =
        data['financialSummary'] as Map<String, dynamic>? ?? const {};
    final installmentsJson = data['installments'] as List<dynamic>? ?? const [];
    final transactionsJson = data['transactions'] as List<dynamic>? ?? const [];

    return FinanceReportModel(
      studentName: student['name']?.toString() ?? '',
      planName: plan['name']?.toString() ?? '',
      installmentPolicyName: policy['name']?.toString() ?? '',
      installmentPolicyCount: (policy['count'] as num?)?.toInt() ?? 0,
      summary: FinancialSummary(
        totalAmount: (summaryJson['totalAmount'] as num?)?.toInt() ?? 0,
        paidAmount: (summaryJson['paidAmount'] as num?)?.toInt() ?? 0,
        remainingBalance: (summaryJson['remainingBalance'] as num?)?.toInt() ?? 0,
        paymentStatus: summaryJson['paymentStatus']?.toString() ?? '',
      ),
      installments: installmentsJson
          .map((e) => _installmentFromJson(e as Map<String, dynamic>))
          .toList(),
      transactions: transactionsJson
          .map((e) => _transactionFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static InstallmentItem _installmentFromJson(Map<String, dynamic> json) {
    final amount = json['amount'] as Map<String, dynamic>? ?? const {};
    return InstallmentItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      due: (amount['due'] as num?)?.toInt() ?? 0,
      paid: (amount['paid'] as num?)?.toInt() ?? 0,
      remaining: (amount['remaining'] as num?)?.toInt() ?? 0,
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
    );
  }

  static TransactionItem _transactionFromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id']?.toString() ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paperReceiptNo: json['paperReceiptNo']?.toString(),
      digitalReference: json['digitalReference']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}