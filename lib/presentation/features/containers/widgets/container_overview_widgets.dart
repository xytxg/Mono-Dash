import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/info_panel.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/thin_divider.dart';
import '../models/container_overview_state.dart';
import '../providers/container_overview_provider.dart';
import '../screens/container_list_page.dart';
import '../screens/container_compose_page.dart';
import '../screens/compose_template_page.dart';
import '../screens/images_page.dart';
import '../screens/image_repo_page.dart';
import '../screens/network_page.dart';
import 'docker_setting_sheet.dart';

class DockerUnavailableCard extends ConsumerWidget {
  const DockerUnavailableCard({super.key, required this.state});

  final ContainerOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExist = state.dockerStatus.isExist;
    final message = !isExist
        ? context.l10n.containers_dockerNotDetected
        : context.l10n.containers_dockerNotRunning;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    TablerIcons.brand_docker,
                    size: 72,
                    color: CupertinoColors.systemGrey
                        .resolveFrom(context)
                        .withValues(alpha: 0.5),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 28,
                        color: CupertinoColors.systemOrange.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.containers_serviceUnavailable,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.secondaryLabel(context),
              ),
            ),
            if (isExist) ...[
              const SizedBox(height: 32),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => showDockerSettingSheet(
                  context,
                  onChanged: () =>
                      ref.read(containerOverviewProvider.notifier).refresh(),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.containers_configureDockerService,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DockerSummaryCard extends ConsumerWidget {
  const DockerSummaryCard({
    super.key,
    required this.state,
    this.loading = false,
  });

  final ContainerOverviewState state;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = state.daemonConfig;
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  TablerIcons.brand_docker,
                  size: 20,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Docker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (loading)
                      const SkeletonItem.text(width: 80, height: 12)
                    else
                      Text(
                        config == null || config.version.isEmpty
                            ? context.l10n.containers_serviceRunning
                            : context.l10n.containers_versionValue(
                                config.version,
                              ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (loading)
                const SkeletonItem.text(width: 48, height: 20, borderRadius: 10)
              else
                StatusPill(
                  label: context.l10n.containers_running,
                  active: state.dockerStatus.isActive,
                ),
              const SizedBox(width: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => showDockerSettingSheet(
                  context,
                  onChanged: () =>
                      ref.read(containerOverviewProvider.notifier).refresh(),
                ),
                child: Icon(
                  TablerIcons.settings,
                  size: 20,
                  color: AppColors.secondaryLabel(
                    context,
                  ).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (!loading && config?.isSwarm == true) ...[
            const SizedBox(height: 10),
            const StatusPill(label: 'Swarm', active: true),
          ],
        ],
      ),
    );
  }
}

class ResourceOverviewCard extends StatelessWidget {
  const ResourceOverviewCard({
    super.key,
    required this.state,
    required this.serverId,
    this.loading = false,
  });

  final ContainerOverviewState state;
  final int serverId;
  final bool loading;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    if (!loading && state.status == null) return const SizedBox.shrink();

    final blue = CupertinoColors.activeBlue.resolveFrom(context);
    final purple = CupertinoColors.systemPurple.resolveFrom(context);
    final indigo = CupertinoColors.systemIndigo.resolveFrom(context);
    final orange = CupertinoColors.systemOrange.resolveFrom(context);
    final teal = CupertinoColors.systemTeal.resolveFrom(context);
    final green = CupertinoColors.systemGreen.resolveFrom(context);

    return InfoPanel(
      title: context.l10n.containers_resourceCount,
      child: Column(
        children: loading
            ? _buildSkeletonRows(
                context,
                blue,
                purple,
                indigo,
                orange,
                teal,
                green,
              )
            : _buildDataRows(
                context,
                blue,
                purple,
                indigo,
                orange,
                teal,
                green,
              ),
      ),
    );
  }

  List<Widget> _buildSkeletonRows(
    BuildContext context,
    Color blue,
    Color purple,
    Color indigo,
    Color orange,
    Color teal,
    Color green,
  ) {
    return [
      MetricRow(
        icon: TablerIcons.box,
        color: blue,
        label: context.l10n.containers_containers,
        value: '',
        onTap: _noop,
        loading: true,
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.stack_2,
        color: purple,
        label: context.l10n.containers_compose,
        value: '',
        onTap: _noop,
        loading: true,
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.template,
        color: indigo,
        label: context.l10n.containers_composeTemplates,
        value: '',
        onTap: _noop,
        loading: true,
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.photo,
        color: orange,
        label: context.l10n.containers_images,
        value: '',
        onTap: _noop,
        loading: true,
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.database,
        color: teal,
        label: context.l10n.containers_imageRepos,
        value: '',
        onTap: _noop,
        loading: true,
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.network,
        color: green,
        label: context.l10n.containers_networks,
        value: '',
        onTap: _noop,
        loading: true,
      ),
    ];
  }

  List<Widget> _buildDataRows(
    BuildContext context,
    Color blue,
    Color purple,
    Color indigo,
    Color orange,
    Color teal,
    Color green,
  ) {
    final status = state.status!;
    return [
      MetricRow(
        icon: TablerIcons.box,
        color: blue,
        label: context.l10n.containers_containers,
        value: '${status.containerCount}',
        detail: context.l10n.containers_runningCount(status.running),
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ContainerListPage(serverId: serverId),
          ),
        ),
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.stack_2,
        color: purple,
        label: context.l10n.containers_compose,
        value: '${status.composeCount}',
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ContainerComposePage(serverId: serverId),
          ),
        ),
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.template,
        color: indigo,
        label: context.l10n.containers_composeTemplates,
        value: '${status.composeTemplateCount}',
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => ComposeTemplatePage(serverId: serverId),
          ),
        ),
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.photo,
        color: orange,
        label: context.l10n.containers_images,
        value: '${status.imageCount}',
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => ImagesPage(serverId: serverId)),
        ),
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.database,
        color: teal,
        label: context.l10n.containers_imageRepos,
        value: '${status.repoCount}',
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => ImageRepoPage(serverId: serverId)),
        ),
      ),
      const ThinDivider(),
      MetricRow(
        icon: TablerIcons.network,
        color: green,
        label: context.l10n.containers_networks,
        value: '${status.networkCount}',
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => NetworkPage(serverId: serverId)),
        ),
      ),
    ];
  }
}

class StorageUsageCard extends StatelessWidget {
  const StorageUsageCard({
    super.key,
    required this.state,
    this.loading = false,
  });

  final ContainerOverviewState state;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && state.itemStats == null) return const SizedBox.shrink();

    final orange = CupertinoColors.systemOrange.resolveFrom(context);
    final blue = CupertinoColors.activeBlue.resolveFrom(context);
    final teal = CupertinoColors.systemTeal.resolveFrom(context);
    final purple = CupertinoColors.systemPurple.resolveFrom(context);

    return InfoPanel(
      title: context.l10n.containers_diskUsage,
      child: Column(
        children: loading
            ? _buildSkeletonRows(context, orange, blue, teal, purple)
            : _buildDataRows(context, orange, blue, teal, purple),
      ),
    );
  }

  List<Widget> _buildSkeletonRows(
    BuildContext context,
    Color orange,
    Color blue,
    Color teal,
    Color purple,
  ) {
    return [
      UsageRow(
        icon: TablerIcons.photo,
        color: orange,
        label: context.l10n.containers_images,
        usage: 0,
        reclaimable: 0,
        loading: true,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.box,
        color: blue,
        label: context.l10n.containers_containers,
        usage: 0,
        reclaimable: 0,
        loading: true,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.database,
        color: teal,
        label: context.l10n.containers_localVolumes,
        usage: 0,
        reclaimable: 0,
        loading: true,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.tool,
        color: purple,
        label: context.l10n.containers_buildCache,
        usage: 0,
        reclaimable: 0,
        loading: true,
      ),
    ];
  }

  List<Widget> _buildDataRows(
    BuildContext context,
    Color orange,
    Color blue,
    Color teal,
    Color purple,
  ) {
    final stats = state.itemStats!;
    return [
      UsageRow(
        icon: TablerIcons.photo,
        color: orange,
        label: context.l10n.containers_images,
        usage: stats.imageUsage,
        reclaimable: stats.imageReclaimable,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.box,
        color: blue,
        label: context.l10n.containers_containers,
        usage: stats.containerUsage,
        reclaimable: stats.containerReclaimable,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.database,
        color: teal,
        label: context.l10n.containers_localVolumes,
        usage: stats.volumeUsage,
        reclaimable: stats.volumeReclaimable,
      ),
      const ThinDivider(),
      UsageRow(
        icon: TablerIcons.tool,
        color: purple,
        label: context.l10n.containers_buildCache,
        usage: stats.buildCacheUsage,
        reclaimable: stats.buildCacheReclaimable,
      ),
    ];
  }
}

class DaemonConfigCard extends StatelessWidget {
  const DaemonConfigCard({
    super.key,
    required this.state,
    this.loading = false,
  });

  final ContainerOverviewState state;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && state.daemonConfig == null) return const SizedBox.shrink();

    return InfoPanel(
      title: context.l10n.containers_dockerConfig,
      child: Column(
        children: loading
            ? _buildSkeletonRows(context)
            : _buildDataRows(context),
      ),
    );
  }

  List<Widget> _buildSkeletonRows(BuildContext context) {
    return [
      ConfigRow(
        label: context.l10n.databases_version,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      const ConfigRow(label: 'Cgroup Driver', value: '', loading: true),
      const ThinDivider(),
      const ConfigRow(label: 'Live Restore', value: '', loading: true),
      const ThinDivider(),
      const ConfigRow(label: 'iptables', value: '', loading: true),
      const ThinDivider(),
      const ConfigRow(label: 'IPv6', value: '', loading: true),
      const ThinDivider(),
      const ConfigRow(label: 'ip6tables', value: '', loading: true),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_experimentalFeatures,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_logSize,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_logFileCount,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      _RegistryListSkeleton(title: context.l10n.containers_imageAccelerator),
      const ThinDivider(),
      _RegistryListSkeleton(title: context.l10n.containers_insecureRegistries),
    ];
  }

  List<Widget> _buildDataRows(BuildContext context) {
    final config = state.daemonConfig!;
    return [
      ConfigRow(
        label: context.l10n.databases_version,
        value: _fallback(config.version),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: 'Cgroup Driver',
        value: _fallback(config.cgroupDriver),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: 'Live Restore',
        value: _boolText(context, config.liveRestore),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: 'iptables',
        value: _boolText(context, config.iptables),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: 'IPv6',
        value: _boolText(context, config.ipv6),
        valueTextAlign: TextAlign.end,
      ),
      if (config.fixedCidrV6.isNotEmpty) ...[
        const ThinDivider(),
        ConfigRow(
          label: 'Fixed CIDR v6',
          value: config.fixedCidrV6,
          valueTextAlign: TextAlign.end,
        ),
      ],
      const ThinDivider(),
      ConfigRow(
        label: 'ip6tables',
        value: _boolText(context, config.ip6Tables),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_experimentalFeatures,
        value: _boolText(context, config.experimental),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_logSize,
        value: _fallback(config.logMaxSize),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.containers_logFileCount,
        value: _fallback(config.logMaxFile),
        valueTextAlign: TextAlign.end,
      ),
      const ThinDivider(),
      RegistryList(
        title: context.l10n.containers_imageAccelerator,
        items: config.registryMirrors,
      ),
      const ThinDivider(),
      RegistryList(
        title: context.l10n.containers_insecureRegistries,
        items: config.insecureRegistries,
      ),
    ];
  }

  static String _boolText(BuildContext context, bool value) => value
      ? context.l10n.containers_enabled
      : context.l10n.containers_disabled;

  static String _fallback(String value) => value.trim().isEmpty ? '--' : value;
}

class _RegistryListSkeleton extends StatelessWidget {
  const _RegistryListSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SkeletonItem.text(width: 120, height: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistryList extends StatelessWidget {
  const RegistryList({super.key, required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Text(
                    '--',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label(context),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final item in items) ...[
                        Text(
                          item,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                        if (item != items.last) const SizedBox(height: 4),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
