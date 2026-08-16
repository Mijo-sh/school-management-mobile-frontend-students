// lib/features/school_rules/data/data_sources/remote/school_rules_remote_data_source.dart

import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/school_rule_model.dart';

abstract class SchoolRulesRemoteDataSource {
  Future<List<SchoolRuleModel>> getSchoolRules();
}

class SchoolRulesRemoteDataSourceImpl extends BaseRemoteDataSource
    implements SchoolRulesRemoteDataSource {
  final Dio dio;

  SchoolRulesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SchoolRuleModel>> getSchoolRules() async {
    return execute(() async {
      final response = await dio.get('/api/user/school/laws/all/show');

      final body = response.data;
      if (body is Map && body['status'] == false) {
        throw ServerException(
          message: body['message']?.toString() ?? 'فشل جلب قوانين المدرسة',
        );
      }

      final data = body['data'] as List;
      return data.map((json) => SchoolRuleModel.fromJson(json as Map<String, dynamic>)).toList();
    });
  }
}