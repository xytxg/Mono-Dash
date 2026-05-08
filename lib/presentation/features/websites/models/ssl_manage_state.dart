import '../../../../data/dto/website/ssl_manage_dtos.dart';

class SslManageState {
  const SslManageState({
    this.items = const [],
    this.searchQuery = '',
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<SslManageDto> items;
  final String searchQuery;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoadingMore;

  SslManageState copyWith({
    List<SslManageDto>? items,
    String? searchQuery,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoadingMore,
  }) {
    return SslManageState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
