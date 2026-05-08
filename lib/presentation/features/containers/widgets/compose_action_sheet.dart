import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/app_toast.dart';
import 'container_log_sheet.dart';
import 'compose_edit_sheet.dart';
import 'compose_delete_dialog.dart';
import 'compose_terminal_action.dart';

/// 显示容器编排操作菜单
void showComposeActionSheet(
  BuildContext context,
  WidgetRef ref,
  ContainerComposeDto item,
) {
  showActionSheet(
    context: context,
    builder: (context) => _ComposeActionSheet(item: item),
  );
}

class _ComposeActionSheet extends StatelessWidget {
  const _ComposeActionSheet({required this.item});

  final ContainerComposeDto item;

  @override
  Widget build(BuildContext context) {
    final isRunning = item.runningCount > 0;
    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);

    final (leadingIcon, leadingColor) = _getLeadingInfo(context);

    return ActionSheetScaffold(
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: leadingColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: leadingIcon),
        ),
        title: item.name,
        subtitle: item.workdir,
        trailing: StatusPill(
          label: context.l10n.containers_composeRunningStatus(
            item.runningCount,
            item.containerCount,
          ),
          active: isRunning,
          activeColor: isRunning ? statusColor : null,
          inactiveColor: !isRunning ? statusColor : null,
        ),
      ),
      child: _ComposeActionList(item: item),
    );
  }

  (Widget, Color) _getLeadingInfo(BuildContext context) {
    final type = item.createdBy.toLowerCase();
    if (type == 'apps') {
      final color = CupertinoColors.systemBlue.resolveFrom(context);
      return (Icon(TablerIcons.brand_appstore, size: 32, color: color), color);
    }
    if (type == '1panel') {
      final color = CupertinoColors.activeBlue.resolveFrom(context);
      return (
        SvgPicture.asset(
          'assets/icons/1panel.svg',
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        color,
      );
    }
    final color = CupertinoColors.systemPurple.resolveFrom(context);
    return (Icon(TablerIcons.stack_2, size: 32, color: color), color);
  }
}

class _ComposeActionList extends ConsumerWidget {
  const _ComposeActionList({required this.item});

  final ContainerComposeDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppSectionHeader(
          title: context.l10n.containers_containerOperations,
          icon: TablerIcons.settings_automation,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.player_play,
              iconColor: CupertinoColors.systemGreen,
              title: context.l10n.containers_start,
              subtitle: Text(context.l10n.containers_startComposeSubtitle),
              onTap: () => _operate(context, ref, 'up'),
            ),
            AppActionRow(
              icon: TablerIcons.player_stop,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.containers_stop,
              subtitle: Text(context.l10n.containers_stopComposeSubtitle),
              onTap: () => _operate(context, ref, 'stop'),
            ),
            AppActionRow(
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.containers_restart,
              subtitle: Text(context.l10n.containers_restartComposeSubtitle),
              onTap: () => _operate(context, ref, 'restart'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_composeManagement,
          icon: TablerIcons.adjustments,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.edit,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.common_edit,
              subtitle: Text(context.l10n.containers_editComposeSubtitle),
              onTap: () => showComposeEditSheet(context, ref, item),
            ),
            AppActionRow(
              icon: TablerIcons.logs,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.containers_logs,
              subtitle: Text(context.l10n.containers_composeLogsSubtitle),
              onTap: () => showContainerLogSheet(context, composeItem: item),
            ),
            AppActionRow(
              icon: TablerIcons.terminal_2,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.containers_terminal,
              subtitle: Text(context.l10n.containers_composeTerminalSubtitle),
              onTap: () => openComposeTerminal(context, item),
            ),
          ],
        ),
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
              subtitle: Text(context.l10n.containers_deleteComposeSubtitle),
              isDestructive: true,
              onTap: () => _handleDelete(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _operate(
    BuildContext context,
    WidgetRef ref,
    String operation,
  ) async {
    final title = _getOperationName(context, operation);
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: title,
      content: context.l10n.containers_composeOperationConfirm(
        title,
        item.name,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.operateCompose(
        name: item.name,
        path: item.path,
        operation: operation,
      );

      if (context.mounted) {
        showAppSuccessToast(context.l10n.containers_operationSubmitted(title));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.containers_operationNamedFailed(title),
        description: e.toString(),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<Map<String, bool>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ComposeDeleteDialog(name: item.name),
    );

    if (result == null || !context.mounted) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.operateCompose(
        name: item.name,
        path: item.path,
        operation: 'delete',
        withFile: result['withFile'] ?? false,
        force: result['force'] ?? false,
      );

      if (context.mounted) {
        showAppSuccessToast(context.l10n.containers_composeDeleted);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.containers_deleteComposeFailed,
        description: e.toString(),
      );
    }
  }

  String _getOperationName(BuildContext context, String op) {
    switch (op) {
      case 'up':
        return context.l10n.containers_start;
      case 'stop':
        return context.l10n.containers_stop;
      case 'restart':
        return context.l10n.containers_restart;
      case 'delete':
        return context.l10n.common_delete;
      default:
        return context.l10n.containers_operationGeneric;
    }
  }
}
