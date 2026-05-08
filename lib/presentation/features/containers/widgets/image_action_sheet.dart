import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/status_pill.dart';
import '../providers/image_list_provider.dart';
import 'image_push_sheet.dart';
import 'image_save_sheet.dart';
import 'image_tag_sheet.dart';

/// 显示镜像操作菜单
Future<void> showImageActionSheet(
  BuildContext context,
  WidgetRef ref,
  DockerImageInfo image,
) async {
  await showActionSheet(
    context: context,
    builder: (context) => _ImageActionSheet(image: image),
  );
}

class _ImageActionSheet extends StatelessWidget {
  const _ImageActionSheet({required this.image});

  final DockerImageInfo image;

  @override
  Widget build(BuildContext context) {
    final statusColor = image.isUsed
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);

    final idDisplay = image.id.replaceFirst('sha256:', '');
    final shortId = idDisplay.length > 12
        ? idDisplay.substring(0, 12)
        : idDisplay;
    final tagsDisplay = image.tags.isEmpty ? '-' : image.tags.join(', ');

    return ActionSheetScaffold(
      isAdaptive: true,
      isFloating: false,
      showHandle: false,

      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(TablerIcons.photo, size: 28, color: statusColor),
        ),
        title: shortId,
        subtitle: tagsDisplay,
        chips: image.tags.map((tag) => _TagChip(label: tag)).toList(),
        trailing: StatusPill(
          label: image.isUsed
              ? context.l10n.containers_imageUsed
              : context.l10n.containers_imageUnused,
          active: image.isUsed,
          activeColor: image.isUsed ? statusColor : null,
          inactiveColor: !image.isUsed ? statusColor : null,
        ),
      ),
      child: _ImageActionList(image: image),
    );
  }
}

class _ImageActionList extends ConsumerWidget {
  const _ImageActionList({required this.image});

  final DockerImageInfo image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(
          title: context.l10n.containers_commonActions,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.upload,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.containers_push,
              subtitle: Text(context.l10n.containers_pushImageSubtitle),
              onTap: () {
                Navigator.pop(context);
                showImagePushSheet(context, image);
              },
            ),
            AppActionRow(
              icon: TablerIcons.download,
              iconColor: CupertinoColors.systemGreen,
              title: context.l10n.containers_export,
              subtitle: Text(context.l10n.containers_exportImageSubtitle),
              onTap: () {
                Navigator.pop(context);
                showImageSaveSheet(context, image);
              },
            ),
            AppActionRow(
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.common_update,
              subtitle: Text(context.l10n.containers_updateImageSubtitle),
              onTap: () async {
                final validTags = image.tags
                    .where((t) => t.isNotEmpty && t != '<none>')
                    .toList();
                if (validTags.isEmpty) return;

                final confirmed = await showFrostedConfirmDialog(
                  context,
                  title: context.l10n.containers_updateImage,
                  icon: TablerIcons.refresh,
                  content: context.l10n.containers_updateImageConfirm(
                    validTags.join('\n'),
                  ),
                  isDestructive: false,
                  confirmText: context.l10n.containers_pull,
                );
                if (confirmed != true || !context.mounted) return;

                await ref
                    .read(imageListControllerProvider.notifier)
                    .updateImage(context, validTags);
              },
            ),
            AppActionRow(
              icon: TablerIcons.tags,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.containers_tags,
              subtitle: Text(context.l10n.containers_tagsSubtitle),
              onTap: () {
                Navigator.pop(context);
                showImageTagSheet(context, image);
              },
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
              subtitle: Text(context.l10n.containers_removeLocalImageSubtitle),
              onTap: () {
                final idDisplay = image.id.replaceFirst('sha256:', '');
                final shortId = idDisplay.length > 12
                    ? idDisplay.substring(0, 12)
                    : idDisplay;
                Navigator.pop(context);
                ref.read(imageListControllerProvider.notifier).deleteImages(
                  context,
                  [image.id],
                  displayName: image.tags.isNotEmpty
                      ? image.tags.first
                      : shortId,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLabel(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLabel(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
