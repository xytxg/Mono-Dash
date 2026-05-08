import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/container/docker_status_dto.dart';

class AppStoreState {
  const AppStoreState({
    required this.dockerStatus,
    required this.installedApps,
    required this.total,
    required this.hasMore,
    required this.isLoadingMore,
    required this.hasAvailableUpdates,
    this.searchName = '',
  });

  final DockerStatusDto dockerStatus;
  final List<AppInstalledDto> installedApps;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchName;
  final bool hasAvailableUpdates;

  bool get hasUpdates => hasAvailableUpdates || installedApps.any((app) => app.canUpdate);

  AppStoreState copyWith({
    DockerStatusDto? dockerStatus,
    List<AppInstalledDto>? installedApps,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchName,
    bool? hasAvailableUpdates,
  }) {
    return AppStoreState(
      dockerStatus: dockerStatus ?? this.dockerStatus,
      installedApps: installedApps ?? this.installedApps,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchName: searchName ?? this.searchName,
      hasAvailableUpdates: hasAvailableUpdates ?? this.hasAvailableUpdates,
    );
  }
}
