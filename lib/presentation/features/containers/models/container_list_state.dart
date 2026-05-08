import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/dto/container/container_resource_stats_dto.dart';
import '../../../../data/dto/container/container_status_dto.dart';

enum ContainerSortType {
  none,
  cpu,
  memory,
}

class ContainerListState {
  const ContainerListState({
    this.containers = const [],
    this.stats = const {},
    this.statusSummary,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.filterState = 'all',
    this.searchQuery = '',
    this.isSearching = false,
    this.isLoadingMore = false,
    this.sortType = ContainerSortType.none,
  });

  final List<ContainerItemDto> containers;
  final Map<String, ContainerResourceStatsDto> stats;
  final ContainerStatusDto? statusSummary;
  final int page;
  final int pageSize;
  final int total;
  final String filterState;
  final String searchQuery;
  final bool isSearching;
  final bool isLoadingMore;
  final ContainerSortType sortType;

  List<ContainerItemDto> get sortedContainers {
    if (sortType == ContainerSortType.none) return containers;

    final List<ContainerItemDto> sorted = List.from(containers);
    sorted.sort((a, b) {
      final statsA = stats[a.containerID];
      final statsB = stats[b.containerID];

      if (sortType == ContainerSortType.cpu) {
        final cpuA = statsA?.cpuPercent ?? 0.0;
        final cpuB = statsB?.cpuPercent ?? 0.0;
        return cpuB.compareTo(cpuA); // 从高到低
      } else {
        final memA = statsA?.memoryUsage ?? 0;
        final memB = statsB?.memoryUsage ?? 0;
        return memB.compareTo(memA); // 从高到低
      }
    });
    return sorted;
  }

  ContainerListState copyWith({
    List<ContainerItemDto>? containers,
    Map<String, ContainerResourceStatsDto>? stats,
    ContainerStatusDto? statusSummary,
    int? page,
    int? pageSize,
    int? total,
    String? filterState,
    String? searchQuery,
    bool? isSearching,
    bool? isLoadingMore,
    ContainerSortType? sortType,
  }) {
    return ContainerListState(
      containers: containers ?? this.containers,
      stats: stats ?? this.stats,
      statusSummary: statusSummary ?? this.statusSummary,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      filterState: filterState ?? this.filterState,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sortType: sortType ?? this.sortType,
    );
  }
}
