import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase.dart';
import '../../../app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../../app_intro/domain/use_cases/save_app_session_use_case.dart';
import '../../domain/use_cases/save_profile_picture.dart';

import 'profile_picture_event.dart';
import 'profile_picture_state.dart';

class ProfilePictureBloc
    extends Bloc<ProfilePictureEvent, ProfilePictureState> {
  final SaveProfilePicture saveProfilePicture;
  final GetAppSessionUseCase getAppSession;
  final SaveAppSessionUseCase saveAppSession;

  ProfilePictureBloc({
    required this.saveProfilePicture,
    required this.getAppSession,
    required this.saveAppSession,
  }) : super(const ProfilePictureInitial()) {
    on<SaveProfilePictureRequested>(_onSaveRequested);
    on<SkipProfilePictureRequested>(_onSkipRequested);
  }

  Future<void> _markPictureStepDone() async {
    final sessionResult = await getAppSession();
    await sessionResult.fold(
          (failure) async {
        // فشل جلب الـ session نادر وغير حرج هون؛ ما منوقف تدفق الصورة بسببه.
      },
          (session) async {
        await saveAppSession(session.copyWith(isPicChoose: true));
      },
    );
  }

  Future<void> _onSaveRequested(
      SaveProfilePictureRequested event,
      Emitter<ProfilePictureState> emit,
      ) async {
    emit(const ProfilePictureLoading());
    final result = await saveProfilePicture(
      SaveProfilePictureParams(event.image),
    );
    await result.fold(
          (failure) async => emit(ProfilePictureError(failure.message)),
          (picture) async {
        // الصورة انحفظت محليًا بنجاح (بغض النظر عن نتيجة الرفع للسيرفر)
        // → هاد يكفي نعتبره "قرار نهائي" ونحدّث isPicChoose بجلسة التطبيق.
        await _markPictureStepDone();
        emit(ProfilePictureSaved(picture));
      },
    );
  }

  Future<void> _onSkipRequested(
      SkipProfilePictureRequested event,
      Emitter<ProfilePictureState> emit,
      ) async {
    emit(const ProfilePictureLoading());
    await _markPictureStepDone();
    emit(const ProfilePictureSkipped());
  }


}