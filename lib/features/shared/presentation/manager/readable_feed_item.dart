/// أي كيان بدو يدخل بنظام [FeedCubit] العام (تنبيهات، إعلانات،
/// أنشطة، علامات، تقييمات...) لازم يحقق هالعقد البسيط.
abstract class ReadableFeedItem {
  bool get isRead;
}
