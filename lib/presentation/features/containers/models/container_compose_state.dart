import '../../../../data/dto/container/container_compose_dto.dart';

class ContainerComposeState {
  const ContainerComposeState({
    this.items = const [],
    this.searchQuery = '',
    this.page = 1,
    this.pageSize = 100,
    this.total = 0,
  });

  final List<ContainerComposeDto> items;
  final String searchQuery;
  final int page;
  final int pageSize;
  final int total;

  ContainerComposeState copyWith({
    List<ContainerComposeDto>? items,
    String? searchQuery,
    int? page,
    int? pageSize,
    int? total,
  }) {
    return ContainerComposeState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
    );
  }
}
