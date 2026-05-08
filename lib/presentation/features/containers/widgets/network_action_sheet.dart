import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/network_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../providers/network_provider.dart';

/// 显示网络操作菜单
void showNetworkActionSheet(BuildContext context, NetworkDto network) {
  showActionSheet(
    context: context,
    builder: (context) => _NetworkActionSheet(network: network),
  );
}

class _NetworkActionSheet extends StatelessWidget {
  const _NetworkActionSheet({required this.network});

  final NetworkDto network;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              TablerIcons.network,
              size: 32,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
        ),
        title: network.name,
        subtitle: network.driver.isEmpty
            ? context.l10n.containers_defaultDriver
            : network.driver,
        trailing: network.isSystem
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey
                      .resolveFrom(context)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.containers_systemNetwork,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      child: _ActionList(network: network),
    );
  }
}

class _ActionList extends ConsumerWidget {
  const _ActionList({required this.network});

  final NetworkDto network;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppSectionHeader(
          title: context.l10n.containers_networkOperations,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.eye,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.containers_viewDetails,
              subtitle: Text(
                context.l10n.containers_viewNetworkDetailsSubtitle,
              ),
              onTap: () {
                Navigator.pop(context);
                _inspectNetwork(context, ref, network.name);
              },
            ),
            AppActionRow(
              icon: TablerIcons.eraser,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.containers_pruneUnusedNetworks,
              subtitle: Text(
                context.l10n.containers_pruneUnusedNetworksSubtitle,
              ),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(networkControllerProvider.notifier)
                    .pruneNetworks(context);
              },
            ),
          ],
        ),
        if (!network.isSystem) ...[
          const SizedBox(height: 22),
          AppSectionHeader(
            title: context.l10n.containers_dangerZone,
            icon: TablerIcons.alert_triangle,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.trash,
                iconColor: CupertinoColors.systemRed,
                title: context.l10n.common_delete,
                subtitle: Text(context.l10n.containers_deleteNetworkSubtitle),
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(networkControllerProvider.notifier).deleteNetworks(
                    context,
                    [network.name],
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _inspectNetwork(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final getDetailsFailedText = context.l10n.containers_getDetailsFailed;
    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      final content = await repo.inspect(id: name, type: 'network', detail: '');

      if (!context.mounted) return;
      showAppCodeEditorSheet(
        context,
        title: name,
        subtitle: 'JSON',
        initialContent: content,
        language: 'json',
        readOnly: true,
      );
    } catch (e) {
      showAppErrorToast(getDetailsFailedText, description: e.toString());
    }
  }
}
