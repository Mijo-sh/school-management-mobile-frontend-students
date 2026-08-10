import 'package:dio/dio.dart';

import '../../../../../core/network/base_remote_data_source.dart';
import '../../../../shared/data/models/paginated_model.dart';
import '../../models/study_material_model.dart';

abstract class MaterialsRemoteDataSource {
  Future<PaginatedModel<StudyMaterialModel>> getMaterials({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();

  /// يحمّل الملف كـ bytes (للنوع file). الحفظ بالجهاز يصير بطبقة أعلى.
  Future<List<int>> downloadMaterial(int materialId);
}

class MaterialsRemoteDataSourceImpl extends BaseRemoteDataSource
    implements MaterialsRemoteDataSource {
  final Dio dio;

  MaterialsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedModel<StudyMaterialModel>> getMaterials({int page = 1}) {
    return execute(() async {
      final response = await dio.get(
        '/api/user/helper/materials/show/all-by',
        queryParameters: {'page': page},
      );
      // data = { items: [...], pagination: {...} }
      final data = response.data['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => StudyMaterialModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;

      return PaginatedModel<StudyMaterialModel>(
        items: items,
        currentPage: (pagination['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
      );
    });
  }

  @override
  Future<int> getUnreadCount() {
    return execute(() async {
      final response =
          await dio.get('/api/user/helper/materials/count/unread');
      return (response.data['data']?['unread_count'] as num?)?.toInt() ?? 0;
    });
  }

  @override
  Future<void> markAllAsRead() {
    return execute(() async {
      await dio.post('/api/user/helper/materials/mark/all/read');
    });
  }

  @override
  Future<List<int>> downloadMaterial(int materialId) {
    return execute(() async {
      final response = await dio.get<List<int>>(
        '/api/user/helper/materials/download/$materialId',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? <int>[];
    });
  }
}
