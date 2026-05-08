import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/dto/container/container_item_stats_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../../domain/repositories/container_repository.dart';
import '../models/container_overview_state.dart';

final containerOverviewProvider =
    AsyncNotifierProvider<ContainerOverviewController, ContainerOverviewState>(
      ContainerOverviewController.new,
      dependencies: [containerRepositoryProvider],
    );

class ContainerOverviewController
    extends AsyncNotifier<ContainerOverviewState> {
  @override
  Future<ContainerOverviewState> build() => _load();

  Future<ContainerOverviewState> _load() async {
    final repo = await ref.read(containerRepositoryProvider.future);
    final dockerStatus = await repo.getDockerStatus();

    if (!dockerStatus.isAvailable) {
      return ContainerOverviewState(dockerStatus: dockerStatus);
    }

    final statusFuture = repo.getStatus();
    final itemStatsFuture = _loadOptionalItemStats(repo);
    final daemonConfigFuture = repo.getDaemonConfig();

    return ContainerOverviewState(
      dockerStatus: dockerStatus,
      status: await statusFuture,
      itemStats: await itemStatsFuture,
      daemonConfig: await daemonConfigFuture,
    );
  }

  Future<ContainerItemStatsDto?> _loadOptionalItemStats(
    ContainerRepository repo,
  ) async {
    try {
      return await repo.getItemStats();
    } catch (_) {
      // Compatibility: 1Panel v2.0.0 may not provide this endpoint.
      // Treat it as an optional capability and hide the disk usage section.
      return null;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }
}
