import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/api/host_api.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/feature_scroll.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/loading_block.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/utils/display_utils.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../widgets/disk_item.dart';

class DiskPage extends StatelessWidget {
  const DiskPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _DiskContent(),
    );
  }
}

class _DiskContent extends ConsumerStatefulWidget {
  const _DiskContent();

  @override
  ConsumerState<_DiskContent> createState() => _DiskContentState();
}

class _DiskContentState extends ConsumerState<_DiskContent> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<HostApi> _api() async {
    final serverId = ref.read(activeServerIdProvider);
    return HostApi(await ref.read(dioClientProvider(serverId).future));
  }

  Future<Map<String, dynamic>> _load() async => (await _api()).listDisks();

  void _refresh() {
    setState(() => _future = _load());
  }

  Future<void> _unmount(Map<String, dynamic> disk) async {
    final l10n = context.l10n;
    final mountPoint = text(disk['mountPoint']);
    if (mountPoint == '--') return;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.disk_unmountTitle,
        content: l10n.disk_unmountContent(mountPoint),
        confirmText: l10n.disk_unmountAction,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      await (await _api()).unmountDisk(mountPoint);
      _refresh();
      showAppSuccessToast(l10n.disk_unmountRequested);
    } catch (e) {
      showAppErrorToast(l10n.disk_unmountFailed, description: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedScaffold(
      title: l10n.disk_title,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final disks = ((data?['disks'] as List?) ?? const [])
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList(growable: false);
          final unpartitioned =
              ((data?['unpartitionedDisks'] as List?) ?? const [])
                  .whereType<Map>()
                  .map((e) => e.cast<String, dynamic>())
                  .toList(growable: false);
          return FeatureScroll(
            onRefresh: _refresh,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting &&
                  data == null)
                LoadingBlock(label: l10n.disk_loadingInfo)
              else if (snapshot.hasError && data == null)
                AppErrorState(
                  title: l10n.common_loadingFailed,
                  error: snapshot.error!,
                  onRetry: _refresh,
                )
              else ...[
                MoreSummaryCard(
                  icon: TablerIcons.device_floppy,
                  iconColor: CupertinoColors.systemBlue,
                  title: l10n.disk_overview,
                  value: '${data?['totalDisks'] ?? disks.length}',
                  subtitle: l10n.disk_totalCapacity(
                    formatBytes(data?['totalCapacity']),
                  ),
                ),
                const SizedBox(height: 12),
                for (final disk in disks)
                  DiskItem(disk: disk, onUnmount: () => _unmount(disk)),
                if (unpartitioned.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  MoreSectionTitle(title: l10n.disk_unpartitioned),
                  for (final disk in unpartitioned) DiskItem(disk: disk),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
