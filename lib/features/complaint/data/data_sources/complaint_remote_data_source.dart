// lib/features/complaint/data/data_sources/remote/complaint_remote_data_source.dart

import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../domain/entities/complaint_entities.dart';
import '../models/complaint_models.dart';

abstract class ComplaintRemoteDataSource {
  Future<List<ComplaintCategoryModel>> getOptions();
  Future<List<ComplaintModel>> getComplaints(int studentId);
  Future<void> createComplaint(ComplaintToCreate complaint);
  Future<void> deleteComplaint(int complaintId); // 👈 جديد

}

class ComplaintRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ComplaintRemoteDataSource {
  final Dio dio;

  ComplaintRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ComplaintCategoryModel>> getOptions() async {
    return execute(() async {
      final response = await dio.get('/api/user/complaint/options');
      final data = response.data['data'] as List;
      return data
          .map((json) =>
          ComplaintCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<ComplaintModel>> getComplaints(int studentId) async {
    return execute(() async {
      final response = await dio.get('/api/user/complaint/show/$studentId');
      final data = response.data['data'] as List;
      return data
          .map((json) => ComplaintModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> createComplaint(ComplaintToCreate complaint) async {
    return execute(() async {
      await dio.post(
        '/api/user/complaint/create',
        data: {
          'student_id': complaint.studentId,
          'complaint_type_id': complaint.complaintTypeId,
        },
      );
    });
  }
  @override
  Future<void> deleteComplaint(int complaintId) async {
    return execute(() async {
      await dio.delete('/api/user/complaint/delete/$complaintId');
    });
  }
}