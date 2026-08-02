import 'package:dio/dio.dart';
import '../../models/school_rule_model.dart';

abstract class SchoolRulesRemoteDataSource {
  Future<List<SchoolRuleModel>> getSchoolRules();
}

class SchoolRulesRemoteDataSourceImpl implements SchoolRulesRemoteDataSource {
  final Dio dio;

  SchoolRulesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SchoolRuleModel>> getSchoolRules() async {
    final response = await dio.get('/api/user/school/laws/all/show');

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((json) => SchoolRuleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load school rules');
    }
  }
}