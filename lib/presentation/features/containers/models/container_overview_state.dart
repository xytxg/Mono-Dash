import '../../../../data/dto/container/container_daemon_config_dto.dart';
import '../../../../data/dto/container/container_item_stats_dto.dart';
import '../../../../data/dto/container/container_status_dto.dart';
import '../../../../data/dto/container/docker_status_dto.dart';

class ContainerOverviewState {
  const ContainerOverviewState({
    required this.dockerStatus,
    this.status,
    this.itemStats,
    this.daemonConfig,
  });

  final DockerStatusDto dockerStatus;
  final ContainerStatusDto? status;
  final ContainerItemStatsDto? itemStats;
  final ContainerDaemonConfigDto? daemonConfig;

  bool get isDockerAvailable => dockerStatus.isAvailable;
}
