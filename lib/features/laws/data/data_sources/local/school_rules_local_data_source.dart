import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/school_rule_model.dart';

abstract class SchoolRulesLocalDataSource {
  Future<List<SchoolRuleModel>> getLastSchoolRules();
  Future<void> cacheSchoolRules(List<SchoolRuleModel> rulesToCache);
}

class SchoolRulesLocalDataSourceImpl implements SchoolRulesLocalDataSource {
  static const String cachedSchoolRulesKey = 'CACHED_SCHOOL_RULES';
  final SharedPreferences sharedPreferences;

  SchoolRulesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheSchoolRules(List<SchoolRuleModel> rulesToCache) async {
    final List<Map<String, dynamic>> jsonList =
    rulesToCache.map((rule) => rule.toJson()).toList();
    await sharedPreferences.setString(cachedSchoolRulesKey, jsonEncode(jsonList));
  }

  @override
  Future<List<SchoolRuleModel>> getLastSchoolRules() async {
    final jsonString = sharedPreferences.getString(cachedSchoolRulesKey);
    if (jsonString != null) {
      final List decodedList = jsonDecode(jsonString);
      return decodedList
          .map((json) => SchoolRuleModel.fromJson(json))
          .toList();
    } else {
      throw Exception('No Cached Data Found'); // أو يمكنك إرجاع قائمة فارغة
    }
  }
}