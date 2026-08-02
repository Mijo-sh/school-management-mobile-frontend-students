part of 'school_rules_cubit.dart';

abstract class SchoolRulesState {
  const SchoolRulesState();
}

class SchoolRulesInitial extends SchoolRulesState {}

class SchoolRulesLoading extends SchoolRulesState {}

class SchoolRulesLoaded extends SchoolRulesState {
  final List<SchoolRule> rules;
  const SchoolRulesLoaded(this.rules);
}

class SchoolRulesError extends SchoolRulesState {
  final String message;
  const SchoolRulesError(this.message);
}