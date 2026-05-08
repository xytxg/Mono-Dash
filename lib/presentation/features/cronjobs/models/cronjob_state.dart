import '../../../../data/dto/cronjob/cronjob_dto.dart';

class CronjobState {
  const CronjobState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.typeFilter = '',
    this.statusFilter = '',
  });

  final List<CronjobDto> items;
  final int page;
  final int total;
  final int pageSize;
  final bool isLoadingMore;
  final String searchQuery;
  final String typeFilter;
  final String statusFilter;

  bool get hasMore => items.length < total;

  CronjobState copyWith({
    List<CronjobDto>? items,
    int? page,
    int? total,
    int? pageSize,
    bool? isLoadingMore,
    String? searchQuery,
    String? typeFilter,
    String? statusFilter,
  }) {
    return CronjobState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
