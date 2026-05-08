import '../../../../data/dto/container/compose_template_dto.dart';

class ComposeTemplateState {
  const ComposeTemplateState({
    this.items = const [],
    this.searchQuery = '',
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<ComposeTemplateDto> items;
  final String searchQuery;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoadingMore;

  ComposeTemplateState copyWith({
    List<ComposeTemplateDto>? items,
    String? searchQuery,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoadingMore,
  }) {
    return ComposeTemplateState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
