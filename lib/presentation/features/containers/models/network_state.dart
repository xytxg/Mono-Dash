import '../../../../data/dto/container/network_dtos.dart';

class NetworkState {
  const NetworkState({
    this.items = const [],
    this.searchQuery = '',
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<NetworkDto> items;
  final String searchQuery;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoadingMore;

  NetworkState copyWith({
    List<NetworkDto>? items,
    String? searchQuery,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoadingMore,
  }) {
    return NetworkState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
