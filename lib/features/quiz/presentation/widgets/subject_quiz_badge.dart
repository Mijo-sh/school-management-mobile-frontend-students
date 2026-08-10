import 'package:flutter/material.dart';
import 'package:school_management_mobile_frontend_students/features/quiz/presentation/widgets/quiz_unread_store.dart';
import '../../../../core/injector/injector_container.dart';

/// بادج عدّاد كويزات مادة معيّنة.
/// بيقرأ من QuizUnreadStore المركزي عبر ListenableBuilder — فبيتحدّث
/// تلقائيًا لما يجي إشعار كويز، أو لما يتصفّر عدّاد المادة.
///
/// ملاحظة: ما بيجيب عدّاده بنفسه — الـ store بيتحمّل مرة وحدة بالـ
/// StudentShell (عبر loadAll)، والبادج بس بيقرأ منه.
class SubjectQuizBadge extends StatelessWidget {
  final int subjectId;
  const SubjectQuizBadge({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final store = di<QuizUnreadStore>();

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final count = store.countFor(subjectId);
        if (count <= 0) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1F9D55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Center(
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}