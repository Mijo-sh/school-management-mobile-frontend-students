enum PaymentAlertType {
  payment, // تنبيه تأخر/استحقاق دفع
  payed,   // تم تسديد دفعة
  general;

  static PaymentAlertType fromApiValue(String? value) {
    switch (value) {
      case 'payment':
        return PaymentAlertType.payment;
      case 'payed':
        return PaymentAlertType.payed;
      default:
        return PaymentAlertType.general;
    }
  }
}