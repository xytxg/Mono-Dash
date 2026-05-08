import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/status_pill.dart';
import '../providers/image_repo_provider.dart';
import 'image_repo_create_sheet.dart';

/// 显示镜像仓库操作菜单
void showImageRepoActionSheet(BuildContext context, ImageRepoDto repo) {
  showActionSheet(
    context: context,
    builder: (context) => _ImageRepoActionSheet(repo: repo),
  );
}

class _ImageRepoActionSheet extends StatelessWidget {
  const _ImageRepoActionSheet({required this.repo});

  final ImageRepoDto repo;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (repo.status) {
      'Success' => CupertinoColors.systemGreen.resolveFrom(context),
      'Fail' => CupertinoColors.systemRed.resolveFrom(context),
      _ => CupertinoColors.systemGrey.resolveFrom(context),
    };

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.systemTeal
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              TablerIcons.database,
              size: 32,
              color: CupertinoColors.systemTeal.resolveFrom(context),
            ),
          ),
        ),
        title: repo.name,
        subtitle: repo.downloadUrl,
        trailing: repo.status.isNotEmpty
            ? StatusPill(
                label: repo.status == 'Success'
                    ? context.l10n.containers_statusNormal
                    : context.l10n.containers_statusAbnormal,
                active: repo.status == 'Success',
                activeColor: statusColor,
                inactiveColor: statusColor,
              )
            : StatusPill(
                label: repo.protocol.toUpperCase(),
                active: repo.protocol == 'https',
                activeColor: CupertinoColors.systemGreen.resolveFrom(context),
                inactiveColor: CupertinoColors.systemOrange.resolveFrom(
                  context,
                ),
              ),
      ),
      child: _ActionList(repo: repo),
    );
  }
}

class _ActionList extends ConsumerWidget {
  const _ActionList({required this.repo});

  final ImageRepoDto repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuiltIn = repo.isBuiltIn;

    return Column(
      children: [
        AppSectionHeader(
          title: context.l10n.containers_repoOperations,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.edit,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.common_edit,
              subtitle: Text(context.l10n.containers_editRepoSubtitle),
              enabled: !isBuiltIn,
              onTap: () {
                Navigator.pop(context);
                showImageRepoCreateSheet(context, repo: repo);
              },
            ),
            AppActionRow(
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.activeBlue,
              title: context.l10n.containers_sync,
              subtitle: Text(context.l10n.containers_syncRepoSubtitle),
              enabled: !isBuiltIn,
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(imageRepoControllerProvider.notifier)
                    .syncRepo(context, repo.id);
              },
            ),
          ],
        ),
        if (!isBuiltIn) ...[
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
                subtitle: Text(context.l10n.containers_deleteRepoSubtitle),
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(imageRepoControllerProvider.notifier)
                      .deleteRepo(context, repo.id);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
