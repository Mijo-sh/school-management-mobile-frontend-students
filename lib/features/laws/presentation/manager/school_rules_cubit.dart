import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/school_rule.dart';
import '../../domain/use_cases/get_school_rules_use_case.dart';

part 'school_rules_state.dart';

class SchoolRulesCubit extends Cubit<SchoolRulesState> {
  final GetSchoolRulesUseCase getSchoolRulesUseCase;

  SchoolRulesCubit({required this.getSchoolRulesUseCase}) : super(SchoolRulesInitial());

  Future<void> fetchSchoolRules() async {
    emit(SchoolRulesLoading());
    final result = await getSchoolRulesUseCase();

    result.fold(
          (failure) => emit(const SchoolRulesError('فشل في تحميل القوانين المدرسية')),
          (rules) => emit(SchoolRulesLoaded(rules)),
    );
  }
}