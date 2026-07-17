class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;

  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });
}