import '../../../../data/dto/runtime/runtime_dto.dart';

/// 单个运行环境类型（如 php / java / node 等）的分页状态。
class RuntimeTypeState {
  const RuntimeTypeState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isInitialized = false,
  });

  final List<RuntimeDto> items;
  final int page;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isInitialized;

  bool get hasMore => items.length < total;

  RuntimeTypeState copyWith({
    List<RuntimeDto>? items,
    int? page,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isInitialized,
  }) {
    return RuntimeTypeState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// 运行环境总状态，按类型分别维护分页，合并为统一列表展示。
class RuntimeState {
  const RuntimeState({
    this.typeStates = const {},
    this.pageSize = 20,
    this.searchQuery = '',
  });

  /// 每个类型的独立分页状态。
  final Map<String, RuntimeTypeState> typeStates;
  final int pageSize;
  final String searchQuery;

  /// 获取“全部”类型的数据。
  List<RuntimeDto> get items => typeStates['']?.items ?? const [];

  /// “全部”类型是否正在加载更多。
  bool get isLoadingMore => typeStates['']?.isLoadingMore ?? false;

  /// “全部”类型是否已全部加载完毕。
  bool get allLoaded => !(typeStates['']?.hasMore ?? true);

  /// “全部”类型的总数。
  int get totalItems => typeStates['']?.total ?? 0;

  /// “全部”类型当前已加载的总数。
  int get loadedItems => typeStates['']?.items.length ?? 0;

  RuntimeState copyWith({
    Map<String, RuntimeTypeState>? typeStates,
    int? pageSize,
    String? searchQuery,
  }) {
    return RuntimeState(
      typeStates: typeStates ?? this.typeStates,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// 更新指定类型的状态。
  RuntimeState updateType(
    String type,
    RuntimeTypeState Function(RuntimeTypeState) updater,
  ) {
    final current = typeStates[type] ?? const RuntimeTypeState();
    return copyWith(typeStates: {...typeStates, type: updater(current)});
  }
}
