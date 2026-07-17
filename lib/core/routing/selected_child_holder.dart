import '../../features/profile/domain/entities/child_card.dart';

/// يحتفظ بـ ChildCard الابن المختار حاليًا من ولي الأمر — بديل عن
/// تمرير الكائن عبر `extra` بـ go_router (غير موثوق بين فروع
/// StatefulShellRoute، لأنو goBranch() ما بتمرر extra إطلاقًا).
///
/// يتحدّث مرة وحدة (من guardian.dart وقت الضغط على كارد الابن)،
/// وبضل ثابت طول ما ولي الأمر شغال جوا شاشات هالابن، بغض النظر عن
/// أي تنقل بين التبويبات (Dashboard/Services).
class SelectedChildHolder {
  ChildCard? current;
}
