import 'package:equatable/equatable.dart';

class FinanceReport extends Equatable {
  final String studentName;
  final String planName;
  final String installmentPolicyName;
  final int installmentPolicyCount;
  final FinancialSummary summary;
  final List<InstallmentItem> installments;
  final List<TransactionItem> transactions;

  const FinanceReport({
    required this.studentName,
    required this.planName,
    required this.installmentPolicyName,
    required this.installmentPolicyCount,
    required this.summary,
    required this.installments,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    studentName,
    planName,
    installmentPolicyName,
    installmentPolicyCount,
    summary,
    installments,
    transactions,
  ];
}

class FinancialSummary extends Equatable {
  final int totalAmount;
  final int paidAmount;
  final int remainingBalance;
  final String paymentStatus; // partially_paid / paid / unpaid ...

  const FinancialSummary({
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingBalance,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props =>
      [totalAmount, paidAmount, remainingBalance, paymentStatus];
}

class InstallmentItem extends Equatable {
  final int id;
  final int number;
  final String title;
  final int due;
  final int paid;
  final int remaining;
  final DateTime? dueDate;
  final String status; // paid / pending ...

  const InstallmentItem({
    required this.id,
    required this.number,
    required this.title,
    required this.due,
    required this.paid,
    required this.remaining,
    required this.dueDate,
    required this.status,
  });

  bool get isPaid => status.toLowerCase() == 'paid';

  @override
  List<Object?> get props =>
      [id, number, title, due, paid, remaining, dueDate, status];
}

class TransactionItem extends Equatable {
  final String id;
  final int paidAmount;
  final String paymentMethod;
  final String? paperReceiptNo;
  final String? digitalReference;
  final DateTime? createdAt;

  const TransactionItem({
    required this.id,
    required this.paidAmount,
    required this.paymentMethod,
    required this.paperReceiptNo,
    required this.digitalReference,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, paidAmount, paymentMethod, paperReceiptNo, digitalReference, createdAt];
}