import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../common/components/frosted_overlay_menu.dart';
import '../../../containers/providers/image_list_provider.dart';
import '../../../containers/widgets/image_pull_sheet.dart';
import '../../../containers/widgets/image_build_sheet.dart';

class ImageOverlayMenu extends ConsumerWidget {
  const ImageOverlayMenu({
    super.key,
    required this.isDark,
    required this.isOverlapping,
    required this.onSearchModeEnter,
  });

  final bool isDark;
  final bool isOverlapping;
  final VoidCallback onSearchModeEnter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return FrostedOverlayMenuButton(
      label: l10n.serverDetail_menu,
      isDark: isDark,
      isOverlapping: isOverlapping,
      items: [
        // 1. 搜索
        FrostedMenuItem(
          text: l10n.common_search,
          icon: TablerIcons.search,
          action: onSearchModeEnter,
        ),

        FrostedMenuItem(
          text: l10n.serverDetail_pullImage,
          icon: TablerIcons.cloud_download,
          action: () => showImagePullSheet(context),
        ),

        // 3. 导入镜像
        FrostedMenuItem(
          text: l10n.serverDetail_importImage,
          icon: TablerIcons.file_import,
          action: () =>
              ref.read(imageListControllerProvider.notifier).loadImage(context),
        ),

        // 4. 构建镜像
        FrostedMenuItem(
          text: l10n.serverDetail_buildImage,
          icon: TablerIcons.hammer,
          action: () => showImageBuildSheet(context),
        ),

        // 5. 清理构建缓存
        FrostedMenuItem(
          text: l10n.serverDetail_pruneBuildCache,
          icon: TablerIcons.eraser,
          action: () => ref
              .read(imageListControllerProvider.notifier)
              .pruneBuildCache(context),
        ),

        // 6. 清理镜像
        FrostedMenuItem(
          text: l10n.serverDetail_pruneImages,
          icon: TablerIcons.trash,
          action: () => ref
              .read(imageListControllerProvider.notifier)
              .pruneImages(context),
        ),
      ],
    );
  }
}
