import 'package:flutter/foundation.dart';
import '../../../../data/dto/file/file_item_dto.dart';

enum FileViewMode { list, icon }

/// 文件浏览器的视图状态。
class FilesViewState {
  const FilesViewState({
    this.currentPath = '/',
    this.items = const [],
    this.pathHistory = const ['/'],
    this.isLoading = false,
    this.showHidden = true,
    this.sortBy = 'name',
    this.sortOrder = 'ascending',
    this.viewMode = FileViewMode.list,
    this.searchText = '',
    this.containSub = false,
    this.scrollOffsets = const {},
    this.isSelectionMode = false,
    this.selectedPaths = const {},
    this.page = 1,
    this.pageSize = 50,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.editingPath,
  });

  /// 当前浏览的目录路径
  final String currentPath;

  /// 当前目录下的文件/文件夹列表
  final List<FileItemDto> items;

  /// 路径浏览历史（面包屑导航用）
  final List<String> pathHistory;

  /// 是否正在加载
  final bool isLoading;

  /// 是否显示隐藏文件
  final bool showHidden;

  /// 排序字段
  final String sortBy;

  /// 排序顺序
  final String? sortOrder;

  /// 文件展示模式
  final FileViewMode viewMode;

  /// 搜索关键词
  final String searchText;

  /// 搜索时是否包含子目录
  final bool containSub;

  /// 存储各目录的滚动位置
  final Map<String, double> scrollOffsets;

  /// 是否处于多选模式
  final bool isSelectionMode;

  /// 已选择的文件路径集合
  final Set<String> selectedPaths;

  /// 当前页码
  final int page;

  /// 每页数量
  final int pageSize;

  /// 是否还有更多数据
  final bool hasMore;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 当前正在重命名的文件路径
  final String? editingPath;

  FilesViewState copyWith({
    String? currentPath,
    List<FileItemDto>? items,
    List<String>? pathHistory,
    bool? isLoading,
    bool? showHidden,
    String? sortBy,
    ValueGetter<String?>? sortOrder,
    FileViewMode? viewMode,
    String? searchText,
    bool? containSub,
    Map<String, double>? scrollOffsets,
    bool? isSelectionMode,
    Set<String>? selectedPaths,
    int? page,
    int? pageSize,
    bool? hasMore,
    bool? isLoadingMore,
    ValueGetter<String?>? editingPath,
  }) {
    return FilesViewState(
      currentPath: currentPath ?? this.currentPath,
      items: items ?? this.items,
      pathHistory: pathHistory ?? this.pathHistory,
      isLoading: isLoading ?? this.isLoading,
      showHidden: showHidden ?? this.showHidden,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder != null ? sortOrder() : this.sortOrder,
      viewMode: viewMode ?? this.viewMode,
      searchText: searchText ?? this.searchText,
      containSub: containSub ?? this.containSub,
      scrollOffsets: scrollOffsets ?? this.scrollOffsets,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      editingPath: editingPath != null ? editingPath() : this.editingPath,
    );
  }

  /// 将路径拆分为面包屑段。
  /// 例："/root/.config" => ["/", "root", ".config"]
  List<PathSegment> get pathSegments {
    final segments = <PathSegment>[const PathSegment(name: '/', fullPath: '/')];
    if (currentPath == '/') return segments;

    final parts = currentPath.split('/').where((p) => p.isNotEmpty).toList();
    for (var i = 0; i < parts.length; i++) {
      final fullPath = '/${parts.sublist(0, i + 1).join('/')}';
      segments.add(PathSegment(name: parts[i], fullPath: fullPath));
    }
    return segments;
  }
}

/// 路径面包屑中的一个段。
class PathSegment {
  const PathSegment({required this.name, required this.fullPath});

  final String name;
  final String fullPath;
}
