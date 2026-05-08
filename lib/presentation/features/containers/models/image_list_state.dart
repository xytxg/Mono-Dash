import '../../../../data/dto/container/image_dtos.dart';

class ImageListState {
  const ImageListState({
    this.images = const [],
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.searchQuery = '',
    this.isSearching = false,
    this.isLoadingMore = false,
  });

  final List<DockerImageInfo> images;
  final int page;
  final int pageSize;
  final int total;
  final String searchQuery;
  final bool isSearching;
  final bool isLoadingMore;

  ImageListState copyWith({
    List<DockerImageInfo>? images,
    int? page,
    int? pageSize,
    int? total,
    String? searchQuery,
    bool? isSearching,
    bool? isLoadingMore,
  }) {
    return ImageListState(
      images: images ?? this.images,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
