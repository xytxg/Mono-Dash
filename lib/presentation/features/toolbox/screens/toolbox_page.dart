import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../data/api/toolbox_api.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/feature_scroll.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/loading_block.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/components/mini_button.dart';
import '../../../common/utils/display_utils.dart';
import '../../server_detail/providers/active_server_provider.dart';
import 'clean_scan_page.dart';

class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ToolboxContent(),
    );
  }
}

class _ToolboxContent extends ConsumerStatefulWidget {
  const _ToolboxContent();

  @override
  ConsumerState<_ToolboxContent> createState() => _ToolboxContentState();
}

class _ToolboxContentState extends ConsumerState<_ToolboxContent> {
  late Future<_ToolboxViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ToolboxApi> _api() async {
    final serverId = ref.read(activeServerIdProvider);
    return ToolboxApi(await ref.read(dioClientProvider(serverId).future));
  }

  Future<_ToolboxViewData> _load() async {
    final api = await _api();
    final results = await Future.wait<Map<String, dynamic>>([
      api.getDeviceBase(),
      api.getFail2banBase().catchError((_) => <String, dynamic>{}),
      api.getFtpBase().catchError((_) => <String, dynamic>{}),
      api.getClamBase().catchError((_) => <String, dynamic>{}),
    ]);
    return _ToolboxViewData(
      device: results[0],
      fail2ban: results[1],
      ftp: results[2],
      clam: results[3],
    );
  }

  Future<void> _scanClean() async {
    try {
      final api = await _api();
      final data = await api.scanClean();
      if (!mounted) return;
      Navigator.of(context).push(
        CupertinoPageRoute<void>(builder: (_) => CleanScanPage(data: data)),
      );
    } catch (e) {
      if (!mounted) return;
      showAppErrorToast(context.l10n.toolbox_scanFailed, description: '$e');
    }
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedScaffold(
      title: l10n.toolbox_title,
      body: FutureBuilder<_ToolboxViewData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return FeatureScroll(
            onRefresh: _refresh,
            children: [
              if (snapshot.connectionState == ConnectionState.waiting &&
                  data == null)
                LoadingBlock(label: l10n.toolbox_loadingStatus)
              else if (snapshot.hasError && data == null)
                AppErrorState(
                  title: l10n.common_loadingFailed,
                  error: snapshot.error!,
                  onRetry: _refresh,
                )
              else ...[
                MoreInfoCard(
                  icon: TablerIcons.adjustments_horizontal,
                  iconColor: CupertinoColors.activeBlue,
                  title: l10n.toolbox_quickSettings,
                  rows: [
                    MoreInfoRow(
                      l10n.toolbox_hostname,
                      text(data?.device['hostname']),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_systemUser,
                      text(data?.device['user']),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_timeZone,
                      text(data?.device['timeZone']),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_localTime,
                      text(data?.device['localTime']),
                    ),
                    MoreInfoRow(
                      'DNS',
                      ((data?.device['dns'] as List?) ?? const [])
                          .map((e) => '$e')
                          .join(', '),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MoreInfoCard(
                  icon: TablerIcons.trash,
                  iconColor: CupertinoColors.systemOrange,
                  title: l10n.toolbox_cacheClean,
                  rows: [
                    MoreInfoRow(
                      l10n.toolbox_cleanSource,
                      l10n.toolbox_cleanSourceValue,
                    ),
                    MoreInfoRow(
                      l10n.toolbox_cleanAction,
                      l10n.toolbox_cleanActionValue,
                    ),
                  ],
                  actions: [
                    MiniButton(
                      label: l10n.toolbox_scan,
                      icon: TablerIcons.scan,
                      onTap: _scanClean,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MoreInfoCard(
                  icon: TablerIcons.shield_check,
                  iconColor: CupertinoColors.systemGreen,
                  title: 'Fail2ban',
                  rows: [
                    MoreInfoRow(
                      l10n.toolbox_installed,
                      boolText(data?.fail2ban['isExist'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_running,
                      boolText(data?.fail2ban['isActive'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_enabled,
                      boolText(data?.fail2ban['isEnable'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_version,
                      text(data?.fail2ban['version']),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_port,
                      text(data?.fail2ban['port']),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MoreInfoCard(
                  icon: TablerIcons.folder_share,
                  iconColor: CupertinoColors.systemTeal,
                  title: 'FTP',
                  rows: [
                    MoreInfoRow(
                      l10n.toolbox_installed,
                      boolText(data?.ftp['isExist'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_running,
                      boolText(data?.ftp['isActive'], l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MoreInfoCard(
                  icon: TablerIcons.bug,
                  iconColor: CupertinoColors.systemRed,
                  title: l10n.toolbox_virusScan,
                  rows: [
                    MoreInfoRow(
                      'ClamAV',
                      boolText(data?.clam['isExist'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_clamAvRunning,
                      boolText(data?.clam['isActive'], l10n),
                    ),
                    MoreInfoRow(
                      'FreshClam',
                      boolText(data?.clam['freshIsExist'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_freshClamRunning,
                      boolText(data?.clam['freshIsActive'], l10n),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_version,
                      text(data?.clam['version']),
                    ),
                    MoreInfoRow(
                      l10n.toolbox_virusDatabase,
                      text(data?.clam['freshVersion']),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ToolboxViewData {
  const _ToolboxViewData({
    required this.device,
    required this.fail2ban,
    required this.ftp,
    required this.clam,
  });

  final Map<String, dynamic> device;
  final Map<String, dynamic> fail2ban;
  final Map<String, dynamic> ftp;
  final Map<String, dynamic> clam;
}
