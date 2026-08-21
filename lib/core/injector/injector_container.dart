import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_management_mobile_frontend_students/features/alerts/data/data_sources/local/alert_local_data_source.dart';
import 'package:school_management_mobile_frontend_students/features/auth/data/data_sources/local_data_source/auth_local_data_source.dart';
import 'package:school_management_mobile_frontend_students/features/auth/data/data_sources/remote_data_source/auth_remote_datasource.dart';
import 'package:school_management_mobile_frontend_students/features/auth/domain/use_cases/log_out.dart';
import 'package:school_management_mobile_frontend_students/features/auth/presentation/manager/auth_bloc.dart';
import 'package:school_management_mobile_frontend_students/features/laws/presentation/manager/school_rules_cubit.dart';
import 'package:school_management_mobile_frontend_students/features/subject/presentation/manager/subjects_cubit.dart';

import '../../features/activities/data/data_sources/local/activity_local_data_source.dart';
import '../../features/activities/data/data_sources/remote/activity_remote_data_source.dart';
import '../../features/activities/data/repositories/activity_repository_impl.dart';
import '../../features/activities/domain/repositories/activity_repository.dart';
import '../../features/activities/domain/use_cases/get_activities_usecase.dart';
import '../../features/activities/domain/use_cases/get_unread_activities_count_usecase.dart';
import '../../features/activities/domain/use_cases/mark_all_activities_as_read_usecase.dart';
import '../../features/activities/presentation/manager/activities_cubit.dart';
import '../../features/ai_assistant/data/data_sources/ai_conversation_store.dart';
import '../../features/ai_assistant/data/data_sources/gemini_chat_service.dart';
import '../../features/ai_assistant/presentation/manager/ai_chat_cubit.dart';
import '../../features/alerts/data/data_sources/remote/alert_remote_data_source_example.dart';
import '../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../features/announcement/data/data_sources/local/announcement_local_data_source.dart';
import '../../features/announcement/data/data_sources/remote/announcement_remote_data_source.dart';
import '../../features/announcement/data/repositories/announcement_repository_impl.dart';
import '../../features/announcement/domain/repositories/announcement_repository.dart';
import '../../features/announcement/domain/use_cases/get_announcements_usecase.dart';
import '../../features/announcement/domain/use_cases/get_unread_announcements_count_usecase.dart';
import '../../features/announcement/domain/use_cases/mark_announcement_as_read_usecase.dart';
import '../../features/announcement/presentation/manager/announcements_cubit.dart';
import '../../features/app_intro/data/data_sources/app_session_local_data_source.dart';
import '../../features/app_intro/data/repositories/app_session_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/complete_onboarding_use_case.dart';
import '../../features/app_intro/domain/use_cases/delete_app_session_use_case.dart';
import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/auth/domain/use_cases/resend_otp_usecase.dart';
import '../../features/complaint/data/data_sources/complaint_remote_data_source.dart';
import '../../features/complaint/data/repositories/complaint_repository_impl.dart';
import '../../features/complaint/domain/repositories/complaint_repository.dart';
import '../../features/complaint/domain/use_cases/create_complaint_usecase.dart';
import '../../features/complaint/domain/use_cases/delete_complaint_usecase.dart';
import '../../features/complaint/domain/use_cases/get_complaint_options_usecase.dart';
import '../../features/complaint/domain/use_cases/get_complaints_usecase.dart';
import '../../features/complaint/presentation/manager/complaint_bloc.dart';
import '../../features/consulre/data/data_sources/remote/appointment_remote_data_source.dart';
import '../../features/consulre/data/repositories/appointment_repository_impl.dart';
import '../../features/consulre/domain/repositories/appointment_repository.dart';
import '../../features/consulre/domain/use_cases/book_appointment_use_case.dart';
import '../../features/consulre/domain/use_cases/cancel_appointment_use_case.dart';
import '../../features/consulre/domain/use_cases/get_available_slots_use_case.dart';
import '../../features/consulre/domain/use_cases/get_my_appointments_use_case.dart';
import '../../features/consulre/presentation/manager/appointment_bloc.dart';
import '../../features/evaluation/data/data_sources/local_datasource/evaluation_local_data_source.dart';
import '../../features/evaluation/data/data_sources/remote_datasource/evaluation_remote_data_source.dart';
import '../../features/evaluation/data/repositories/evaluation_repository_impl.dart';
import '../../features/evaluation/domain/repositories/evaluation_repository.dart';
import '../../features/evaluation/domain/use_cases/get_evaluations_usecase.dart';
import '../../features/evaluation/domain/use_cases/get_unread_evaluations_count_usecase.dart';
import '../../features/evaluation/domain/use_cases/mark_all_evaluations_as_read_usecase.dart';
import '../../features/evaluation/presentation/manager/evaluations_cubit.dart';
import '../../features/exam/data/data_sources/remote/exam_schedule_remote_data_source.dart';
import '../../features/exam/data/repositories/exam_schedule_repository_impl.dart';
import '../../features/exam/domain/entities/exam_schedule_entity.dart';
import '../../features/exam/domain/repositories/exam_schedule_repository.dart';
import '../../features/exam/domain/use_cases/get_exam_schedule_usecase.dart';
import '../../features/exam/domain/use_cases/get_unread_exams_count_usecase.dart';
import '../../features/exam/domain/use_cases/mark_all_exams_read_usecase.dart';
import '../../features/exam/presentation/manager/exam_schedule_cubit.dart';
import '../../features/exam/presentation/widgets/exam_unread_store.dart';
import '../../features/helper/data/data_sources/remote/materials_remote_data_source.dart';
import '../../features/helper/data/repositories/materials_repository_impl.dart';
import '../../features/helper/domain/repositories/materials_repository.dart';
import '../../features/helper/domain/use_cases/download_material_usecase.dart';
import '../../features/helper/domain/use_cases/get_materials_usecase.dart';
import '../../features/helper/domain/use_cases/get_unread_materials_count_usecase.dart';
import '../../features/helper/domain/use_cases/mark_all_materials_as_read_usecase.dart';
import '../../features/helper/presentation/manager/materials_cubit.dart';
import '../../features/helper/presentation/widgets/material_downloader.dart';
import '../../features/helper/presentation/widgets/material_file_service.dart';
import '../../features/home/presentation/manager/main_cubit.dart';
import '../../features/laws/data/data_sources/local/school_rules_local_data_source.dart';
import '../../features/laws/data/data_sources/remote/school_rules_remote_data_source.dart';
import '../../features/laws/data/repositories/school_rules_repository_impl.dart';
import '../../features/laws/domain/repositories/school_rules_repository.dart';
import '../../features/laws/domain/use_cases/get_school_rules_use_case.dart';
import '../../features/marks/data/data_sources/local/grade_local_data_source.dart';
import '../../features/marks/data/data_sources/remote/grade_remote_data_source.dart';
import '../../features/marks/data/repositories/grade_repository_impl.dart';
import '../../features/marks/domain/repositories/grade_repository.dart';
import '../../features/marks/domain/use_cases/get_grades_usecase.dart';
import '../../features/marks/domain/use_cases/get_unread_grades_count_usecase.dart';
import '../../features/marks/domain/use_cases/mark_all_grades_as_read_usecase.dart';
import '../../features/marks/presentation/manager/grades_cubit.dart';
import '../../features/payment_alerts/data/data_sources/local/payment_alert_local_data_source.dart';
import '../../features/payment_alerts/data/data_sources/remote/finance_report_remote_data_source.dart';
import '../../features/payment_alerts/data/data_sources/remote/payment_alert_remote_data_source.dart';
import '../../features/payment_alerts/data/repositories/finance_report_repository_impl.dart';
import '../../features/payment_alerts/data/repositories/payment_alert_repository_impl.dart';
import '../../features/payment_alerts/domain/repositories/finance_report_repository.dart';
import '../../features/payment_alerts/domain/repositories/payment_alert_repository.dart';
import '../../features/payment_alerts/domain/use_cases/ get_payment_alerts_usecase.dart';
import '../../features/payment_alerts/domain/use_cases/get_finance_report_usecase.dart';
import '../../features/payment_alerts/domain/use_cases/get_unread_payment_alerts_count_usecase.dart';
import '../../features/payment_alerts/domain/use_cases/mark_payment_alert_as_read_usecase.dart';
import '../../features/payment_alerts/presentation/manager/finance_report_cubit.dart';
import '../../features/payment_alerts/presentation/manager/payment_alerts_cubit.dart';
import '../../features/profile/presentation/manager/tomorrow_schedule_cubit.dart';
import '../../features/quiz/data/data_sources/local/practice_quizzes_local_data_source.dart';
import '../../features/quiz/data/data_sources/remote/practice_quizzes_remote_data_source.dart';
import '../../features/quiz/data/repositories/practice_quizzes_repository_impl.dart';
import '../../features/quiz/domain/repositories/practice_quizzes_repository.dart';
import '../../features/quiz/domain/use_cases/get_last_attempt_details_usecase.dart';
import '../../features/quiz/domain/use_cases/get_quiz_details_usecase.dart';
import '../../features/quiz/domain/use_cases/get_quizzes_by_subject_usecase.dart';
import '../../features/quiz/domain/use_cases/get_quizzes_unread_count_usecase.dart';
import '../../features/quiz/domain/use_cases/mark_as_read_quiz_usecase.dart';
import '../../features/quiz/domain/use_cases/submit_quiz_answers_usecase.dart';
import '../../features/quiz/presentation/manager/practice_quizzes_cubit.dart';
import '../../features/quiz/presentation/widgets/quiz_unread_store.dart';
import '../../features/report/data/data_sources/local/report_card_local_data_source.dart';
import '../../features/report/data/data_sources/remote/report_card_remote_data_source.dart';
import '../../features/report/data/repositories/report_card_repository_impl.dart';
import '../../features/report/domain/repositories/report_card_repository.dart';
import '../../features/report/domain/use_cases/get_report_card_unread_count_usecase.dart';
import '../../features/report/domain/use_cases/get_report_card_usecase.dart';
import '../../features/report/domain/use_cases/mark_all_report_card_as_read_usecase.dart';
import '../../features/report/presentation/manager/report_card_cubit.dart';
import '../../features/subject/data/repositories/subjects_repository_impl.dart';
import '../../features/subject/domain/repositories/get_practice_subjects_usecase.dart';
import '../../features/subject/domain/repositories/subjects_repository.dart';
import '../../features/tasks/data/data_sources/random_tasks_store.dart';
import '../../features/tasks/data/data_sources/task_reminder_service.dart';
import '../../features/top_student/data/data_sources/remote/top_students_remote_data_source.dart';
import '../../features/top_student/data/repositories/top_students_repository_impl.dart';
import '../../features/top_student/domain/repositories/top_students_repository.dart';
import '../../features/top_student/domain/use_cases/get_top_students_usecase.dart';
import '../../features/top_student/presentation/manager/top_students_cubit.dart';
import '../../features/weekly_schedule/data/data_sources/local/schedule_local_data_source .dart';
import '../../features/weekly_schedule/data/data_sources/remote/schedule_remote_data_source.dart';
import '../../features/weekly_schedule/data/repositories/schedule_repository_impl.dart';
import '../../features/weekly_schedule/domain/repositories/schedule_repository.dart';
import '../../features/weekly_schedule/domain/use_cases/get_tomorrow_schedule_usecase.dart';
import '../../features/weekly_schedule/domain/use_cases/get_weekly_schedule_usecase.dart';
import '../../features/weekly_schedule/presentation/manager/schedule_cubit (1).dart';
import '../homework/homework_completion_store.dart';
import '../../features/homework/data/data_sources/local_datasource/homework_local_data_source.dart';
import '../../features/homework/data/data_sources/remote_datasource/homework_remote_data_source.dart';
import '../../features/homework/data/repositories/homework_repository_impl.dart';
import '../../features/homework/domain/repositories/homework_repository.dart';
import '../../features/homework/domain/use_cases/get_homeworks_usecase.dart';
import '../../features/homework/domain/use_cases/get_unread_homeworks_count_usecase.dart';
import '../../features/homework/domain/use_cases/mark_all_homeworks_as_read_usecase.dart';
import '../../features/homework/presentation/manager/homeworks_cubit.dart';
import '../../features/language/data/data_sources/language_local_data_source.dart';
import '../../features/app_intro/domain/repositories/app_session_repository.dart';
import '../../features/app_intro/domain/use_cases/save_app_session_use_case.dart';
import '../../features/language/data/repositories/language_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../features/language/domain/use_cases/save_language_use_case.dart';
import '../../features/language/domain/repositories/language_repository.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/language/domain/use_cases/get_language_use_case.dart';
import '../../features/auth/data/repositories/auth_repository_imp.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/log_in_usecase.dart';
import '../../features/auth/domain/use_cases/send_otp_usecase.dart';
import '../../features/profile/data/data_sources/local_data_source/guardian_local_datasource.dart';
import '../../features/profile/data/data_sources/local_data_source/profile_local_data_source.dart';
import '../../features/profile/data/data_sources/local_data_source/student_local_datasource.dart';
import '../../features/profile/data/data_sources/remote_data_source/guardian_remote_data_source.dart';
import '../../features/profile/data/data_sources/remote_data_source/image_remote_data_source.dart';
import '../../features/profile/data/data_sources/remote_data_source/profile_photo_remote_data_source.dart';
import '../../features/profile/data/data_sources/remote_data_source/student_remote_data_source.dart';
import '../../features/profile/data/repositories/guardian_repository_imp.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/repositories/student_repository_imp.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/repositories/quardian_repository.dart';
import '../../features/profile/domain/repositories/student_repository.dart';
import '../../features/profile/domain/use_cases/get_cached_user_usecase.dart';
import '../../features/profile/domain/use_cases/get_children_usecase.dart';
import '../../features/profile/domain/use_cases/get_profile_photo_url_usecase.dart';
import '../../features/profile/domain/use_cases/get_student_usecase.dart';
import '../../features/profile/presentation/manager/guardian_cubit.dart';
import '../../features/profile/presentation/manager/profile_picture_bloc.dart';
import '../../features/profile/presentation/manager/student_cubit.dart';
import '../../features/theme/data/data_sources/theme_local_data_source.dart';
import '../../features/app_intro/presentation/bloc/splash/splash_bloc.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/app_intro/domain/services/app_entry_decider.dart';
import '../../features/theme/domain/use_cases/save_theme_use_case.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/use_cases/get_theme_use_case.dart';
import '../../features/language/presentation/bloc/language_bloc.dart';
import '../../features/theme/presentation/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../network/api_endpoints.dart';
import '../network/dio_auth_interceptor.dart';
import '../network/dio_error_interceptor.dart';
import '../network/network_info.dart';
import 'package:get_it/get_it.dart';

import '../notifications/data/data_sources/firebase_push_notification_sevice.dart';
import '../notifications/data/data_sources/local_data_source/notification_local_data_source.dart';
import '../notifications/data/data_sources/remote_data_source/remote_data_source_notification.dart';
import '../notifications/domain/repositories/push_notification_repository.dart';
import '../notifications/domain/use_cases/ensure_fcm_token_usecase.dart';
import '../notifications/domain/use_cases/put_fcmtoken_usecase.dart';
import '../notifications/presentation/manager/notification_handler.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import '../../features/alerts/domain/use_cases/get_alerts_usecase.dart';
import '../../features/alerts/domain/use_cases/get_unread_alerts_count_usecase.dart';
import '../../features/alerts/domain/use_cases/mark_alert_as_read_usecase.dart';
import '../../features/alerts/presentation/manager/alerts_cubit.dart';
import '../routing/selected_child_holder.dart';
import '../unread_counts_store.dart';

final di = GetIt.instance;
Future<void> init() async {
  // 1. تسجيل الـ SharedPreferences فوراً
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerLazySingleton(() => sharedPreferences);

  // 2. تسجيل الـ SecureStorage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  di.registerLazySingleton(() => secureStorage);

  // 3. تسجيل الـ Interceptors أولاً
  di.registerLazySingleton<DioAuthInterceptor>(
        () => DioAuthInterceptor(localDataSource: di()),
  );
  di.registerLazySingleton<DioErrorInterceptor>(
        () => DioErrorInterceptor(),
  );

  di.registerLazySingleton<Dio>(() {
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dioInstance.interceptors.add(di<DioAuthInterceptor>());
    dioInstance.interceptors.add(di<DioErrorInterceptor>());
    dioInstance.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,     // 👈 شو عم يتبعت
      responseHeader: false,
      responseBody: true,    // 👈 شو عم يرجع
      error: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
    return dioInstance;
  });


  di.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  di.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  di.registerLazySingleton<InternetConnectionChecker>(() =>
      InternetConnectionChecker.createInstance());
  // ====================   Core   ====================
  di.registerLazySingleton<NetworkInfo>(() =>
      NetworkInfoImpl(connectionChecker: di()));
  di.registerLazySingleton<SelectedChildHolder>(() => SelectedChildHolder());

  // ====================   Features   ====================

  // ********** Auth Feature **********
  di.registerLazySingleton<AuthLocalDataSource>(() =>
      AuthLocalDataSourceImpl(secureStorage: di(), sharedPreferences: di()));
  di.registerLazySingleton<AuthRemoteDataSource>(() =>
      AuthRemoteDataSourceImpl(dio: di()));

  di.registerLazySingleton<AuthRepository>(() =>
      AuthRepositoryImpl(remoteDataSource: di(),
          localDataSource: di(),
          sessionRepository: di()));

  di.registerLazySingleton<LoginUseCase>(() => LoginUseCase(di()));
  di.registerLazySingleton<SendOtpUsecase>(() => SendOtpUsecase(di()));
  di.registerLazySingleton<ResendOtpUsecase>(() => ResendOtpUsecase(di()));
  di.registerLazySingleton<LogOutUsecase>(() => LogOutUsecase(di(), selectedChildHolder: di()));

  di.registerFactory(() =>
      AuthBloc(
        loginUseCase: di(),
        sendOtpUsecase: di(),
        resendOtpUsecase: di(),
        ensureFcmToken: di(),
        putFcmToken: di(),
        logOutUsecase: di(),
      ));

  // ********** Theme   **********
  di.registerLazySingleton<ThemeLocalDataSource>(() =>
      ThemeLocalDataSourceImpl(preferences: di()));
  di.registerLazySingleton<ThemeRepository>(() =>
      ThemeRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetThemeUseCase>(() =>
      GetThemeUseCase(repository: di()));
  di.registerLazySingleton<SaveThemeUseCase>(() =>
      SaveThemeUseCase(repository: di()));
  di.registerFactory(() => ThemeBloc(getTheme: di(), saveTheme: di()));

  // ********** Language   **********
  di.registerLazySingleton<LanguageLocalDataSource>(() =>
      LanguageLocalDataSourceImpl(preferences: di()));
  di.registerLazySingleton<LanguageRepository>(() =>
      LanguageRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetLanguageUseCase>(() =>
      GetLanguageUseCase(repository: di()));
  di.registerLazySingleton<SaveLanguageUseCase>(() =>
      SaveLanguageUseCase(repository: di()));
  di.registerFactory(() => LanguageBloc(getLanguage: di(), saveLanguage: di()));
  // ********** Notification  **********
  // 1. Local & Remote Data Sources
  di.registerLazySingleton<NotificationLocalDataSource>(
        () => NotificationLocalDataSourceImpl(),
  );
  di.registerLazySingleton<NotificationRemoteDataSource>(
        () =>
        NotificationRemoteDataSourceImpl(dio: di<
            Dio>()), // سيأخذ نسخة الـ Dio المحقون بها الـ Interceptor تلقائياً
  );

  // 2. Repository
  di.registerLazySingleton<PushNotificationRepository>(() =>
      FirebasePushNotificationService(remoteDataSource: di()),
  );

  // 3. Use Cases
  di.registerLazySingleton(() => EnsureFcmTokenUseCase(di(), di()));
  di.registerLazySingleton(() => PutFcmTokenUseCase(di()));
  di.registerLazySingleton(() => NotificationHandler(di()));
  // ********** App Intro & Splash   **********
  di.registerLazySingleton<AppSessionLocalDataSource>(() =>
      AppSessionLocalDataSourceImpl(storage: di()));
  di.registerLazySingleton<AppSessionRepository>(() =>
      AppSessionRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetAppSessionUseCase>(() =>
      GetAppSessionUseCase(repository: di()));
  di.registerLazySingleton<SaveAppSessionUseCase>(() =>
      SaveAppSessionUseCase(repository: di()));
  di.registerLazySingleton<DeleteAppSessionUseCase>(() =>
      DeleteAppSessionUseCase(repository: di()));
  di.registerLazySingleton<CompleteOnboardingUseCase>(() =>
      CompleteOnboardingUseCase(repository: di()));

  di.registerLazySingleton<AppEntryDecider>(() => AppEntryDecider());

  di.registerFactory(() =>
      SplashBloc(getAppSession: di(),
          decider: di(),
          ensureFcmToken: di(),
          putFcmToken: di()));
  di.registerFactory(() => OnboardingBloc(completeOnboarding: di()));

// ********** Profile  **********

// 1. Data Sources (أولاً)
  di.registerLazySingleton<GuardianRemoteDataSource>(() =>
      GuardianRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<GuardianLocalDataSource>(() =>
      GuardianLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<StudentRemoteDataSource>(() =>
      StudentRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<StudentLocalDataSource>(() =>
      StudentLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<ProfileLocalDataSource>(() =>
      ProfileLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<ProfileRemoteDataSource>(() =>
      ProfileRemoteDataSourceImpl(dio: di()));

// 2. Repositories (تعتمد على الـ Data Sources)
  di.registerLazySingleton<ProfilePhotoRemoteDataSource>(() =>
      ProfilePhotoRemoteDataSourceImpl(dio: di()),);
  di.registerLazySingleton<GuardianRepository>(() =>
      GuardianRepositoryImpl(remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<StudentRepository>(() =>
      StudentRepositoryImpl(remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<ProfileRepository>(() =>
      ProfileRepositoryImpl(localDataSource: di(),
          remoteDataSource: di(),
          networkInfo: di(),
          photoRemoteDataSource: di()));

// 3. Use Cases (تعتمد على الـ Repositories)
  di.registerLazySingleton<GetCachedUserUsecase>(() =>
      GetCachedUserUsecase(di()));
  di.registerLazySingleton<GetChildrenUsecase>(() => GetChildrenUsecase(di()));
  di.registerLazySingleton<GetAcademicInfoUsecase>(() =>
      GetAcademicInfoUsecase(di()));
  di.registerLazySingleton<GetProfilePhotoUrlUseCase>(() =>
      GetProfilePhotoUrlUseCase(repository: di()),);

// 4. Cubits & Blocs (آخر شيء لأنها تعتمد على الـ Use Cases)
  di.registerFactory(() => GuardianCubit(getChildrenUsecase: di()));
  di.registerFactory(() =>
      StudentCubit(getAcademicInfoUsecase: di(), getCachedUserUsecase: di()));
  di.registerFactory(() => MainCubit(getCachedUserUsecase: di()));
  di.registerFactory(() =>
      ProfilePictureBloc(
        getAppSession: di(),
        saveAppSession: di(),
      ));

// 5. Helpers

  di.registerLazySingleton<UnreadCountsStore>(() =>
      UnreadCountsStore(
        getAlertsCount: di(),
        getAnnouncementsCount: di(),
        getActivitiesCount: di(),
        pushNotificationRepository: di(),
        getEvaluationsCount: di(),
        getGradesCount: di(),
        getHomeworksCount: di(),
        getMaterialsCount: di(),
        getPaymentAlertsCount: di(),
        getReportCardCount: di(),
      ));

  // ********** Alerts **********
  di.registerLazySingleton<AlertRemoteDataSource>(() =>
      AlertRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<AlertLocalDataSource>(() =>
      AlertLocalDataSourceImpl(sharedPreferences: di()));

  di.registerLazySingleton<AlertRepository>(() =>
      AlertRepositoryImpl(remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<GetAlertsUseCase>(() =>
      GetAlertsUseCase(repository: di()));
  di.registerLazySingleton<GetUnreadAlertsCountUseCase>(() =>
      GetUnreadAlertsCountUseCase(repository: di()));
  di.registerLazySingleton<MarkAlertAsReadUseCase>(() =>
      MarkAlertAsReadUseCase(repository: di()));

  // AlertsCubit بيحتاج studentId وقت الإنشاء (null = الطالب نفسو،
  // موجود = ولي أمر عم يشوف ابن معيّن) — لهيك registerFactoryParam
  // بدل registerFactory العادية.
  di.registerFactoryParam<AlertsCubit, int?, void>(
        (studentId, _) =>
        AlertsCubit(
          getAlertsUseCase: di(),
          markAlertAsReadUseCase: di(),
          studentId: studentId,
        ),
  );

  // ********** Announcements **********
  di.registerLazySingleton<AnnouncementRemoteDataSource>(() =>
      AnnouncementRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<AnnouncementLocalDataSource>(() =>
      AnnouncementLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<AnnouncementRepository>(() =>
      AnnouncementRepositoryImpl(
          remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<GetAnnouncementsUseCase>(() =>
      GetAnnouncementsUseCase(repository: di()));
  di.registerLazySingleton<GetUnreadAnnouncementsCountUseCase>(() =>
      GetUnreadAnnouncementsCountUseCase(repository: di()));
  di.registerLazySingleton<MarkAnnouncementAsReadUseCase>(() =>
      MarkAnnouncementAsReadUseCase(repository: di()));

  di.registerFactoryParam<AnnouncementsCubit, int?, void>((studentId, _) =>
      AnnouncementsCubit(
        getAnnouncementsUseCase: di(),
        studentId: studentId, markAnnouncementsAsReadUseCase: di(),
      ),
  );

  // ********** Activities **********
  di.registerLazySingleton<ActivityLocalDataSource>(() =>
      ActivityLocalDataSourceImpl(sharedPreferences: di()),);
  di.registerLazySingleton<ActivityRemoteDataSource>(() =>
      ActivityRemoteDataSourceImpl(dio: di()),);
  di.registerLazySingleton<ActivityRepository>(() =>
      ActivityRepositoryImpl(remoteDataSource: di(), localDataSource: di(),),);
  di.registerLazySingleton<GetActivitiesUseCase>(() =>
      GetActivitiesUseCase(repository: di()));
  di.registerLazySingleton<GetUnreadActivitiesCountUseCase>(() =>
      GetUnreadActivitiesCountUseCase(repository: di()));
  di.registerLazySingleton<MarkAllActivitiesAsReadUseCase>(() =>
      MarkAllActivitiesAsReadUseCase(repository: di()));

  di.registerFactoryParam<ActivitiesCubit, int?, void>((studentId, _) =>
      ActivitiesCubit(getActivitiesUseCase: di(),
        studentId: studentId,
        markActivitiesAsReadUseCase: di(),),);
// ********** Evaluation *******************
  di.registerLazySingleton<EvaluationLocalDataSource>(() =>
      EvaluationLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<EvaluationRemoteDataSource>(() =>
      EvaluationRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<EvaluationRepository>(() =>
      EvaluationRepositoryImpl(remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<GetEvaluationsUseCase>(() =>
      GetEvaluationsUseCase(repository: di()));
  di.registerLazySingleton<GetUnreadEvaluationsCountUseCase>(() =>
      GetUnreadEvaluationsCountUseCase(repository: di()));
  di.registerLazySingleton<MarkAllEvaluationsAsReadUseCase>(() =>
      MarkAllEvaluationsAsReadUseCase(repository: di()));

  di.registerFactoryParam<EvaluationsCubit, int?, void>(
        (studentId, _) =>
        EvaluationsCubit(
          getEvaluationsUseCase: di(),
          markEvaluationsAsReadUseCase: di(),
          studentId: studentId,
        ),
  );

//************** Homework *******************
  di.registerLazySingleton<HomeworkLocalDataSource>(() =>
      HomeworkLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<HomeworkRemoteDataSource>(() =>
      HomeworkRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<HomeworkRepository>(() =>
      HomeworkRepositoryImpl(remoteDataSource: di(), localDataSource: di()));
  di.registerLazySingleton<GetHomeworksUseCase>(() =>
      GetHomeworksUseCase(repository: di()));
  di.registerLazySingleton<GetUnreadHomeworksCountUseCase>(() =>
      GetUnreadHomeworksCountUseCase(repository: di()));
  di.registerLazySingleton<MarkAllHomeworksAsReadUseCase>(() =>
      MarkAllHomeworksAsReadUseCase(repository: di()));
  di.registerLazySingleton<HomeworkCompletionStore>(() =>
      HomeworkCompletionStore(sharedPreferences: di()));

  di.registerFactoryParam<HomeworksCubit, int?, void>(
        (studentId, _) =>
        HomeworksCubit(
          getHomeworksUseCase: di(),
          markHomeworksAsReadUseCase: di(),
          studentId: studentId,
        ),
  );
//***************** AIChat*****************
  di.registerLazySingleton<AiConversationStore>(() =>
      AiConversationStore(sharedPreferences: di()));
  di.registerLazySingleton<GeminiChatService>(() => GeminiChatService());
  di.registerFactory<AiChatCubit>(() =>
      AiChatCubit(store: di(), geminiService: di()));


//***************** Tasks***************************
  di.registerLazySingleton<TaskReminderService>(() => TaskReminderService());
  di.registerLazySingleton<RandomTasksStore>(() =>
      RandomTasksStore(sharedPreferences: di(), reminderService: di()));
//***************** Rules ***************************
  di.registerLazySingleton<SchoolRulesRemoteDataSource>(() =>
      SchoolRulesRemoteDataSourceImpl(dio: di()),);
  di.registerLazySingleton<SchoolRulesLocalDataSource>(() =>
      SchoolRulesLocalDataSourceImpl(sharedPreferences: di()),);
  di.registerLazySingleton<SchoolRulesRepository>(() =>
      SchoolRulesRepositoryImpl(
        remoteDataSource: di(), localDataSource: di(),),);

  di.registerLazySingleton<GetSchoolRulesUseCase>(
        () => GetSchoolRulesUseCase(di()),
  );

// 4. Cubit (يُفضل تسجيله كـ Factory وليس Singleton ليتم إنشاء نسخة جديدة وتدميرها عند خروج المستخدم من الصفحة)
  di.registerFactory<SchoolRulesCubit>(
        () => SchoolRulesCubit(getSchoolRulesUseCase: di()),
  );
  // ==================== Grades Feature ====================

// 1. Data Sources
  di.registerLazySingleton<GradeRemoteDataSource>(
        () => GradeRemoteDataSourceImpl(dio: di()),
  );

  di.registerLazySingleton<GradeLocalDataSource>(
        () => GradeLocalDataSourceImpl(sharedPreferences: di()),
  );

// 2. Repository
  di.registerLazySingleton<GradeRepository>(
        () =>
        GradeRepositoryImpl(
          remoteDataSource: di(),
          localDataSource: di(),
        ),
  );

// 3. Use Cases
  di.registerLazySingleton<GetGradesUseCase>(
        () => GetGradesUseCase(repository: di()),
  );

  di.registerLazySingleton<GetUnreadGradesCountUseCase>(
        () => GetUnreadGradesCountUseCase(repository: di()),
  );

  di.registerLazySingleton<MarkAllGradesAsReadUseCase>(
        () => MarkAllGradesAsReadUseCase(repository: di()),
  );

// 4. Cubit (باستخدام registerFactory ودعم الـ param1 للـ studentId)
  di.registerFactoryParam<GradesCubit, int?, void>(
        (studentId, _) =>
        GradesCubit(
          getGradesUseCase: di(),
          markGradesAsReadUseCase: di(),
          studentId: studentId,
        ),
  );

  // ==================== Practice Quizzes Feature ====================

  // 1. Data Sources
  di.registerLazySingleton<PracticeQuizzesRemoteDataSource>(
        () => PracticeQuizzesRemoteDataSourceImpl(dio: di()),
  );

  di.registerLazySingleton<PracticeQuizzesLocalDataSource>(
        () => PracticeQuizzesLocalDataSourceImpl(sharedPreferences: di()),
  );

  // 2. Repositories
  di.registerLazySingleton<SubjectsRepository>(
        () =>
        SubjectsRepositoryImpl(
          remoteDataSource: di(),
          localDataSource: di(),
        ),
  );

  di.registerLazySingleton<PracticeQuizzesRepository>(
        () =>
        PracticeQuizzesRepositoryImpl(
          remoteDataSource: di(),
          localDataSource: di(),
        ),
  );

  // 3. Use Cases
  di.registerLazySingleton(() => GetPracticeSubjectsUseCase(di()));
  di.registerLazySingleton(() => GetQuizzesBySubjectUseCase(di()));
  di.registerLazySingleton(() => GetQuizDetailsUseCase(di()));
  di.registerLazySingleton(() => SubmitQuizAnswersUseCase(di()));
  di.registerLazySingleton(() => GetLastAttemptDetailsUseCase(di()));
  di.registerLazySingleton(() => GetQuizzesUnreadCountUseCase(di()));
  di.registerLazySingleton(() => MarkQuizzesAsReadUseCase(di()));
  // 4. Cubit
  di.registerFactory(
        () =>
        PracticeQuizzesCubit(
          getQuizzesBySubjectUseCase: di(),
          getQuizDetailsUseCase: di(),
          submitQuizAnswersUseCase: di(),
          getLastAttemptDetailsUseCase: di(),
        ),
  );
  di.registerFactory(
          () =>
          SubjectsCubit(
            getPracticeSubjectsUseCase: di(),
          ));
  di.registerLazySingleton<QuizUnreadStore>(() =>
      QuizUnreadStore(
        getUnreadCounts: di(), // الاسم الجديد
        markAsReadUseCase: di(),
        pushNotificationRepository: di(),
      ));
  // **************** helper*****************
  // data source + repository
  di.registerLazySingleton<MaterialsRemoteDataSource>(() =>
      MaterialsRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<MaterialsRepository>(() =>
      MaterialsRepositoryImpl(remoteDataSource: di()));
// use cases
  di.registerLazySingleton(() => GetMaterialsUseCase(di()));
  di.registerLazySingleton(() => GetUnreadMaterialsCountUseCase(di()));
  di.registerLazySingleton(() => MarkAllMaterialsAsReadUseCase(di()));
  di.registerLazySingleton(() => DownloadMaterialUseCase(di()));
// cubit
  di.registerFactory(() =>
      MaterialsCubit(
          getMaterialsUseCase: di(), markMaterialsAsReadUseCase: di()));
  di.registerLazySingleton(() => MaterialFileService(dio: di(), sessionLocalDataSource: di()));
  di.registerLazySingleton(() => MaterialDownloader(sessionLocalDataSource: di(), dio: di()));
  // ***************** schedule ********************
  // ── Schedule (برنامج الأسبوع) ──
  di.registerLazySingleton<ScheduleRemoteDataSource>(
          () => ScheduleRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<ScheduleLocalDataSource>(
          () => ScheduleLocalDataSourceImpl(sharedPreferences: di()));
  di.registerLazySingleton<ScheduleRepository>(() => ScheduleRepositoryImpl(
    remoteDataSource: di(),
    localDataSource: di(),
  ));
  di.registerLazySingleton(() => GetWeeklyScheduleUseCase(di()));
  di.registerLazySingleton(() => GetTomorrowScheduleUseCase(di()));
  di.registerFactory(() => ScheduleCubit(getWeeklyScheduleUseCase: di(), localDataSource: di()));
  di.registerFactory(() => TomorrowScheduleCubit(getTomorrowScheduleUseCase: di()));

  //************** Exam schedule *************
  // ═══════ Exam Schedule Feature ═══════

// 1) Data source (نفس أسلوب تسجيل data sources عندك)
  di.registerLazySingleton<ExamScheduleRemoteDataSource>(
        () => ExamScheduleRemoteDataSourceImpl(dio: di()),
  );

// 2) Repository
  di.registerLazySingleton<ExamScheduleRepository>(
        () => ExamScheduleRepositoryImpl(remoteDataSource: di()),
  );

// 3) Use cases (الثلاثة)
  di.registerLazySingleton(() => GetExamScheduleUseCase(di()));
  di.registerLazySingleton(() => GetUnreadExamsCountUseCase(di()));
  di.registerLazySingleton(() => MarkAllExamsReadUseCase(di()));

// 4) Store (Singleton — لازم يضل حيّ طول عمر التطبيق مثل QuizUnreadStore)
  di.registerLazySingleton<ExamUnreadStore>(
        () => ExamUnreadStore(
      getUnreadCounts: di(),
      markAllReadUseCase: di(),
      pushNotificationRepository: di(),
    ),
  );

// 5) Cubit (factoryParam: studentId + type)
  di.registerFactoryParam<ExamScheduleCubit, int?, ExamType>(
        (studentId, type) => ExamScheduleCubit(
      getExamSchedule: di(),
      studentId: studentId,
      type: type,
    ),
  );
  //********** complaint ****************
  di.registerLazySingleton<ComplaintRemoteDataSource>(
          () => ComplaintRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<ComplaintRepository>(
          () => ComplaintRepositoryImpl(remoteDataSource: di()));
  di.registerLazySingleton(() => GetComplaintOptionsUseCase(di()));
  di.registerLazySingleton(() => GetComplaintsUseCase(di()));
  di.registerLazySingleton(() => CreateComplaintUseCase(di()));
  di.registerLazySingleton(() => DeleteComplaintUseCase(di()));

  di.registerFactory(() => ComplaintBloc(
      getComplaints: di(), getOptions: di(), createComplaint: di(), deleteComplaint: di()));
// ===================== Report Card (الجلاء) =====================

// cubit — زيد البارامتر الجديد
  di.registerFactoryParam<ReportCardCubit, int?, int?>(
        (studentId, reportCardId) => ReportCardCubit(
      getReportCardUseCase: di(),
      markReportCardAsReadUseCase: di(), // 👈 جديد
      studentId: studentId,
      reportCardId: reportCardId,
    ),
  );


// UseCase
  di.registerLazySingleton(() => GetReportCardUnreadCountUseCase(repository: di()));
  di.registerLazySingleton(() => MarkAllReportCardAsReadUseCase(repository: di()));

  di.registerLazySingleton(
        () => GetReportCardUseCase(repository: di()),
  );

// Repository
  di.registerLazySingleton<ReportCardRepository>(
        () => ReportCardRepositoryImpl(
      remoteDataSource: di(),
      localDataSource: di(),
    ),
  );

// Remote DataSource
  di.registerLazySingleton<ReportCardRemoteDataSource>(
        () => ReportCardRemoteDataSourceImpl(dio: di()),
  );

// Local DataSource
  di.registerLazySingleton<ReportCardLocalDataSource>(
        () => ReportCardLocalDataSourceImpl(sharedPreferences: di()),
  );
  // ===== Payment Alerts =====

  // Data sources
  di.registerLazySingleton<PaymentAlertRemoteDataSource>(
        () => PaymentAlertRemoteDataSourceImpl(dio: di()),
  );
  di.registerLazySingleton<PaymentAlertLocalDataSource>(
        () => PaymentAlertLocalDataSourceImpl(sharedPreferences: di()),
  );

  // Repository
  di.registerLazySingleton<PaymentAlertRepository>(
        () => PaymentAlertRepositoryImpl(
      remoteDataSource: di(),
      localDataSource: di(),
    ),
  );

  // Use cases
  di.registerLazySingleton(() => GetPaymentAlertsUseCase(repository: di()));
  di.registerLazySingleton(
        () => GetUnreadPaymentAlertsCountUseCase(repository: di()),
  );
  di.registerLazySingleton(
        () => MarkPaymentAlertAsReadUseCase(repository: di()),
  );

  // Cubit — factoryParam مشان param1: studentId (متل AlertsCubit)
  di.registerFactoryParam<PaymentAlertsCubit, int?, void>(
        (studentId, _) => PaymentAlertsCubit(
      getPaymentAlertsUseCase: di(),
      markPaymentAlertAsReadUseCase: di(),
      studentId: studentId,
    ),
  );
  // Finance report
  di.registerLazySingleton<FinanceReportRemoteDataSource>(
          () => FinanceReportRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<FinanceReportRepository>(
          () => FinanceReportRepositoryImpl(remoteDataSource: di()));
  di.registerLazySingleton(() => GetFinanceReportUseCase(repository: di()));
  di.registerFactoryParam<FinanceReportCubit, int?, void>(
          (studentId, _) => FinanceReportCubit(
        getFinanceReportUseCase: di(),
        studentId: studentId!, // للأب دايمًا موجود
      ));
//*********** consulre *******************
// Bloc
  di.registerFactory(() => AppointmentBloc(
    getAvailableSlots: di(),
    getMyAppointments: di(),
    bookAppointment: di(),
    cancelAppointment: di(),
  ));

// Use cases
  di.registerLazySingleton(() => GetAvailableSlotsUseCase(repository: di()));
  di.registerLazySingleton(() => GetMyAppointmentsUseCase(repository: di()));
  di.registerLazySingleton(() => BookAppointmentUseCase(repository: di()));
  di.registerLazySingleton(() => CancelAppointmentUseCase(repository: di()));

// Repository
  di.registerLazySingleton<AppointmentRepository>(
        () => AppointmentRepositoryImpl(remoteDataSource: di()),
  );

// Data source
  di.registerLazySingleton<AppointmentRemoteDataSource>(
        () => AppointmentRemoteDataSourceImpl(dio: di()),
  );
  // ===================== Top Students Feature =====================

// 1) Remote Data Source
  di.registerLazySingleton<TopStudentsRemoteDataSource>(
        () => TopStudentsRemoteDataSourceImpl(dio: di()),
  );

// 2) Repository
  di.registerLazySingleton<TopStudentsRepository>(
        () => TopStudentsRepositoryImpl(remoteDataSource: di()),
  );

// 3) Use Case
  di.registerLazySingleton(
        () => GetTopStudentsUseCase(repository: di()),
  );

// 4) Cubit — factory param لأنه بياخد studentId وقت الإنشاء
  di.registerFactoryParam<TopStudentsCubit, int?, void>(
        (studentId, _) => TopStudentsCubit(
      getTopStudentsUseCase: di(),
      studentId: studentId,
    ),
  );
}