import '../../../../data/dto/log/ssh_log_dto.dart';

class SshLogState {
  const SshLogState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
    this.isLoadingMore = false,
    this.infoSearch = '',
    this.statusFilter = 'All',
  });

  final List<SshLogDto> items;
  final int page;
  final int total;
  final int pageSize;
  final bool isLoadingMore;
  final String infoSearch;
  final String statusFilter;

  bool get hasMore => items.length < total;

  SshLogState copyWith({
    List<SshLogDto>? items,
    int? page,
    int? total,
    int? pageSize,
    bool? isLoadingMore,
    String? infoSearch,
    String? statusFilter,
  }) {
    return SshLogState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      infoSearch: infoSearch ?? this.infoSearch,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
