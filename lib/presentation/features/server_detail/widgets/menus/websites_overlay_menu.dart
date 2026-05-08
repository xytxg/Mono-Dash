import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../common/app_toast.dart';
import '../../../../common/components/action_sheet_launcher.dart';
import '../../../../common/components/app_confirm_sheet.dart';
import '../../../../common/components/frosted_overlay_menu.dart';
import '../../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../websites/providers/websites_provider.dart';
import '../../../websites/screens/create/website_create_proxy_page.dart';
import '../../../websites/screens/create/website_create_runtime_page.dart';
import '../../../websites/screens/create/website_create_static_page.dart';
import '../../../websites/screens/create/website_create_tunnel_page.dart';
import '../../../websites/widgets/openresty_status_sheet.dart';
import '../../../websites/widgets/website_group_sheet.dart';
import '../../../websites/widgets/openresty_performance_sheet.dart';
import '../../providers/active_server_provider.dart';
import '../../../containers/widgets/container_log_sheet.dart';
import '../../../../common/components/app_code_editor.dart';
import '../../../../../data/repositories_impl/website_repository_impl.dart';

Future<void> _operateOpenResty(
  BuildContext context,
  WidgetRef ref,
  String label,
  String operate,
) async {
  final l10n = context.l10n;
  final viewState = ref.read(websitesControllerProvider).valueOrNull;
  final installId = viewState?.openRestyAppInstallId;
  if (installId == null || installId == 0) {
    showAppWarningToast(l10n.serverDetail_openRestyInstallMissing);
    return;
  }

  final confirmed = await showActionSheet<bool>(
    context: context,
    builder: (_) => AppConfirmSheet(
      title: '$label OpenResty',
      content: l10n.serverDetail_openRestyConfirmContent(label),
      confirmText: label,
      confirmColor: operate == 'stop'
          ? CupertinoColors.destructiveRed
          : CupertinoColors.activeBlue,
    ),
  );
  if (confirmed != true) return;

  try {
    final appRepo = await ref.read(appRepositoryProvider.future);
    switch (operate) {
      case 'start':
        await appRepo.startInstalled(installId: installId, detailId: 0);
      case 'stop':
        await appRepo.stopInstalled(installId: installId, detailId: 0);
      case 'restart':
        await appRepo.restartInstalled(installId: installId, detailId: 0);
      case 'reload':
        await appRepo.reloadInstalled(installId: installId, detailId: 0);
    }
    showAppSuccessToast(l10n.serverDetail_openRestySuccess(label));
  } catch (e) {
    showAppErrorToast(
      l10n.serverDetail_operationFailed(label),
      description: '$e',
    );
  }
}

Future<void> _openOpenRestyConfig(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  await showAppCodeEditorSheet(
    context,
    title: l10n.serverDetail_openRestyConfigTitle,
    subtitle: l10n.serverDetail_openRestyConfigSubtitle,
    language: 'ini',
    onLoad: () async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final config = await repo.getOpenRestyConfig();
      return config.content;
    },
    onSave: (content) async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      await repo.updateOpenRestyConfig(content);
      showAppSuccessToast(l10n.common_saved);
      return true;
    },
  );
}

class WebsitesOverlayMenu extends ConsumerWidget {
  const WebsitesOverlayMenu({
    super.key,
    required this.isDark,
    required this.isOverlapping,
    this.onSearchModeEnter,
  });

  final bool isDark;
  final bool isOverlapping;
  final VoidCallback? onSearchModeEnter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return FrostedOverlayMenuButton(
      label: l10n.serverDetail_menu,
      isDark: isDark,
      isOverlapping: isOverlapping,
      items: [
        FrostedMenuItem(
          text: l10n.serverDetail_new,
          icon: CupertinoIcons.add,
          action: () {},
          children: [
            FrostedMenuItem(
              text: l10n.serverDetail_createStaticWebsite,
              icon: CupertinoIcons.doc_text,
              action: () {
                final serverId = ref.read(activeServerIdProvider);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) =>
                        WebsiteCreateStaticPage(serverId: serverId),
                  ),
                );
              },
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_createRuntimeWebsite,
              icon: CupertinoIcons.cube_box,
              action: () {
                final serverId = ref.read(activeServerIdProvider);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) =>
                        WebsiteCreateRuntimePage(serverId: serverId),
                  ),
                );
              },
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_createReverseProxy,
              icon: CupertinoIcons.arrow_right_arrow_left,
              action: () {
                final serverId = ref.read(activeServerIdProvider);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) =>
                        WebsiteCreateProxyPage(serverId: serverId),
                  ),
                );
              },
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_createTcpUdpProxy,
              icon: CupertinoIcons.arrow_2_circlepath,
              action: () {
                final serverId = ref.read(activeServerIdProvider);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) =>
                        WebsiteCreateTunnelPage(serverId: serverId),
                  ),
                );
              },
            ),
          ],
        ),
        FrostedMenuItem(
          text: l10n.common_search,
          icon: TablerIcons.search,
          action: () => onSearchModeEnter?.call(),
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_manageGroups,
          icon: TablerIcons.folder,
          iconColor: CupertinoColors.systemOrange,
          action: () {
            showWebsiteGroupSheet(context);
          },
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_runtimeStatus,
          icon: TablerIcons.activity,
          iconColor: CupertinoColors.systemTeal,
          action: () => showOpenRestyStatusSheet(context),
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_logs,
          icon: TablerIcons.logs,
          iconColor: CupertinoColors.systemBrown,
          action: () => showContainerLogSheet(
            context,
            containerName: 'openresty',
            displayName: 'OpenResty',
            initialFollow: true,
          ),
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_configEdit,
          icon: TablerIcons.settings_code,
          iconColor: CupertinoColors.systemIndigo,
          action: () => _openOpenRestyConfig(context, ref),
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_performanceTuning,
          icon: TablerIcons.adjustments_horizontal,
          iconColor: CupertinoColors.systemOrange,
          action: () => showOpenRestyPerformanceSheet(context),
        ),
        FrostedMenuItem(
          text: l10n.serverDetail_service,
          icon: TablerIcons.server,
          iconColor: CupertinoColors.systemGreen,
          action: () {},
          children: [
            FrostedMenuItem(
              text: l10n.serverDetail_start,
              icon: TablerIcons.player_play,
              iconColor: CupertinoColors.systemGreen,
              action: () => _operateOpenResty(
                context,
                ref,
                l10n.serverDetail_start,
                'start',
              ),
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_stop,
              icon: TablerIcons.player_stop,
              iconColor: CupertinoColors.destructiveRed,
              action: () => _operateOpenResty(
                context,
                ref,
                l10n.serverDetail_stop,
                'stop',
              ),
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_restart,
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.systemOrange,
              action: () => _operateOpenResty(
                context,
                ref,
                l10n.serverDetail_restart,
                'restart',
              ),
            ),
            FrostedMenuItem(
              text: l10n.serverDetail_reload,
              icon: TablerIcons.reload,
              iconColor: CupertinoColors.activeBlue,
              action: () => _operateOpenResty(
                context,
                ref,
                l10n.serverDetail_reload,
                'reload',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
