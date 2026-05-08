import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../providers/app_store_provider.dart';
import 'app_installed_card.dart';
import 'app_store_empty_state.dart';
import 'docker_warning_card.dart';

class InstalledAppsTab extends ConsumerWidget {
  const InstalledAppsTab({
    super.key,
    required this.scrollController,
    required this.serverId,
  });

  final ScrollController scrollController;
  final int serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(appStoreControllerProvider);

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () =>
              ref.read(appStoreControllerProvider.notifier).refresh(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        asyncState.when(
          skipLoadingOnRefresh: true,
          skipError: true,
          data: (state) {
            final children = <Widget>[
              if (!state.dockerStatus.isAvailable) ...[
                DockerWarningCard(
                  isExist: state.dockerStatus.isExist,
                  isActive: state.dockerStatus.isActive,
                ),
                const SizedBox(height: 12),
              ],
              if (state.installedApps.isEmpty)
                AppStoreEmptyState(
                  icon: state.searchName.isNotEmpty
                      ? TablerIcons.search_off
                      : TablerIcons.package_off,
                  title: state.searchName.isNotEmpty
                      ? context.l10n.appStore_noMatchingInstalledApps
                      : context.l10n.appStore_noInstalledApps,
                )
              else
                for (final app in state.installedApps) ...[
                  AppInstalledCard(app: app),
                  const SizedBox(height: 12),
                ],
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
            ];

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 132),
              sliver: SliverList.list(children: children),
            );
          },
          loading: () => SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 132),
            sliver: SliverList.list(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  const AppInstalledCard(loading: true),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          error: (err, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TablerIcons.alert_triangle,
                      size: 46,
                      color: AppColors.tertiaryLabel(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.appStore_loadStoreFailed,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
