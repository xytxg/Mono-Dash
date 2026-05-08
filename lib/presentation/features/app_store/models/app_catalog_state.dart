import '../../../../data/dto/app/app_catalog_dto.dart';
import '../../../../data/dto/app/app_tag_dto.dart';

class AppCatalogState {
  const AppCatalogState({
    required this.apps,
    required this.tags,
    required this.selectedTagKey,
    required this.total,
    required this.hasMore,
    required this.isLoadingMore,
    this.isRefreshing = false,
    this.searchName = '',
  });

  final List<AppCatalogDto> apps;
  final List<AppTagDto> tags;
  final String selectedTagKey;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String searchName;

  List<String> get selectedTags =>
      selectedTagKey.isEmpty ? const [] : [selectedTagKey];

  AppCatalogState copyWith({
    List<AppCatalogDto>? apps,
    List<AppTagDto>? tags,
    String? selectedTagKey,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? searchName,
  }) {
    return AppCatalogState(
      apps: apps ?? this.apps,
      tags: tags ?? this.tags,
      selectedTagKey: selectedTagKey ?? this.selectedTagKey,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchName: searchName ?? this.searchName,
    );
  }
}
