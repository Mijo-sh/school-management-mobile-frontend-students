import '../../domain/entities/paginated.dart';
class PaginatedModel<T> extends Paginated<T> {
  const PaginatedModel({
    required super.items,
    required super.currentPage,
    required super.lastPage,
  });

  factory PaginatedModel.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedModel<T>(
      items: data.map((item) => fromJsonT(item)).toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }
}