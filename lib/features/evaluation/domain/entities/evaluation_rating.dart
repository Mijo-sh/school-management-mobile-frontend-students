/// مستويات التقييم الخمسة — نفس القيم الإنكليزية يلي بيرجعها السيرفر
/// بحقل "rating" بالضبط.
enum EvaluationRating {
  excellent,
  veryGood,
  good,
  average,
  weak,
  general; // احتياطي لأي قيمة غير متوقعة

  static EvaluationRating fromApiValue(String? value) {
    switch (value) {
      case 'excellent':
        return EvaluationRating.excellent;
      case 'very_good':
        return EvaluationRating.veryGood;
      case 'good':
        return EvaluationRating.good;
      case 'average':
        return EvaluationRating.average;
      case 'weak':
        return EvaluationRating.weak;
      default:
        return EvaluationRating.general;
    }
  }

  /// اسم ملف الأيقونة — مطابق تمامًا لاسم القيمة بالسيرفر
  /// (assets/images/excellent.png, very_good.png...).
  String get assetName {
    switch (this) {
      case EvaluationRating.excellent:
        return 'excellent';
      case EvaluationRating.veryGood:
        return 'very_good';
      case EvaluationRating.good:
        return 'good';
      case EvaluationRating.average:
        return 'average';
      case EvaluationRating.weak:
        return 'weak';
      case EvaluationRating.general:
        return 'general';
    }
  }

  /// مفتاح الترجمة — استخدمه مع "key".tr(context) لعرض النص حسب
  /// لغة التطبيق الحالية (عربي/إنكليزي)، بدل الاعتماد على النص
  /// الجاهز من السيرفر (rating_arabic) يلي دايمًا عربي بس.
  String get translationKey => 'rating_$assetName';
}