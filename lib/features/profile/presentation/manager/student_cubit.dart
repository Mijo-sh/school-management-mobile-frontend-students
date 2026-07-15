import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/use_cases/get_cached_user_usecase.dart';
import '../../domain/use_cases/get_student_usecase.dart';
import '../../../profile/domain/entities/child_card.dart';

part 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  final GetAcademicInfoUsecase getAcademicInfoUsecase;
  final GetCachedUserUsecase getCachedUserUsecase;

  StudentCubit({
    required this.getAcademicInfoUsecase,
    required this.getCachedUserUsecase,
  }) : super(const StudentInitial());

  /// المسار العادي: الطالب نفسو عم يشوف بياناتو — بينادي السيرفر.
  Future<void> loadStudentData() async {
    emit(const StudentLoading());

    final userResult = await getCachedUserUsecase();
    String studentName = '';
    userResult.fold(
          (_) => studentName = '',
          (user) => studentName = user?.fullName ?? '',
    );

    final infoResult = await getAcademicInfoUsecase();
    infoResult.fold(
          (failure) => emit(StudentError(failure.message)),
          (info) => emit(StudentLoaded(
        studentName: studentName,
        academicInfo: info,
      )),
    );
  }

  /// مسار ولي الأمر: بيانات الطالب (الابن) موجودة أصلًا عند
  /// GuardianCubit (ChildCard)، فما في داعي أي طلب سيرفر جديد —
  /// بس نبني StudentLoaded مباشرة من هالبيانات المتوفرة.
  void loadFromChildCard(ChildCard child) {
    emit(StudentLoaded(
      studentName: child.fullName,

      academicInfo: AcademicInfo(
        gradeName: child.gradeName,
        classNumber: child.classNumber,
        // TODO: ChildCard ما فيها semesterName حاليًا — إذا محتاجها
        // فعليًا بالداشبورد، ضيفها لـ ChildCard entity من الـ API
        // الأساسي (getChildrenUsecase)، أو خليها فاضية متل هلق.
        semesterName: '',
      ),
    ));
  }
}