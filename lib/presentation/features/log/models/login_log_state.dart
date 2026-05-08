import '../../../../data/dto/log/login_log_dto.dart';

class LoginLogState {
  const LoginLogState({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
    this.isLoadingMore = false,
    this.ipSearch = '',
    this.statusFilter = '',
  });

  final List<LoginLogDto> items;
  final int page;
  final int total;
  final int pageSize;
  final bool isLoadingMore;
  final String ipSearch;
  final String statusFilter;

  bool get hasMore => items.length < total;

  LoginLogState copyWith({
    List<LoginLogDto>? items,
    int? page,
    int? total,
    int? pageSize,
    bool? isLoadingMore,
    String? ipSearch,
    String? statusFilter,
  }) {
    return LoginLogState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      ipSearch: ipSearch ?? this.ipSearch,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
