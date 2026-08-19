import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../models/finance_report_model.dart';

abstract class FinanceReportRemoteDataSource {
  Future<FinanceReportModel> getReport({required int studentId});
}

class FinanceReportRemoteDataSourceImpl extends BaseRemoteDataSource
    implements FinanceReportRemoteDataSource {
  final Dio dio;
  FinanceReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<FinanceReportModel> getReport({required int studentId}) async {
    return execute(() async {
      final response = await dio.get('/api/user/show/finance/report/$studentId');
      return FinanceReportModel.fromJson(response.data as Map<String, dynamic>);
    });
  }
}