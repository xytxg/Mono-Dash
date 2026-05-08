import '../../../../data/dto/website/website_group_dto.dart';
import '../../../../data/dto/website/website_dto.dart';

class WebsitesViewState {
  const WebsitesViewState({
    this.websites = const [],
    this.groups = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchText = '',
    this.isCheckingOpenResty = false,
    this.isOpenRestyInstalled,
    this.openRestyStatus,
    this.openRestyAppInstallId,
  });

  final List<WebsiteDto> websites;
  final List<WebsiteGroupDto> groups;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchText;
  final bool isCheckingOpenResty;
  final bool? isOpenRestyInstalled;
  final String? openRestyStatus;
  final int? openRestyAppInstallId;

  WebsitesViewState copyWith({
    List<WebsiteDto>? websites,
    List<WebsiteGroupDto>? groups,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchText,
    bool? isCheckingOpenResty,
    bool? isOpenRestyInstalled,
    String? openRestyStatus,
    int? openRestyAppInstallId,
  }) {
    return WebsitesViewState(
      websites: websites ?? this.websites,
      groups: groups ?? this.groups,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchText: searchText ?? this.searchText,
      isCheckingOpenResty: isCheckingOpenResty ?? this.isCheckingOpenResty,
      isOpenRestyInstalled: isOpenRestyInstalled ?? this.isOpenRestyInstalled,
      openRestyStatus: openRestyStatus ?? this.openRestyStatus,
      openRestyAppInstallId:
          openRestyAppInstallId ?? this.openRestyAppInstallId,
    );
  }
}
