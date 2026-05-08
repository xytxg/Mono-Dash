import '../../../../data/dto/container/image_dtos.dart';

class ImageRepoState {
  const ImageRepoState({
    this.items = const [],
    this.searchQuery = '',
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<ImageRepoDto> items;
  final String searchQuery;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoadingMore;

  ImageRepoState copyWith({
    List<ImageRepoDto>? items,
    String? searchQuery,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoadingMore,
  }) {
    return ImageRepoState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
