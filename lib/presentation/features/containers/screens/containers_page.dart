import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../../data/dto/container/docker_status_dto.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/container_overview_state.dart';
import '../providers/container_overview_provider.dart';
import '../widgets/container_overview_widgets.dart';

class ContainersPage extends ConsumerWidget {
  const ContainersPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) return const _InactiveContainersPage();

    final asyncState = ref.watch(containerOverviewProvider);
    final serverId = ref.watch(activeServerIdProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              ref.read(containerOverviewProvider.notifier).refresh(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        asyncState.when(
          data: (state) {
            if (!state.isDockerAvailable) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: DockerUnavailableCard(state: state),
              );
            }
            return _buildContent(state, serverId);
          },
          loading: () => _buildLoading(serverId),
          error: (err, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: context.l10n.containers_loadOverviewFailed,
              error: err,
              onRetry: () =>
                  ref.read(containerOverviewProvider.notifier).refresh(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ContainerOverviewState state, int serverId) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
      sliver: SliverList.list(
        children: [
          DockerSummaryCard(state: state),
          const SizedBox(height: 10),
          ResourceOverviewCard(state: state, serverId: serverId),
          const SizedBox(height: 10),
          StorageUsageCard(state: state),
          const SizedBox(height: 10),
          DaemonConfigCard(state: state),
        ],
      ),
    );
  }

  Widget _buildLoading(int serverId) {
    const dummyState = ContainerOverviewState(
      dockerStatus: DockerStatusDto(isExist: true, isActive: false),
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
      sliver: SliverList.list(
        children: [
          const DockerSummaryCard(state: dummyState, loading: true),
          const SizedBox(height: 10),
          ResourceOverviewCard(
            state: dummyState,
            serverId: serverId,
            loading: true,
          ),
          const SizedBox(height: 10),
          const StorageUsageCard(state: dummyState, loading: true),
          const SizedBox(height: 10),
          const DaemonConfigCard(state: dummyState, loading: true),
        ],
      ),
    );
  }
}

class _InactiveContainersPage extends StatelessWidget {
  const _InactiveContainersPage();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
      ],
    );
  }
}
