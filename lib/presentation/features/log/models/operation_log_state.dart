import '../../../../data/dto/log/operation_log_dto.dart';

class OperationLogState {
  const OperationLogState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.sourceFilter = '',
    this.statusFilter = '',
  });

  final List<OperationLogDto> items;
  final int page;
  final int total;
  final int pageSize;
  final bool isLoadingMore;
  final String searchQuery;
  final String sourceFilter;
  final String statusFilter;

  bool get hasMore => items.length < total;

  OperationLogState copyWith({
    List<OperationLogDto>? items,
    int? page,
    int? total,
    int? pageSize,
    bool? isLoadingMore,
    String? searchQuery,
    String? sourceFilter,
    String? statusFilter,
  }) {
    return OperationLogState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      sourceFilter: sourceFilter ?? this.sourceFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
